import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:flutter_dialogflow/utils/language.dart';

void main() {
  runApp(MaterialApp(
    home: ChatBot(),
  ));
}

class ChatBot extends StatefulWidget {
  // ChatBot({Key? key}) : super(key: key);

  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  Future<void> _queryDialogFlow(String query) async {
    // print(query);
    _textController.clear();

    AuthGoogle authGoogle = await AuthGoogle(
            fileJson: "assets/farm-buddy-chatbot-ncqv-d2734ea11952.json")
        .build();
    Dialogflow dialogflow =
        Dialogflow(authGoogle: authGoogle, language: Language.english);
    AIResponse response = await dialogflow.detectIntent(query);
    // print(response.getListMessage());
    if (response != null) {
      // Dialogflow returned a response, create and display the bot message
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              text: response.getListMessage()[0]["text"]["text"][0].toString(),
              name: "Bot",
              type: false,
              context: context,
            ));
      });
    } else {
      // Dialogflow did not return a response
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              text: "No response from Dialogflow!!",
              name: "Bot",
              type: false,
              context: context,
            ));
      });
    }
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: text,
      name: "You",
      type: true,
      context: context,
    );
    setState(() {
      _messages.insert(0, message);
    });
    _queryDialogFlow(text);
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                    InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Chatbot'),
        centerTitle: true,
        backgroundColor: Color(0xFFFF8000),
      ),
      body: Column(children: <Widget>[
        Flexible(
          child: ListView.builder(
            padding: EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) => _messages[index],
            itemCount: _messages.length,
          ),
        ),
        Divider(height: 1.0),
        Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor),
          child: _buildTextComposer(),
        ),
      ]),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage(
      {required this.text,
      required this.name,
      required this.type,
      required this.context});

  final String text;
  final String name;
  final bool type;
  final BuildContext context;

  List<Widget> messageChildren() {
    return <Widget>[
      Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: CircleAvatar(child: Text(name[0])),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(name, style: Theme.of(context).textTheme.titleMedium),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(text),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            type ? messageChildren() : messageChildren().reversed.toList(),
      ),
    );
  }
}
