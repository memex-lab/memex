import 'dart:convert';
import 'dart:io';

/// Script the model's decisions. Memex still owns the queue, tool execution,
/// card and attachment persistence, and the subsequent timeline query.
class JournalModelFixture {
  JournalModelFixture(this.factId, this.message, this.filename);

  final String factId;
  final String message;
  final String filename;
  final calls = <String>[];
  final toolResults = <String>[];

  Future<void> respond(HttpRequest request) async {
    final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
    final messages = body['messages'] as List;
    final last = messages.last;
    if (last['role'] == 'tool') toolResults.add(last['content'].toString());
    final history = jsonEncode(messages);
    final tools = (body['tools'] as List? ?? [])
        .map((tool) => tool['function']['name'])
        .toSet();
    String? name;
    Map<String, dynamic> arguments = {};
    if (history.contains(message) &&
        history.contains(filename) &&
        !calls.contains('save_timeline_card')) {
      if (tools.contains('save_timeline_card') && history.contains(factId)) {
        name = 'save_timeline_card';
        arguments = {
          'fact_id': factId,
          'title': 'River walk',
          'fact': message,
          'assets': ['fs://$filename'],
          'ui_configs': [
            {
              'template_id': 'article',
              'data': {'body': message}
            }
          ],
          'tags': [
            {'name': 'Trip'}
          ],
        };
      } else if (tools.contains('activate_skills') &&
          !calls.contains('activate_skills')) {
        name = 'activate_skills';
        arguments = {
          'skill_names': ['manage_timeline_card']
        };
      }
    }
    if (name != null) calls.add(name);
    final streaming = body['stream'] == true;
    final reply = {
      'role': 'assistant',
      if (name == null) 'content': 'Done.',
      if (name != null)
        'tool_calls': [
          {
            if (streaming) 'index': 0,
            'id': 'call_${calls.length}',
            'type': 'function',
            'function': {'name': name, 'arguments': jsonEncode(arguments)},
          }
        ],
    };
    final response = {
      'id': 'journal-response',
      'model': 'journal-test',
      'choices': [
        {
          'index': 0,
          if (streaming) 'delta': reply else 'message': reply,
          'finish_reason': name == null ? 'stop' : 'tool_calls',
        }
      ],
    };
    if (streaming) {
      request.response.headers.contentType =
          ContentType('text', 'event-stream');
      request.response
          .write('data: ${jsonEncode(response)}\n\ndata: [DONE]\n\n');
    } else {
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(response));
    }
    await request.response.close();
  }
}

/// Flutter's widget binding normally synthesizes HTTP 400 responses. Permit
/// a real socket only to the ephemeral model server used by this test.
class JournalHttpOverrides extends HttpOverrides {
  JournalHttpOverrides(this.port);
  final int port;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (_) => 'DIRECT';
    client.connectionFactory = (uri, proxyHost, proxyPort) {
      if (uri.host != '127.0.0.1' || uri.port != port) {
        throw StateError('Unexpected network destination in journal test');
      }
      return Socket.startConnect(InternetAddress.loopbackIPv4, port);
    };
    return client;
  }
}
