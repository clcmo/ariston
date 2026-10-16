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

/// URL do seu backend/proxy de IA. Passe na execução:
///   flutter run --dart-define=ARISTON_AI_URL=https://seu-proxy.exemplo/chat
/// Sem ela, o app usa o FakeAiService (respostas simuladas).
const _aiUrl = String.fromEnvironment('ARISTON_AI_URL');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authService = AuthService();
  final AiService ai = _aiUrl.isEmpty
      ? const FakeAiService()
      : HttpAiService(
          endpoint: Uri.parse(_aiUrl),
          tokenProvider: authService.getIdToken,
        );

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
