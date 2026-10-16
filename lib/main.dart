import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'config/hive_config.dart';
import 'data/repositories/chat_repository.dart';
import 'data/services/ai_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/chat_history_store.dart';
import 'firebase_options.dart';
import 'ui/auth/auth_viewmodel.dart';

const _aiUrl = String.fromEnvironment('ARISTON_AI_URL');
const _demoMode = bool.fromEnvironment('ARISTON_DEMO_MODE');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await HiveConfig.start();
    if (!_demoMode) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    runApp(StartupErrorApp(message: '$e'));
    return;
  }

  final AuthService authService =
      _demoMode ? DemoAuthService() : FirebaseAuthService();
  // Só usa o proxy se a URL for http(s); caso contrário, IA simulada.
  final AiService ai = !_demoMode && _aiUrl.startsWith('http')
      ? HttpAiService(
          endpoint: Uri.parse(_aiUrl),
          tokenProvider: authService.getIdToken,
        )
      : const FakeAiService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<AuthViewModel>(
          create: (c) => AuthViewModel(c.read<AuthService>()),
        ),
        Provider<ChatRepository>(
          create: (_) => ChatRepository(
            ai: ai,
            store: HiveChatHistoryStore(
              Hive.box<String>(HiveConfig.chatBoxName),
            ),
          ),
        ),
      ],
      child: const AristonApp(),
    ),
  );
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