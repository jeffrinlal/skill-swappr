/// Whether a skill is something the user can teach or wants to learn.
enum SkillType { teach, learn }

extension SkillTypeX on SkillType {
  String get value => this == SkillType.teach ? 'teach' : 'learn';

  static SkillType fromValue(String value) =>
      value == 'teach' ? SkillType.teach : SkillType.learn;
}

/// A single skill belonging to a user (from the `user_skills` table).
class UserSkill {
  final String id;
  final String userId;
  final String skillName;
  final SkillType type;
  final String? level;

  const UserSkill({
    required this.id,
    required this.userId,
    required this.skillName,
    required this.type,
    this.level,
  });

  factory UserSkill.fromMap(Map<String, dynamic> map) {
    return UserSkill(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      skillName: map['skill_name'] as String,
      type: SkillTypeX.fromValue(map['skill_type'] as String),
      level: map['level'] as String?,
    );
  }
}
