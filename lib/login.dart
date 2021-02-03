import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todo/main.dart';

void main() {
  runApp(MyToDoApp());
}

class MyToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter To Do',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      initialRoute: '/login',
      onGenerateRoute: _getRoute,
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void> (
      settings : settings,
      builder: (BuildContext context) => LoginPage(),
      fullscreenDialog: true,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _visible = true;

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
                  labelText: 'ID',
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
              SizedBox(height: 12.0),
              AnimatedOpacity(
                opacity: _visible ? 0.0 : 1.0,
                duration: Duration(milliseconds: 500),
                child: Visibility(
                  visible: !_visible,
                  child: TextField(
                    controller: _passwordConfirmController,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Password Confirm',
                    ),
                    obscureText: true,
                  ),


                ),
              ),
              AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Visibility(
                  visible: _visible,
                  child: ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: Text('Sign Up'),
                        onPressed: () {
                          _usernameController.clear();
                          _passwordController.clear();
                          _passwordConfirmController.clear();
                          setState(() {
                            _visible = !_visible;
                          });
                        },
                      ),
                      RaisedButton(
                        child: Text('LOGIN'),
                        onPressed: () {
                          String name;
                          if(_usernameController.text.isNotEmpty)
                            name = _usernameController.text;
                          else
                            name = "test";
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TodoMain(name)));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: _visible ? 0.0 : 1.0,
                duration: Duration(milliseconds: 500),
                child: Visibility(
                  visible: !_visible,
                  child: ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          _usernameController.clear();
                          _passwordController.clear();
                          _passwordConfirmController.clear();
                          setState(() {
                            _visible = !_visible;
                          });
                        },
                      ),
                      RaisedButton(
                        child: Text('Sign Up'),
                        onPressed: () {
                          _usernameController.clear();
                          _passwordController.clear();
                          _passwordConfirmController.clear();
                          setState(() {
                            _visible = !_visible;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
