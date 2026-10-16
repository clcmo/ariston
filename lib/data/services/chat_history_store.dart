import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/chat_message.dart';

abstract class ChatHistoryStore {
  Future<List<ChatMessage>> load(String userId);
  Future<void> save(String userId, List<ChatMessage> messages);
  Future<void> clear(String userId);
}

class HiveChatHistoryStore implements ChatHistoryStore {
  HiveChatHistoryStore(this._box);

  final Box<String> _box;

  @override
  Future<List<ChatMessage>> load(String userId) async {
    final raw = _box.get(userId);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return [
      for (final item in list)
        ChatMessage.fromJson(item as Map<String, dynamic>),
    ];
  }

  @override
  Future<void> save(String userId, List<ChatMessage> messages) =>
      _box.put(userId, jsonEncode([for (final m in messages) m.toJson()]));

  @override
  Future<void> clear(String userId) => _box.delete(userId);
}

/// Usado nos testes.
class InMemoryChatHistoryStore implements ChatHistoryStore {
  final Map<String, List<ChatMessage>> _data = {};

  @override
  Future<List<ChatMessage>> load(String userId) async =>
      List.of(_data[userId] ?? const []);

  @override
  Future<void> save(String userId, List<ChatMessage> messages) async =>
      _data[userId] = List.of(messages);

  @override
  Future<void> clear(String userId) async => _data.remove(userId);
}
