import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class AuthUser {
  const AuthUser({required this.uid});

  final String uid;
}

/// Camada fina sobre o FirebaseAuth, sem estado de UI.
abstract interface class AuthService {
  Stream<AuthUser?> get authStateChanges;

  Future<void> signIn(String email, String password);
  Future<void> register(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Future<String?> getIdToken();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<AuthUser?> get authStateChanges => _auth
      .authStateChanges()
      .map((user) => user == null ? null : AuthUser(uid: user.uid));

  @override
  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  @override
  Future<void> register(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  @override
  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    if (kIsWeb) {
      await _auth.signInWithPopup(provider);
    } else {
      await _auth.signInWithProvider(provider);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<String?> getIdToken() async => _auth.currentUser?.getIdToken();
}

class DemoAuthService implements AuthService {
  AuthUser? _user;
  final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> get authStateChanges async* {
    yield _user;
    yield* _authStateController.stream;
  }

  @override
  Future<void> signIn(String email, String password) async {
    _authenticate(email, password);
  }

  @override
  Future<void> register(String email, String password) async {
    _authenticate(email, password);
  }

  @override
  Future<void> signInWithGoogle() async {
    _user = const AuthUser(uid: 'demo-google');
    _authStateController.add(_user);
  }

  void _authenticate(String email, String password) {
    if (email.trim().isEmpty || password.isEmpty) {
      throw ArgumentError('Informe email e senha para entrar no modo demo.');
    }
    _user = AuthUser(uid: 'demo-${email.trim().toLowerCase()}');
    _authStateController.add(_user);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _authStateController.add(null);
  }

  @override
  Future<String?> getIdToken() async => null;
}
