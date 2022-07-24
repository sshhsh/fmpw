import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fmpw/login.dart';
import 'package:fmpw/sites.dart';

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

  Future<String> generate(SiteModel siteModel) async {
    if (siteModel.site.isEmpty) {
      return "";
    }
    return mpw!.generate(siteModel.site, counter: siteModel.count, template: siteModel.template);
  }

  @override
  Widget build(BuildContext context) {
    return MPWContainer(
      model: this,
      login: login,
      logout: logout,
      generate: generate,
      child: mpw == null
          ? const Login()
          : const Sites(),
    );
  }
}

class MPWContainer extends InheritedWidget {
  static MPWContainer? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MPWContainer>();
  final MyAppState model;
  final void Function(String, String) login;
  final void Function() logout;
  final Future<String> Function(SiteModel) generate;

  const MPWContainer({
    Key? key,
    required this.model,
    required Widget child,
    required this.login,
    required this.logout,
    required this.generate,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant MPWContainer oldWidget) {
    return model != oldWidget.model;
  }
}
