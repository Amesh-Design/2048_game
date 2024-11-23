import 'package:flutter/material.dart';
import 'package:flutter_sample/loginscreen.dart';
import 'package:flutter_sample/boardwidget.dart'; // Import BoardWidget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048 Game Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(), // Login screen is the home screen
      routes: {
        '/board': (context) => const BoardWidget(), // Define route to BoardWidget
      },
    );
  }
}
