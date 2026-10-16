import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../data/models/chat_message.dart';
import '../../data/repositories/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({required ChatRepository repository, required String userId})
      : _repository = repository,
        _userId = userId;

  final ChatRepository _repository;
  final String _userId;

  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  String? _error;
  bool _disposed = false;

  UnmodifiableListView<ChatMessage> get messages =>
      UnmodifiableListView(_messages);
  bool get isSending => _isSending;
  String? get error => _error;

  Future<void> load() async {
    final history = await _repository.loadHistory(_userId);
    if (_disposed) return;
    _messages
      ..clear()
      ..addAll(history);
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    _error = null;
    final now = DateTime.now();
    _messages.add(ChatMessage(
      id: '${now.microsecondsSinceEpoch}-u',
      role: ChatRole.user,
      text: trimmed,
      createdAt: now,
    ));
    final history = List<ChatMessage>.of(_messages);

    final placeholder = ChatMessage(
      id: '${now.microsecondsSinceEpoch}-a',
      role: ChatRole.assistant,
      text: '',
      createdAt: now,
    );
    _messages.add(placeholder);
    _isSending = true;
    _notify();

    try {
      final buffer = StringBuffer();
      await for (final chunk in _repository.reply(history)) {
        buffer.write(chunk);
        _messages[_messages.length - 1] =
            placeholder.copyWith(text: buffer.toString());
        _notify();
      }
    } catch (_) {
      _error = 'Não foi possível obter a resposta. Tente novamente.';
      if (_messages.isNotEmpty && _messages.last.text.isEmpty) {
        _messages.removeLast();
      }
    } finally {
      _isSending = false;
      await _repository.saveHistory(_userId, _messages);
      _notify();
    }
  }

  Future<void> clearChat() async {
    _messages.clear();
    _error = null;
    await _repository.clearHistory(_userId);
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
