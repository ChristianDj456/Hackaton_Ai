class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
  }
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
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
        // Chat history list
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 90),
          itemCount: history.reversed.length,
          controller: _scrollController,
          reverse: true,
          itemBuilder: (context, index) {
         
            // return message container

          },
          separatorBuilder: (context, index) => const SizedBox(height: 15),
        ),

        // User input and Send button
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: size.width,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    //_textController.text = message; // User input
                    //history.insert(historyIndex, Content('user', [TextPart(message)])); // Add temporary user message
                    _sendChatMessage(_textController.text, history.length);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: MyColors.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(1, 1),
                          blurRadius: 3,
                          spreadRadius: 3,
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ],
                    ),
                    child: _loading
                        ? const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  void _sendChatMessage(String text, int length) {

  }
 }
