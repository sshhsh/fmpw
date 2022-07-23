import 'package:flutter/material.dart';
import 'package:fmpw/mpw.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

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
              const TextField(),
              const TextField(),
              Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      getKey();
                    },
                    child: const Text("Login"),
                  )),
            ],
          )),
    ));
  }
}
