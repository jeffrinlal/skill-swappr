import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import '../models/user_skill.dart';

/// Handles reading/writing profiles and skills.
class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  final SupabaseClient _client = Supabase.instance.client;

  String? get _myId => _client.auth.currentUser?.id;

  // ===== PROFILES =====

  Future<Profile> getMyProfile() async {
    final id = _myId;
    if (id == null) throw Exception('Not logged in');
    return getProfile(id);
  }

  Future<Profile> getProfile(String userId) async {
    final data =
    await _client.from('profiles').select().eq('id', userId).single();
    return Profile.fromMap(data);
  }

  /// All profiles for browsing, optionally filtered by name or skill.
  /// Excludes the current user.
  Future<List<Profile>> getAllProfiles({String? search}) async {
    final myId = _myId;
    final rows = await _client.from('profiles').select();

    var profiles = (rows as List)
        .map((row) => Profile.fromMap(row as Map<String, dynamic>))
        .where((p) => p.id != myId)
        .toList();

    final term = search?.trim().toLowerCase();
    if (term != null && term.isNotEmpty) {
      final skillRows = await _client
          .from('user_skills')
          .select('user_id, skill_name')
          .ilike('skill_name', '%$term%');
      final matchingIds = (skillRows as List)
          .map((r) => (r as Map<String, dynamic>)['user_id'] as String)
          .toSet();

      profiles = profiles.where((p) {
        final nameMatch = p.displayName.toLowerCase().contains(term);
        return nameMatch || matchingIds.contains(p.id);
      }).toList();
    }

    profiles.sort((a, b) => b.rating.compareTo(a.rating));
    return profiles;
  }

  Future<void> updateProfile({String? fullName, String? bio}) async {
    final id = _myId;
    if (id == null) throw Exception('Not logged in');
    await _client.from('profiles').update({
      'full_name': fullName,
      'bio': bio,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // ===== SKILLS =====

  Future<List<UserSkill>> getSkills(String userId) async {
    final rows = await _client
        .from('user_skills')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return (rows as List)
        .map((row) => UserSkill.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> addSkill({
    required String skillName,
    required SkillType type,
    String? level,
  }) async {
    final id = _myId;
    if (id == null) throw Exception('Not logged in');
    await _client.from('user_skills').insert({
      'user_id': id,
      'skill_name': skillName.trim(),
      'skill_type': type.value,
      'level': level,
    });
  }

  Future<void> removeSkill(String skillId) async {
    await _client.from('user_skills').delete().eq('id', skillId);
  }
}
