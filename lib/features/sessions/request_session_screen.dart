import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/session.dart';
import '../../models/user_skill.dart';
import '../../services/profile_service.dart';
import '../../services/session_service.dart';

/// Screen where a learner requests a session with a teacher.
class RequestSessionScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;

  const RequestSessionScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  State<RequestSessionScreen> createState() => _RequestSessionScreenState();
}

class _RequestSessionScreenState extends State<RequestSessionScreen> {
  final _messageController = TextEditingController();

  List<UserSkill> _teachSkills = [];
  String? _selectedSkill;
  VideoQuality _quality = VideoQuality.standard;
  DateTime? _date;
  TimeOfDay? _time;

  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadSkills() async {
    final skills = await ProfileService.instance.getSkills(widget.teacherId);
    if (!mounted) return;
    setState(() {
      _teachSkills = skills.where((s) => s.type == SkillType.teach).toList();
      if (_teachSkills.isNotEmpty) {
        _selectedSkill = _teachSkills.first.skillName;
      }
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    if (_selectedSkill == null) {
      _snack('Please pick a skill.');
      return;
    }
    if (_date == null || _time == null) {
      _snack('Please pick a date and time.');
      return;
    }

    final scheduledAt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );

    if (scheduledAt.isBefore(DateTime.now())) {
      _snack('Please pick a time in the future.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await SessionService.instance.requestSession(
        teacherId: widget.teacherId,
        skillName: _selectedSkill!,
        quality: _quality,
        scheduledAt: scheduledAt,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );
      if (!mounted) return;
      _snack('Session requested! Waiting for ${widget.teacherName} to accept.',
          success: true);
      Navigator.of(context).pop();
    } catch (_) {
      _snack('Could not send request. Try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? AppColors.success : AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request session')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _teachSkills.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            "This person hasn't listed any skills to teach yet.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    final dateLabel = _date == null
        ? 'Pick a date'
        : DateFormat('EEE, MMM d, yyyy').format(_date!);
    final timeLabel = _time == null ? 'Pick a time' : _time!.format(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('With ${widget.teacherName}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            )),
        const SizedBox(height: 20),
        const Text('Skill', style: _labelStyle),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedSkill,
          items: _teachSkills
              .map((s) => DropdownMenuItem(
            value: s.skillName,
            child: Text(s.level != null
                ? '${s.skillName} (${s.level})'
                : s.skillName),
          ))
              .toList(),
          onChanged: (v) => setState(() => _selectedSkill = v),
        ),
        const SizedBox(height: 20),
        const Text('Video quality', style: _labelStyle),
        const SizedBox(height: 8),
        _qualityOption(VideoQuality.standard, 'Standard',
            'Good quality - 1 credit', Icons.videocam_outlined),
        const SizedBox(height: 10),
        _qualityOption(VideoQuality.premium, 'Premium HD',
            'Crystal clear - 2 credits', Icons.hd_outlined),
        const SizedBox(height: 20),
        const Text('When', style: _labelStyle),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(dateLabel, overflow: TextOverflow.ellipsis),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.access_time, size: 18),
                label: Text(timeLabel, overflow: TextOverflow.ellipsis),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Message (optional)', style: _labelStyle),
        const SizedBox(height: 8),
        TextField(
          controller: _messageController,
          maxLines: 3,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: 'e.g. I\'m a complete beginner, hoping to learn basics',
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
          )
              : const Text('Send Request'),
        ),
      ],
    );
  }

  Widget _qualityOption(
      VideoQuality value, String title, String subtitle, IconData icon) {
    final selected = _quality == value;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _quality = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

const _labelStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: AppColors.textSecondary,
);
