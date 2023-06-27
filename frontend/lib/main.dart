import 'package:flutter/material.dart';
import 'package:frontend/tools/chat-bot/chatscreen.dart';
import 'package:frontend/tools/faq.dart';
import 'package:frontend/tools/splashScreen.dart';
import 'package:frontend/tools/map/mapScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home:  SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    FAQPage(),
    ChatScreen(),
    MapScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('4Cops'),
        centerTitle: true
      ),*/
      body: _pages[_currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'FAQ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
        ],
      ),
    );
  }
}
