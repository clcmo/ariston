import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._service) {
    _sub = _service.authStateChanges.listen((user) {
      _user = user;
      _isInitializing = false;
      notifyListeners();
    });
  }

  final AuthService _service;
  late final StreamSubscription<AuthUser?> _sub;

  AuthUser? _user;
  bool _isInitializing = true;
  bool _isLoading = false;
  String? _errorMessage;

  AuthUser? get user => _user;
  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) =>
      _run(() => _service.signIn(email, password));

  Future<void> register(String email, String password) =>
      _run(() => _service.register(email, password));

  Future<void> loginWithGoogle() => _run(() => _service.signInWithGoogle());

  Future<void> logout() => _service.signOut();

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      if (!_isCancellation(e.code)) _errorMessage = _messageFor(e.code);
    } catch (_) {
      _errorMessage = 'Algo deu errado. Tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isCancellation(String code) =>
      code == 'popup-closed-by-user' ||
      code == 'cancelled-popup-request' ||
      code == 'canceled' ||
      code == 'web-context-canceled';

  String _messageFor(String code) {
    switch (code) {
      case 'weak-password':
        return 'A senha é muito fraca!';
      case 'email-already-in-use':
        return 'Este email já está cadastrado.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'user-not-found':
        return 'Email não encontrado. Cadastre-se.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou senha incorretos.';
      case 'network-request-failed':
        return 'Sem conexão. Verifique sua internet.';
      case 'account-exists-with-different-credential':
        return 'Este email já está cadastrado com outro método de login.';
      case 'popup-blocked':
        return 'O navegador bloqueou a janela de login. Libere pop-ups e tente de novo.';
      default:
        return 'Não foi possível autenticar. Tente novamente.';
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
