import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

class AiServiceException implements Exception {
  AiServiceException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Contrato da IA. A UI e o ViewModel só conhecem esta interface,
/// então trocar de provedor (ou de simulado para real) não afeta mais nada.
/// Devolve um Stream para já suportar respostas em streaming.
abstract class AiService {
  Stream<String> streamReply(List<ChatMessage> history);
}

/// Respostas simuladas, para desenvolver a interface sem backend.
class FakeAiService implements AiService {
  const FakeAiService({this.delay = const Duration(milliseconds: 60)});

  final Duration delay;

  @override
  Stream<String> streamReply(List<ChatMessage> history) async* {
    final last = history.isEmpty ? '' : history.last.text;
    final words = 'Você disse: "$last". Esta é uma resposta simulada do Ariston.'
        .split(' ');
    for (final word in words) {
      await Future<void>.delayed(delay);
      yield '$word ';
    }
  }
}

/// Fala com o SEU backend/proxy (que guarda a chave da API de IA).
/// Contrato esperado:
///   POST endpoint
///   body:  {"messages": [{"role": "user"|"assistant", "content": "..."}]}
///   reply: {"reply": "texto"}
/// O ID token do Firebase vai em Authorization: Bearer, para o proxy
/// verificar quem está chamando.
class HttpAiService implements AiService {
  HttpAiService({
    required this.endpoint,
    this.tokenProvider,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final Uri endpoint;
  final Future<String?> Function()? tokenProvider;
  final http.Client _client;

  @override
  Stream<String> streamReply(List<ChatMessage> history) async* {
    final token = await tokenProvider?.call();
    final response = await _client
        .post(
          endpoint,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'messages': [
              for (final m in history) {'role': m.role.name, 'content': m.text},
            ],
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw AiServiceException('Erro ${response.statusCode} do servidor de IA.');
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    yield (data['reply'] as String?) ?? '';
  }
}
