import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../models/profile.dart';
import '../../models/user_skill.dart';
import '../../services/profile_service.dart';

/// Browse all other users, with a search box (by name or skill).
class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<Profile> _profiles = [];
  Map<String, List<UserSkill>> _skillsByUser = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load({String? search}) async {
    setState(() => _loading = true);
    try {
      final profiles =
      await ProfileService.instance.getAllProfiles(search: search);

      final map = <String, List<UserSkill>>{};
      for (final p in profiles) {
        final skills = await ProfileService.instance.getSkills(p.id);
        map[p.id] = skills.where((s) => s.type == SkillType.teach).toList();
      }

      if (!mounted) return;
      setState(() {
        _profiles = profiles;
        _skillsByUser = map;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _load(search: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse Skills')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name or skill...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _load();
                  },
                )
                    : null,
              ),
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_profiles.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No users found.Invite friends to join Skill Swappr!',
          textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(search: _searchController.text),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: _profiles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final p = _profiles[i];
          final teach = _skillsByUser[p.id] ?? [];
          return _UserCard(
            profile: p,
            teachSkills: teach,
            onTap: () => context.push('/user/${p.id}'),
          );
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Profile profile;
  final List<UserSkill> teachSkills;
  final VoidCallback onTap;

  const _UserCard({
    required this.profile,
    required this.teachSkills,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AvatarCircle(initials: profile.initials, size: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(Icons.star_rounded,
                            color: AppColors.warning, size: 18),
                        const SizedBox(width: 2),
                        Text(
                          profile.rating > 0
                              ? profile.rating.toStringAsFixed(1)
                              : 'New',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (teachSkills.isEmpty)
                      const Text('No skills listed yet',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13))
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: teachSkills.take(3).map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s.skillName,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
