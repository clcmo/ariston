import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/chat_history_store.dart';

/// Única porta de entrada do ViewModel para dados do chat:
/// junta a IA (remota) com o histórico (local).
class ChatRepository {
  ChatRepository({required AiService ai, required ChatHistoryStore store})
      : _ai = ai,
        _store = store;

  final AiService _ai;
  final ChatHistoryStore _store;

  Stream<String> reply(List<ChatMessage> history) => _ai.streamReply(history);

  Future<List<ChatMessage>> loadHistory(String userId) => _store.load(userId);

  Future<void> saveHistory(String userId, List<ChatMessage> messages) =>
      _store.save(userId, messages);

  Future<void> clearHistory(String userId) => _store.clear(userId);
}
