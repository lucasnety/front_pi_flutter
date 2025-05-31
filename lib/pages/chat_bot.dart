import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({Key? key}) : super(key: key);

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  final String _apiKey = dotenv.env['OPENAI_API_KEY']!;

  final Map<String, String> _systemMessage = {
    'role': 'system',
    'content': '''
Você é um atendente virtual da empresa Líder Gesso, especializada em serviços como gesso liso, drywall, molduras e reparos. Sua função é ajudar clientes a simular orçamentos com base na metragem informada e nos preços fixos listados abaixo. Sempre seja educado, objetivo e prestativo. Nunca diga que é um modelo de IA.

Preços padrão:
• Gesso liso (parede rebocada): R\$ 18,00/m²  
• Gesso liso (alvenaria 25): R\$ 25,00/m²  
• Gesso liso (chapisco): R\$ 30,00/m²  
• Drywall no teto: R\$ 75,00/m²  
• Parede de drywall: R\$ 120,00/m²  
• Moldura 7cm: R\$ 10,00/m  
• Moldura 10cm: R\$ 13,00/m  
• Moldura 12cm: R\$ 13,00/m

Responda conforme esse contexto.
''',
  };

  @override
  void initState() {
    super.initState();
    _addInitialAssistantMessage();
  }

  void _addInitialAssistantMessage() {
    _messages.add({
      'role': 'assistant',
      'text':
          'Olá, sou o assistente virtual da Líder Gesso, como posso ajudar?',
    });
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _controller.clear();
      _isTyping = true;
    });

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4-1106-preview',
        'messages': [
          _systemMessage,
          ..._messages.map(
            (msg) => {'role': msg['role'], 'content': msg['text']},
          ),
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final reply = data['choices'][0]['message']['content'];
      setState(() {
        _messages.add({'role': 'assistant', 'text': reply});
        _isTyping = false;
      });
    } else {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'Erro: ${response.statusCode} - ${response.body}',
        });
        _isTyping = false;
      });
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: SelectableText(
          message['text']!,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
        child: TypingIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atendente Virtual - Líder Gesso')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _dotCount = StepTween(
      begin: 1,
      end: 3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotCount,
      builder: (context, child) {
        String dots = '.' * _dotCount.value;
        return Text(
          dots,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
