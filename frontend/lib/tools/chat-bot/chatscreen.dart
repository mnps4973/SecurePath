import 'package:frontend/tools/faq.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';


import 'chatmessage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  final stt.SpeechToText _speech = stt.SpeechToText();
  String _text = "Press the button and start speaking";

  bool _isListening = false;

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    ChatMessage message = ChatMessage(
      text: _controller.text,
      sender: "Cop",
    );

    final translation = await GoogleTranslator().translate(
      _controller.text,
      from: 'auto',
      to: 'pt',
    );

    ChatMessage translatedMessage = ChatMessage(
      text: translation.text,
      sender: "Translate",
    );

    ChatMessage recommendationMessage = ChatMessage(
      text: _controller.text,
      sender: "Recommendation",
    );

    setState(() {
      _messages.insert(0, message);
      _messages.insert(0, translatedMessage);
      _messages.insert(0, recommendationMessage);
    });

    _controller.clear();
  }


  void _sendVoiceMessage() async {
    if(!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onError: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
            onResult: (val) async {
              _text = val.recognizedWords;
            },
        );
      }
    } else {
      if (_text == ""){
        setState(() {
          _isListening = false;
          _speech.stop();
        });
        return;
      }
      final originalMessage = ChatMessage(
        text: _text,
        sender: "Cop",
      );

      final translation = await GoogleTranslator().translate(
        _text,
        from: 'auto',
        to: 'pt',
      );
      ChatMessage message = ChatMessage(
        text: translation.text,
        sender: "Translate",
      );

      ChatMessage recommendationMessage = ChatMessage(
        text: _text,
        sender: "Recommendation",
      );

      setState(() {
        _messages.insert(0, originalMessage);
        _messages.insert(0, message);
        _messages.insert(0, recommendationMessage);
        _isListening = false;
      });
      _speech.stop();
    }

  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.indigo, width: 2.0),
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: TextField(
              controller: _controller,
              onSubmitted: (value) => _sendMessage(),
              decoration: const InputDecoration.collapsed(hintText: "Type"),
            ),
          ),
        ),
        ButtonBar(
          children: [
            IconButton(
              icon: const Icon(Icons.send),
              color: Colors.indigo,
              onPressed: () {
                _sendMessage();
              },
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000), // Adjust duration as needed
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: _isListening
                    ? [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.5),
                    blurRadius: 10.0,
                    spreadRadius: 3.0,
                  ),
                ]
                    : [],
              ),
              child: IconButton(
                icon: _isListening
                    ? const Icon(Icons.stop)
                    : const Icon(Icons.mic),
                color: Colors.indigo,
                onPressed: () {
                  _sendVoiceMessage();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }


  void navigateToFaQPageWithQuery(BuildContext context, String query) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FAQPage(initialQuery: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {

                      return _messages[index];
                    },
                  )),
              const Divider(
                height: 1.0,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: _buildTextComposer(),
              )
            ],
          ),
        ));
  }
}