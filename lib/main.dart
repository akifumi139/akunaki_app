import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'layouts/menu.dart';

import 'pages/login_page.dart';
import 'pages/create_post.dart';

import 'pages/home_page.dart';
import 'pages/pins_page.dart';
import 'pages/rails_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TopPage(),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Color(0xFFB3DBD6),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF0C4842),
          secondary: const Color(0xFF0C4842),
          tertiary: Colors.teal.shade700,
        ),
      ),
      routes: {
        '/home': (context) => const HomePage(),
        '/post': (context) => const CreatePost(),
        '/pins': (context) => const PinsPage(),
        '/rails': (context) => const RailsPage(),
      },
    );
  }
}

class TopPage extends StatefulWidget {
  const TopPage({super.key});

  @override
  TopPageState createState() => TopPageState();
}

class TopPageState extends State<TopPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const PinsPage(),
    const RailsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('エラーが発生しました'));
        }

        if (snapshot.data == true) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 110,
              title: Menu(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
            body: _pages[_selectedIndex],
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
