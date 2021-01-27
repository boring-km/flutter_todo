import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todo/signup.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Do you want to exit the app?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("NO"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  child: Text("yes"),
                  onPressed: () => SystemNavigator.pop(),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              SizedBox(height: 80.0),
              Column(
                children: <Widget>[
                  Image.asset(
                    'assets/todo.png',
                    width: 50,
                  ),
                  SizedBox(height: 16.0),
                  Text('To Do'),
                ],
              ),
              SizedBox(height: 80.0),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  filled: true,
                  labelText: 'Username',
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  filled: true,
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: Text('Sign Up'),
                    onPressed: () {
                      // _usernameController.clear();
                      // _passwordController.clear();
                      Navigator.of(context, rootNavigator: true).push(
                        CupertinoPageRoute<void>(
                          fullscreenDialog: false,
                          builder: (BuildContext context) => Sign_up(),
                        ),
                      );
                    },
                  ),
                  RaisedButton(
                    child: Text('LOGIN'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
