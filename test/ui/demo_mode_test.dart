import 'package:ariston/app/app.dart';
import 'package:ariston/data/repositories/chat_repository.dart';
import 'package:ariston/data/services/ai_service.dart';
import 'package:ariston/data/services/auth_service.dart';
import 'package:ariston/data/services/chat_history_store.dart';
import 'package:ariston/ui/auth/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('demo auth opens the chat without Firebase', (tester) async {
    final authService = DemoAuthService();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: authService),
          ChangeNotifierProvider(
            create: (_) => AuthViewModel(authService),
          ),
          Provider(
            create: (_) => ChatRepository(
              ai: const FakeAiService(delay: Duration.zero),
              store: InMemoryChatHistoryStore(),
            ),
          ),
        ],
        child: const AristonApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RISTON'), findsOneWidget);
    expect(find.text('Bem-vinda'), findsOneWidget);

    await tester.enterText(
        find.byType(TextFormField).first, 'demo@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'senha-demo');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Pergunte algo ao Ariston.'), findsOneWidget);
  });
}
