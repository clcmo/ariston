import 'dart:convert';

import 'package:ariston/data/models/chat_message.dart';
import 'package:ariston/data/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('sends the Firebase token and reads the provider reply', () async {
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer firebase-id-token');
      expect(
        jsonDecode(request.body),
        {
          'messages': [
            {'role': 'user', 'content': 'Oi, Ariston!'},
          ],
        },
      );
      return http.Response.bytes(
        utf8.encode(jsonEncode({'reply': 'Olá! Como posso ajudar?'})),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final service = HttpAiService(
      endpoint: Uri.parse('https://example.com/chat'),
      tokenProvider: () async => 'firebase-id-token',
      client: client,
    );

    final reply = await service.streamReply([
      ChatMessage(
        id: '1',
        role: ChatRole.user,
        text: 'Oi, Ariston!',
        createdAt: DateTime.utc(2026),
      ),
    ]).join();

    expect(reply, 'Olá! Como posso ajudar?');
  });
}
