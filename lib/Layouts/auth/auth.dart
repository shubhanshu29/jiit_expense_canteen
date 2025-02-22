import 'package:flutter/material.dart';
import 'package:jiitexpense/Layouts/auth/login.dart';


// ignore: must_be_immutable
class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
  bool isLogin = true;
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isLogin ? Text('Login') : Text('Register'),
        actions: <Widget>[
          FlatButton(
            child: widget.isLogin ? Text('Login') : Text('Register'),
            onPressed: () {
              setState(() {
                widget.isLogin = !widget.isLogin;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: widget.isLogin ? Login() : Login(),
      ),
    );
  }
}
