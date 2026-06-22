/// Represents a user's profile (from the `profiles` table).
class Profile {
  final String id;
  final String? fullName;
  final String? bio;
  final String? avatarUrl;
  final int credits;
  final double rating;

  const Profile({
    required this.id,
    this.fullName,
    this.bio,
    this.avatarUrl,
    this.credits = 0,
    this.rating = 0,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      fullName: map['full_name'] as String?,
      bio: map['bio'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      credits: _parseInt(map['credits']),
      rating: _parseDouble(map['rating']),
    );
  }

  // Supabase can return numbers as strings (especially `numeric` columns),
  // so we parse defensively to avoid type-cast crashes.
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String get displayName {
    if (fullName == null || fullName!.trim().isEmpty) return 'Anonymous';
    return fullName!.trim();
  }

  String get initials {
    final parts = displayName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
