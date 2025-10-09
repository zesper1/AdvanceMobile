import 'dart:async';
import 'package:panot/models/user_model.dart';
import 'package:panot/services/auth_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

// These providers remain the same
@riverpod SupabaseClient supabaseClient(SupabaseClientRef ref) => Supabase.instance.client;
@riverpod AuthService authService(AuthServiceRef ref) => AuthService(ref.watch(supabaseClientProvider));
@riverpod Stream<AuthState> authStateChange(AuthStateChangeRef ref) => ref.watch(authServiceProvider).onAuthStateChange;


@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<UserProfile?> build() async {
    final authService = ref.watch(authServiceProvider);
    
    // Listen to the auth state stream to automatically handle login, logout, and password recovery
    final authStateSubscription = ref.listen(authStateChangeProvider, (_, next) async {
      final session = next.asData?.value.session;
      if (session != null) {
        // User is logged in, fetch their profile
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
          final profileMap = await authService.fetchUserProfile(session.user.id);
          return UserProfile.fromJson(profileMap);
        });
      } else {
        // User is logged out
        state = const AsyncValue.data(null);
      }
    });

    // Clean up the listener when the provider is disposed
    ref.onDispose(() => authStateSubscription.close());

    // Initial check
    final initialSession = ref.read(supabaseClientProvider).auth.currentSession;
    if (initialSession != null) {
      final profileMap = await authService.fetchUserProfile(initialSession.user.id);
      return UserProfile.fromJson(profileMap);
    }
    
    return null;
  }
  
  // createStudentProfile method remains the same
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

  // signUp method remains the same
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

  // CORRECTED signIn method
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // Just call the service. The `build` method's listener will automatically
    // handle the state update upon successful login.
    await ref.read(authServiceProvider).signIn(
      email: email,
      password: password,
    );
  }

  // NEW: Method to send the password reset link
  Future<void> sendPasswordResetEmail(String email) async {
    // We don't need to manage state here, just call the service.
    // The UI will show a confirmation message.
    await ref.read(authServiceProvider).sendPasswordResetEmail(email);
  }

  // NEW: Method to update the user's password after they've clicked the link
  Future<void> updateUserPassword(String newPassword) async {
    await ref.read(supabaseClientProvider).auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // signOut method remains the same
  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    // The listener in `build` will automatically set the state to AsyncData(null)
  }
}