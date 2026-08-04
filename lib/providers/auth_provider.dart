import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription<AuthState>? _authStateSubscription;

  User? _user;
  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user ?? _authService.currentUser;
  bool get isAuthenticated => user != null;
  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _init();
  }

  void _init() {
    _user = _authService.currentUser;
    if (_user != null) {
      _syncUserProfile(_user!);
    }

    _authStateSubscription = _authService.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      final User? newUser = session?.user ?? _authService.currentUser;

      _user = newUser;
      _errorMessage = null;

      if (newUser != null) {
        _syncUserProfile(newUser);
      } else if (event == AuthChangeEvent.signedOut) {
        _profile = null;
      }

      notifyListeners();
    });
  }

  Future<void> _syncUserProfile(User user) async {
    try {
      final String fullName = user.userMetadata?['full_name'] ??
          user.userMetadata?['name'] ??
          (user.email != null ? user.email!.split('@').first : 'User');
      final String? avatarUrl = user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'];

      final profileData = {
        'id': user.id,
        'email': user.email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Automatically upsert user profile into public.profiles
      await _supabase.from('profiles').upsert(profileData);

      // Fetch updated profile
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        _profile = Map<String, dynamic>.from(response);
      } else {
        _profile = profileData;
      }
    } catch (e) {
      print('[AuthProvider._syncUserProfile] Profile upsert notice: $e');
      _profile = {
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? user.email?.split('@').first,
        'avatar_url': user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
      };
    }
    notifyListeners();
  }

  Future<bool> signInWithGoogle({String? webClientId, String? iosClientId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signInWithGoogle(
        webClientId: webClientId,
        iosClientId: iosClientId,
      );
      if (response?.user != null) {
        _user = response!.user;
        await _syncUserProfile(_user!);
      }
      _isLoading = false;
      notifyListeners();
      return isAuthenticated;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signOut();
      _user = null;
      _profile = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
