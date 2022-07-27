import 'package:flutter/material.dart';

import 'login.dart';
import 'model.dart';
import 'mpw.dart';
import 'sites.dart';

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
  UserSites? sites;
  void login(String name, String password) {
    setState(() {
      mpw = MPW(name, password);
      sites = UserSites(name, {});
    });
  }

  void logout() {
    setState(() {
      mpw = null;
      sites = null;
    });
  }

  Future<String> generate(SiteModel siteModel) async {
    if (siteModel.site.isEmpty) {
      return "";
    }
    print(siteModel.site);
    return mpw!.generate(siteModel.site,
        counter: siteModel.count, template: siteModel.template);
  }

  void addSite(SiteModel siteModel) {
    setState(() {
      sites?.sites.remove(siteModel.site);
      sites?.sites[siteModel.site] = siteModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MPWContainer(
      model: this,
      login: login,
      logout: logout,
      generate: generate,
      addSite: addSite,
      child: mpw == null ? const Login() : const Sites(),
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
  final Function(SiteModel) addSite;

  const MPWContainer({
    Key? key,
    required this.model,
    required Widget child,
    required this.login,
    required this.logout,
    required this.generate,
    required this.addSite,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant MPWContainer oldWidget) {
    return model != oldWidget.model;
  }
}
