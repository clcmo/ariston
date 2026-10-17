import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  FirebaseAuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        // Na v7+, injetamos a instância Singleton caso não seja fornecida uma de teste
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

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
    // 1. Inicializa o Singleton padrão do pacote v7+
    await _googleSignIn.initialize();

    // 2. Realiza a identificação do usuário
    final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
    if (googleUser == null) return; 

    // 3. Obtém o idToken (Identidade)
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // 4. Solicita explicitamente o escopo para capturar o accessToken (Autorização)
    final List<String> scopes = ['email', 'profile'];
    final clientAuth = await googleUser.authorizationClient.authorizeScopes(scopes);

    // 5. Cria a credencial para o Firebase cruzando os dois tokens exigidos
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: clientAuth.accessToken, // Token extraído da nova camada de escopo
      idToken: googleAuth.idToken,
    );

    // 6. Realiza o login final no Firebase
    await _auth.signInWithCredential(credential);
  }


  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

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
