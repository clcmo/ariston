import 'package:flutter/material.dart';

import '../ui/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await HiveConfig.start();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    runApp(StartupErrorApp(message: '$e'));
    return;
  }

class AristonApp extends StatelessWidget {
  const AristonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ariston',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SelectableText('Erro ao iniciar o Ariston:\n\n$message'),
            ),
          ),
        ),
      );
}
