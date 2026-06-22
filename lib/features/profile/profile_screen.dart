import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../models/profile.dart';
import '../../models/user_skill.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';

/// Shows the logged-in user's own profile.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile? _profile;
  List<UserSkill> _skills = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ProfileService.instance.getMyProfile();
      final skills = await ProfileService.instance.getSkills(profile.id);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _skills = skills;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load profile.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => AuthService.instance.signOut(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    final profile = _profile!;
    final teachSkills =
    _skills.where((s) => s.type == SkillType.teach).toList();
    final learnSkills =
    _skills.where((s) => s.type == SkillType.learn).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                AvatarCircle(initials: profile.initials, size: 96),
                const SizedBox(height: 12),
                Text(
                  profile.displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _statPill(
                      icon: Icons.stars_rounded,
                      label: '${profile.credits} credits',
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 12),
                    _statPill(
                      icon: Icons.star_rounded,
                      label: profile.rating > 0
                          ? profile.rating.toStringAsFixed(1)
                          : 'New',
                      color: AppColors.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('About me'),
          const SizedBox(height: 8),
          Text(
            (profile.bio == null || profile.bio!.trim().isEmpty)
                ? 'No bio yet. Tap "Edit Profile" to add one.'
                : profile.bio!,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          _sectionTitle('I can teach'),
          const SizedBox(height: 8),
          _skillWrap(teachSkills, AppColors.primary,
              emptyText: 'No teaching skills yet.'),
          const SizedBox(height: 20),
          _sectionTitle('I want to learn'),
          const SizedBox(height: 8),
          _skillWrap(learnSkills, AppColors.accent,
              emptyText: 'No learning interests yet.'),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () async {
              await context.push('/edit-profile');
              _load();
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
  );

  Widget _statPill(
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _skillWrap(List<UserSkill> skills, Color color,
      {required String emptyText}) {
    if (skills.isEmpty) {
      return Text(emptyText,
          style: const TextStyle(color: AppColors.textSecondary));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((s) {
        final label =
        s.level != null ? '${s.skillName} (${s.level})' : s.skillName;
        return Chip(
          label: Text(label),
          backgroundColor: color.withValues(alpha: 0.12),
          labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }
}
