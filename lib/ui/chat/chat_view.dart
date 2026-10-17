import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_viewmodel.dart';
import '../../config/app_info.dart';
import '../brand/ariston_brand.dart';
import 'chat_viewmodel.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    final messages = vm.messages;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const AristonLogo(width: 120),
        actions: [
          IconButton(
            tooltip: 'Limpar conversa',
            icon: const Icon(Icons.delete_outline),
            onPressed: messages.isEmpty ? null : vm.clearChat,
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthViewModel>().logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        'Pergunte algo ao Ariston.\n${AppInfo.label}',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        final m = messages[messages.length - 1 - i];
                        return MessageBubble(
                          message: m,
                          isPending: vm.isSending && i == 0 && m.text.isEmpty,
                        );
                      },
                    ),
            ),
            if (vm.error != null)
              Container(
                width: double.infinity,
                color: scheme.errorContainer,
                padding: const EdgeInsets.all(8),
                child: Text(
                  vm.error!,
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            MessageInput(enabled: !vm.isSending, onSend: vm.sendMessage),
          ],
        ),
      ),
    );
  }
}
