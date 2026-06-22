import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/session.dart';
import '../../services/session_service.dart';

/// Shows the user's sessions in two tabs: Teaching and Learning.
class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  List<Session> _all = [];
  bool _loading = true;
  String? _myId;

  @override
  void initState() {
    super.initState();
    _myId = SessionService.instance.myId;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final sessions = await SessionService.instance.getMySessions();
      if (!mounted) return;
      setState(() {
        _all = sessions;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _setStatus(Session s, SessionStatus status) async {
    await SessionService.instance.updateStatus(s.id, status);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final teaching = _all.where((s) => s.teacherId == _myId).toList();
    final learning = _all.where((s) => s.learnerId == _myId).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Sessions'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Teaching'),
              Tab(text: 'Learning'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _list(teaching, isTeacher: true),
            _list(learning, isTeacher: false),
          ],
        ),
      ),
    );
  }

  Widget _list(List<Session> sessions, {required bool isTeacher}) {
    if (sessions.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            const SizedBox(height: 120),
            Center(
              child: Text(
                isTeacher
                    ? 'No one has booked you yet.'
                    : 'You haven\'t requested any sessions.'
                'Browse skills to get started!',
              textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _card(sessions[i], isTeacher: isTeacher),
      ),
    );
  }

  Widget _card(Session s, {required bool isTeacher}) {
    final otherName =
    isTeacher ? (s.learnerName ?? 'Someone') : (s.teacherName ?? 'Someone');
    final dateStr = DateFormat('EEE, MMM d - h:mm a').format(s.scheduledAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.skillName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _statusBadge(s.status),
              ],
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.person_outline,
                isTeacher ? 'Learner: $otherName' : 'Teacher: $otherName'),
            const SizedBox(height: 4),
            _infoRow(Icons.schedule, dateStr),
            const SizedBox(height: 4),
            _infoRow(
              s.quality == VideoQuality.premium
                  ? Icons.hd_outlined
                  : Icons.videocam_outlined,
              '${s.quality.label} - ${s.creditsCost} credit${s.creditsCost > 1 ? 's' : ''}',
            ),
            if (s.message != null && s.message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('"${s.message!}"',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic)),
              ),
            ],
            _actions(s, isTeacher: isTeacher),
          ],
        ),
      ),
    );
  }

  Widget _actions(Session s, {required bool isTeacher}) {
    if (isTeacher && s.status == SessionStatus.pending) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _setStatus(s, SessionStatus.rejected),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error),
                child: const Text('Decline'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _setStatus(s, SessionStatus.accepted),
                child: const Text('Accept'),
              ),
            ),
          ],
        ),
      );
    }

    if (!isTeacher && s.status == SessionStatus.pending) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _setStatus(s, SessionStatus.cancelled),
            style:
            OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancel request'),
          ),
        ),
      );
    }

    if (s.status == SessionStatus.accepted) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 18),
            SizedBox(width: 6),
            Expanded(
              child: Text('Scheduled! Video call coming in Phase 5.',
                  style: TextStyle(color: AppColors.success, fontSize: 13)),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _statusBadge(SessionStatus status) {
    Color color;
    switch (status) {
      case SessionStatus.pending:
        color = AppColors.warning;
        break;
      case SessionStatus.accepted:
      case SessionStatus.completed:
        color = AppColors.success;
        break;
      case SessionStatus.rejected:
      case SessionStatus.cancelled:
        color = AppColors.error;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
