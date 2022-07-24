import 'package:flutter/material.dart';

import 'main.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Align(
      alignment: const AlignmentDirectional(0, 0),
      child: Container(
          width: 200,
          height: 200,
          alignment: Alignment.center,
          child: Column(
            children: [
              TextField(
                  controller: name,
                  onChanged: (_) {
                    setState(() {});
                  }),
              TextField(
                  controller: password,
                  onChanged: (_) {
                    setState(() {});
                  }),
              Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    onPressed: (name.text.isEmpty || password.text.isEmpty)
                        ? null
                        : () {
                            MPWContainer.of(context)
                                ?.login(name.text, password.text);
                          },
                    child: const Text("Login"),
                  )),
            ],
          )),
    ));
  }
}
