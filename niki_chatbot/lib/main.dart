import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'secret.dart' as secret;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:developer';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nike AI Chatbot',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatScreen(title: 'Nike AI Chatbot'),
    );
  }
}


class ChatScreen extends StatefulWidget {
  @override
  const ChatScreen({super.key, required this.title});
  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  List<Content> history = [];
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  bool _loading = false;
  static const _apiKey = secret.api_key;

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro', apiKey: _apiKey,
    );
    _chat = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nike AI Chatbot'),
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 90),
            itemCount: history.reversed.length,
            controller: _scrollController,
            reverse: true,
            itemBuilder: (context, index){
              var content = history.reversed.toList()[index];
              var text = content.parts
                  .whereType<TextPart>()
                  .map<String>((e) => e.text)
                  .join('');
              return ListTile(
                title: Text(text),
              );
              //return MessageTile(
              //  sendByMe: content.role == 'user',
              //  message: text,

              //)
            },
            separatorBuilder: (context, index){
              return const SizedBox(height: 15,);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200))
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: TextField(
                        cursorColor: MyColors.primaryColor,
                        controller: _textController,
                        autofocus: true,
                        focusNode: _textFieldFocus,
                        decoration: InputDecoration(
                            hintText: 'Ask me anything...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true, fillColor: Colors.grey.shade200,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10)
                            )
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        history.add(Content('user', [TextPart(_textController.text)]));
                      });
                      _sendChatMessage(_textController.text, history.length);
                    },
                    child: Container(
                      width: 50, height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: MyColors.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(offset: const Offset(1,1), blurRadius: 3, spreadRadius: 3, color: Colors.black.withOpacity(0.05))
                          ]
                      ),
                      child: _loading
                          ? const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: CircularProgressIndicator.adaptive(
                                                    backgroundColor: Colors.white, ),
                          )
                          : const Icon(Icons.send_rounded, color: Colors.white,),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendChatMessage(String message, int historyIndex) async {
    setState(() {
      _loading = true;
      _textController.clear();
      _textFieldFocus.unfocus();
      _scrollDown();
    });

    List<Part> parts = [];

    try {
      var response = await preguntar(message);
      log(response.toString());
      if (response.statusCode == 200) {

        setState(() {
            _loading = false;
            parts.add(TextPart(jsonDecode(response.body)['respuesta']));
            if((history.length - 1) == historyIndex){
              history.removeAt(historyIndex);
            }
            history.insert(historyIndex, Content('model', parts));

          });
    // If the server did return a 200 OK response,
    // then parse the JSON.
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
      


    } catch (e, t) {
      print(e);
      print(t);
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
  
}

class MessageTile {
  
}

class MyColors {
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.green;
  static const Color accentColor = Colors.orange;
}



Future<http.Response> preguntar(String message) {
  return http.post(
    Uri.parse('http://10.0.2.2:8000/preguntar'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'pregunta': message,
    }),
  );
}
