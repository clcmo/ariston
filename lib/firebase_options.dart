// PLACEHOLDER — substitua este arquivo rodando, na raiz do projeto:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// O comando gera o arquivo real com as chaves do seu projeto Firebase
// (android, ios e web). Essas chaves de cliente não são segredo, então
// o arquivo gerado pode ser versionado.
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Rode "flutterfire configure" para gerar o firebase_options.dart.',
    );
  }
}
