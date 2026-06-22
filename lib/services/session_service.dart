import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../models/session.dart';

/// Handles creating and managing sessions.
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  final SupabaseClient _client = Supabase.instance.client;

  String? get myId => _client.auth.currentUser?.id;

  /// Learner requests a new session with a teacher.
  Future<void> requestSession({
    required String teacherId,
    required String skillName,
    required VideoQuality quality,
    required DateTime scheduledAt,
    String? message,
  }) async {
    final me = myId;
    if (me == null) throw Exception('Not logged in');
    await _client.from('sessions').insert({
      'teacher_id': teacherId,
      'learner_id': me,
      'skill_name': skillName,
      'video_quality': quality.value,
      'credits_cost': quality.cost,
      'scheduled_at': scheduledAt.toUtc().toIso8601String(),
      'message': message,
      'status': 'pending',
    });
  }

  /// All sessions the current user is part of, with the other party's name.
  Future<List<Session>> getMySessions() async {
    final me = myId;
    if (me == null) throw Exception('Not logged in');

    final rows = await _client
        .from('sessions')
        .select()
        .or('teacher_id.eq.$me,learner_id.eq.$me')
        .order('scheduled_at', ascending: true);

    final list = (rows as List).cast<Map<String, dynamic>>();
    if (list.isEmpty) return [];

    final ids = <String>{};
    for (final m in list) {
      ids.add(m['teacher_id'] as String);
      ids.add(m['learner_id'] as String);
    }

    final profs = await _client
        .from('profiles')
        .select('id, full_name')
        .inFilter('id', ids.toList());

    final nameMap = <String, String?>{
      for (final p in (profs as List))
        (p as Map<String, dynamic>)['id'] as String:
        p['full_name'] as String?,
    };

    return list
        .map((m) => Session.fromMap(
      m,
      teacherName: nameMap[m['teacher_id']],
      learnerName: nameMap[m['learner_id']],
    ))
        .toList();
  }

  /// Update a session's status (accept / reject / cancel / complete).
  Future<void> updateStatus(String sessionId, SessionStatus status) async {
    await _client
        .from('sessions')
        .update({'status': status.value}).eq('id', sessionId);
  }
}
