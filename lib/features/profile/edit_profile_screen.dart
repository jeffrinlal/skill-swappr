import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/user_skill.dart';
import '../../services/profile_service.dart';

/// Edit name, bio, and manage teach/learn skills.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  List<UserSkill> _skills = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await ProfileService.instance.getMyProfile();
    final skills = await ProfileService.instance.getSkills(profile.id);
    if (!mounted) return;
    setState(() {
      _nameController.text = profile.fullName ?? '';
      _bioController.text = profile.bio ?? '';
      _skills = skills;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ProfileService.instance.updateProfile(
        fullName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save. Try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addSkillDialog() async {
    final nameController = TextEditingController();
    SkillType type = SkillType.teach;
    String? level = 'Beginner';

    final added = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialog) {
            return AlertDialog(
              title: const Text('Add a skill'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Skill (e.g. Guitar, Spanish)',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<SkillType>(
                    segments: const [
                      ButtonSegment(
                          value: SkillType.teach, label: Text('Teach')),
                      ButtonSegment(
                          value: SkillType.learn, label: Text('Learn')),
                    ],
                    selected: {type},
                    onSelectionChanged: (s) => setDialog(() => type = s.first),
                  ),
                  const SizedBox(height: 16),
                  if (type == SkillType.teach)
                    DropdownButtonFormField<String>(
                      initialValue: level,
                      decoration: const InputDecoration(labelText: 'Level'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Beginner', child: Text('Beginner')),
                        DropdownMenuItem(
                            value: 'Intermediate',
                            child: Text('Intermediate')),
                        DropdownMenuItem(
                            value: 'Advanced', child: Text('Advanced')),
                      ],
                      onChanged: (v) => setDialog(() => level = v),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 44)),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    await ProfileService.instance.addSkill(
                      skillName: nameController.text,
                      type: type,
                      level: type == SkillType.teach ? level : null,
                    );
                    if (context.mounted) Navigator.pop(context, true);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (added == true) _load();
  }

  Future<void> _removeSkill(UserSkill skill) async {
    await ProfileService.instance.removeSkill(skill.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final teachSkills =
    _skills.where((s) => s.type == SkillType.teach).toList();
    final learnSkills =
    _skills.where((s) => s.type == SkillType.learn).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController,
            maxLines: 4,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: 'Bio',
              hintText: 'Tell others about yourself...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My skills',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  )),
              TextButton.icon(
                onPressed: _addSkillDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add skill'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _skillSection('I can teach', teachSkills, AppColors.primary),
          const SizedBox(height: 16),
          _skillSection('I want to learn', learnSkills, AppColors.accent),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
                : const Text('Save Profile'),
          ),
        ],
      ),
    );
  }

  Widget _skillSection(String title, List<UserSkill> skills, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (skills.isEmpty)
          const Text('None yet - tap "Add skill" above.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) {
              final label = s.level != null
                  ? '${s.skillName} (${s.level})'
                  : s.skillName;
              return Chip(
                label: Text(label),
                backgroundColor: color.withValues(alpha: 0.12),
                labelStyle:
                TextStyle(color: color, fontWeight: FontWeight.w600),
                side: BorderSide.none,
                onDeleted: () => _removeSkill(s),
                deleteIconColor: color,
              );
            }).toList(),
          ),
      ],
    );
  }
}
