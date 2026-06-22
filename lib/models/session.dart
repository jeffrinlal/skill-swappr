/// Video quality tiers: standard (Jitsi, 1 credit) or premium (Agora, 2 credits).
enum VideoQuality { standard, premium }

extension VideoQualityX on VideoQuality {
  String get value => this == VideoQuality.premium ? 'premium' : 'standard';
  int get cost => this == VideoQuality.premium ? 2 : 1;
  String get label =>
      this == VideoQuality.premium ? 'Premium HD' : 'Standard';

  static VideoQuality fromValue(String v) =>
      v == 'premium' ? VideoQuality.premium : VideoQuality.standard;
}

/// Lifecycle of a session request.
enum SessionStatus { pending, accepted, rejected, cancelled, completed }

extension SessionStatusX on SessionStatus {
  String get value => name;
  String get label {
    switch (this) {
      case SessionStatus.pending:
        return 'Pending';
      case SessionStatus.accepted:
        return 'Accepted';
      case SessionStatus.rejected:
        return 'Declined';
      case SessionStatus.cancelled:
        return 'Cancelled';
      case SessionStatus.completed:
        return 'Completed';
    }
  }

  static SessionStatus fromValue(String v) => SessionStatus.values
      .firstWhere((s) => s.name == v, orElse: () => SessionStatus.pending);
}

/// A 1-on-1 session between a teacher and a learner.
class Session {
  final String id;
  final String teacherId;
  final String learnerId;
  final String skillName;
  final VideoQuality quality;
  final int creditsCost;
  final DateTime scheduledAt;
  final SessionStatus status;
  final String? message;

  // Filled in by the service (not columns in the table).
  final String? teacherName;
  final String? learnerName;

  const Session({
    required this.id,
    required this.teacherId,
    required this.learnerId,
    required this.skillName,
    required this.quality,
    required this.creditsCost,
    required this.scheduledAt,
    required this.status,
    this.message,
    this.teacherName,
    this.learnerName,
  });

  factory Session.fromMap(
      Map<String, dynamic> map, {
        String? teacherName,
        String? learnerName,
      }) {
    return Session(
      id: map['id'] as String,
      teacherId: map['teacher_id'] as String,
      learnerId: map['learner_id'] as String,
      skillName: map['skill_name'] as String,
      quality: VideoQualityX.fromValue(map['video_quality'] as String),
      creditsCost: (map['credits_cost'] as num?)?.toInt() ?? 1,
      scheduledAt: DateTime.parse(map['scheduled_at'] as String).toLocal(),
      status: SessionStatusX.fromValue(map['status'] as String),
      message: map['message'] as String?,
      teacherName: teacherName,
      learnerName: learnerName,
    );
  }
}
