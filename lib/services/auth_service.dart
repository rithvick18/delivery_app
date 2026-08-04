import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient get _supabase => Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  /// Performs Google Sign-In using native GoogleSignIn credentials or Supabase OAuth.
  Future<AuthResponse?> signInWithGoogle({
    String? webClientId,
    String? iosClientId,
  }) async {
    try {
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(OAuthProvider.google);
        return null;
      }

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
        scopes: const ['email', 'profile', 'openid'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User cancelled
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw const AuthException('No ID Token returned from Google Sign-In.');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response;
    } catch (e) {
      debugPrint(
        '[AuthService.signInWithGoogle] Error: $e. Attempting OAuth fallback...',
      );
      await _supabase.auth.signInWithOAuth(OAuthProvider.google);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint('[AuthService.signOut] Google sign out notice: $e');
    }
    await _supabase.auth.signOut();
  }
}
