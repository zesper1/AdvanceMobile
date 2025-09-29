// lib/providers/auth_provider.dart
import 'dart:async';
import 'package:panot/services/auth_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

// Providers
@riverpod 
SupabaseClient supabaseClient(SupabaseClientRef ref) => Supabase.instance.client;

@riverpod 
AuthService authService(AuthServiceRef ref) => AuthService(ref.watch(supabaseClientProvider));

@riverpod 
Stream<AuthState> authStateChange(AuthStateChangeRef ref) => 
    ref.watch(authServiceProvider).onAuthStateChange;

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<Map<String, dynamic>?> build() async {
    final authService = ref.watch(authServiceProvider);
    final authState = await ref.watch(authStateChangeProvider.future);
    final session = authState.session;

    if (session != null) {
      try {
        return await authService.fetchUserProfile(session.user.id);
      } catch (e) {
        print("Error in AuthNotifier build: $e");
        await authService.signOut();
        return null;
      }
    }
    return null;
  }

  // ✅ Expose the current user ID anywhere in the app
  String? get currentUserId {
    return ref.read(supabaseClientProvider).auth.currentUser?.id;
  }

  // ✅ Create student profile
  Future<void> createStudentProfile({
    required String studentId,
    required String course,
    required int yearLevel,
  }) async {
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    
    await ref.read(authServiceProvider).createStudentProfile(
      userId: user.id,
      studentId: studentId,
      course: course,
      yearLevel: yearLevel,
    );
  }

  // ✅ Sign up
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signUp(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            role: role.toLowerCase().replaceAll(' ', '_'),
          );
      return null;
    });
  }

  // ✅ Sign in
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profile = await ref.read(authServiceProvider).signIn(
            email: email,
            password: password,
          );
      return profile;
    });
  }

  // ✅ Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await ref.read(authServiceProvider).signOut();
    state = const AsyncValue.data(null);
  }
}
