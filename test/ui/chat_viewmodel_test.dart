import 'package:ariston/data/models/chat_message.dart';
import 'package:ariston/data/repositories/chat_repository.dart';
import 'package:ariston/data/services/ai_service.dart';
import 'package:ariston/data/services/chat_history_store.dart';
import 'package:ariston/ui/chat/chat_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ChatViewModel vm;

  setUp(() {
    vm = ChatViewModel(
      repository: ChatRepository(
        ai: const FakeAiService(delay: Duration.zero),
        store: InMemoryChatHistoryStore(),
      ),
      userId: 'u1',
    );
  });

  test('ignora mensagens vazias', () async {
    await vm.sendMessage('   ');
    expect(vm.messages, isEmpty);
  });

  test('envia a mensagem e recebe a resposta', () async {
    await vm.sendMessage('Oi');
    expect(vm.messages.length, 2);
    expect(vm.messages.first.role, ChatRole.user);
    expect(vm.messages.last.role, ChatRole.assistant);
    expect(vm.messages.last.text, isNotEmpty);
    expect(vm.isSending, isFalse);
  });

  test('clearChat esvazia a conversa', () async {
    await vm.sendMessage('Oi');
    await vm.clearChat();
    expect(vm.messages, isEmpty);
  });
}
