import 'package:blood_bridge/data/models/user_model.dart';
import 'package:blood_bridge/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';


enum AuthStatus { initial, loading, otpSent, authenticated, error, profileIncomplete }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  AuthStatus _status = AuthStatus.initial;
UserModel? _user;
  String _verificationId = '';
  String _errorMessage = '';
  String _phoneNumber = '';

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String get errorMessage => _errorMessage;
  String get phoneNumber => _phoneNumber;
  bool get isLoggedIn => _repo.currentUser != null;

  AuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _repo.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        final profile = await _repo.getUserProfile(firebaseUser.uid);
        _user = profile;
        if (profile != null && _repo.isProfileComplete(profile)) {
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.profileIncomplete;
        }
      } else {
        _status = AuthStatus.initial;
        _user = null;
      }
      notifyListeners();
    });
  }

  // ─── Send OTP ─────────────────────────────────────────────
  Future<void> sendOTP(String phone) async {
    _status = AuthStatus.loading;
    _phoneNumber = phone;
    _errorMessage = '';
    notifyListeners();

    await _repo.sendOTP(
      phoneNumber: phone,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        _status = AuthStatus.otpSent;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error;
        _status = AuthStatus.error;
        notifyListeners();
      },
    );
  }

  // ─── Verify OTP ───────────────────────────────────────────
  Future<void> verifyOTP(String otp) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final credential = await _repo.verifyOTP(
        verificationId: _verificationId,
        otp: otp,
      );

      if (credential?.user != null) {
        final user = credential!.user!;
        _user = await _repo.createOrGetUser(user.uid, user.phoneNumber ?? _phoneNumber);

        if (_repo.isProfileComplete(_user!)) {
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.profileIncomplete;
        }
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────
  Future<void> signOut() async {
    await _repo.signOut();
    _user = null;
    _status = AuthStatus.initial;
    notifyListeners();
  }

  void resetError() {
    if (_status == AuthStatus.error) {
      _status = _verificationId.isEmpty ? AuthStatus.initial : AuthStatus.otpSent;
      _errorMessage = '';
      notifyListeners();
    }
  }
}
