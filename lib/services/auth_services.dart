// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase;
  AuthService(this._supabase);

  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    return await _supabase
        .from('users')
        .select()
        .eq('auth_id', userId)
        .single();
  }
  
  // NEW: A dedicated function to create a student profile
  Future<void> createStudentProfile({
    required String userId,
    required String studentId,
    required String course,
    required int yearLevel,
  }) async {
    await _supabase.from('students').insert({
      'user_auth_id': userId,
      'student_id': studentId,
      'course': course,
      'year_level': yearLevel,
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
      },
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}