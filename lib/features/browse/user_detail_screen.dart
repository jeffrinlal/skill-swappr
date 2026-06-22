import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../models/profile.dart';
import '../../models/user_skill.dart';
import '../../services/profile_service.dart';
import 'package:go_router/go_router.dart';


/// Shows another user's full profile and skills.
/// The "Request Session" button is a placeholder for Phase 3.
class UserDetailScreen extends StatefulWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  Profile? _profile;
  List<UserSkill> _skills = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await ProfileService.instance.getProfile(widget.userId);
      final skills = await ProfileService.instance.getSkills(widget.userId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _skills = skills;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_profile?.displayName ?? 'Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
          ? const Center(child: Text('Could not load this profile.'))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final profile = _profile!;
    final teach = _skills.where((s) => s.type == SkillType.teach).toList();
    final learn = _skills.where((s) => s.type == SkillType.learn).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              AvatarCircle(initials: profile.initials, size: 96),
              const SizedBox(height: 12),
              Text(profile.displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.warning, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    profile.rating > 0
                        ? '${profile.rating.toStringAsFixed(1)} rating'
                        : 'New member',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (profile.bio != null && profile.bio!.trim().isNotEmpty) ...[
          const Text('About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 8),
          Text(profile.bio!,
              style: const TextStyle(
                  color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 24),
        ],
        const Text('Can teach',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            )),
        const SizedBox(height: 8),
        _skillWrap(teach, AppColors.primary, 'Nothing listed yet.'),
        const SizedBox(height: 20),
        const Text('Wants to learn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            )),
        const SizedBox(height: 8),
        _skillWrap(learn, AppColors.accent, 'Nothing listed yet.'),
        const SizedBox(height: 28),
    ElevatedButton.icon(
    onPressed: () {
    context.push(
    '/request/${profile.id}',
    extra: profile.displayName,
    );
    },
    icon: const Icon(Icons.video_call),
    label: const Text('Request Session'),
    ),

      ],
    );
  }

  Widget _skillWrap(List<UserSkill> skills, Color color, String emptyText) {
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
