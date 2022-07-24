import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fmpw/login.dart';

import 'mpw.dart';

void main() {
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyApp(),
    ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  MPW? mpw;
  void login(String name, String password) {
    setState(() {
    mpw = MPW(name, password);
    });
  }

  void logout() {
    setState(() {
    mpw = null;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MPWContainer(
        model: this,
        login: login,
        child: mpw == null ? const Login() : FutureBuilder(future: mpw!.key, builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
          print(mpw);
          if (snapshot.hasData) {
            return const Text("logged");
          } else {
            return const Text("Logging");
          }
        }),
      );
  }
}

class MPWContainer extends InheritedWidget {
  static MPWContainer? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MPWContainer>();
  final MyAppState model;
  final void Function(String name, String password) login;

  const MPWContainer({
    Key? key,
    required this.model,
    required Widget child,
    required this.login,
  }) : super(key: key, child: child);
  
  @override
  bool updateShouldNotify(covariant MPWContainer oldWidget) {
    return model != oldWidget.model;
  }
}