// lib/providers/auth_provider.dart
import 'dart:async';
import 'package:panot/models/user_model.dart';
import 'package:panot/services/auth_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

// ... (supabaseClientProvider, authServiceProvider, authStateChangeProvider remain the same) ...
@riverpod SupabaseClient supabaseClient(SupabaseClientRef ref) => Supabase.instance.client;
@riverpod AuthService authService(AuthServiceRef ref) => AuthService(ref.watch(supabaseClientProvider));
@riverpod Stream<AuthState> authStateChange(AuthStateChangeRef ref) => ref.watch(authServiceProvider).onAuthStateChange;


@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<UserProfile?> build() async {
    final authService = ref.watch(authServiceProvider);
    final authState = await ref.watch(authStateChangeProvider.future);
    final session = authState.session;

    if (session != null) {
      try {
        final profileMap = await authService.fetchUserProfile(session.user.id);
        if (profileMap != null) {
          return UserProfile.fromJson(profileMap);
        }
      } catch (e) {
        print("Error in AuthNotifier build: $e");
        await authService.signOut();
        return null;
      }
    }
    return null;
  }
  
  // NEW: Expose the createStudentProfile method
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

  // In lib/providers/auth_provider.dart
  Future<void> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    await ref.read(authServiceProvider).signUp(
      email: email,
      password: password,
      metadata: metadata,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signIn(
            email: email,
            password: password,
          );
      return null;
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await ref.read(authServiceProvider).signOut();
    state = const AsyncValue.data(null);
  }
}