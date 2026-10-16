import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/chat_repository.dart';
import '../chat/chat_view.dart';
import '../chat/chat_viewmodel.dart';
import 'auth_viewmodel.dart';
import 'login_view.dart';

/// Decide a tela: carregando, login ou chat.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    if (auth.isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = auth.user;
    if (user == null) return const LoginView();

    return ChangeNotifierProvider<ChatViewModel>(
      key: ValueKey(user.uid),
      create: (c) => ChatViewModel(
        repository: c.read<ChatRepository>(),
        userId: user.uid,
      )..load(),
      child: const ChatView(),
    );
  }
}
