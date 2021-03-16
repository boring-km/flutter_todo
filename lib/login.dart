import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:flutter_todo/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_todo/FireBase.dart';
import 'package:flutter_todo/sharedPreferences.dart';


void main() {
  runApp(MyToDoApp());
}

class MyToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter To Do',
      theme: ThemeData(
        fontFamily: 'gyeonggi',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      onGenerateRoute: _getRoute,
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
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
  bool _loginToken = false;
  SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadId();
  }

  _loadId() async {
    _prefs = await SharedPref.sharedPref();
    if (_prefs.getString('id') != null) {
      setState(() {
        _usernameController.text = (_prefs.getString('id') ?? null);
        _passwordController.text = (_prefs.getString('pw') ?? null);
        print(_usernameController.text + _passwordController.text);
        _login(context);
      });
    } else {
      print(_usernameController.text + _passwordController.text);
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("To Do를 종료하실건가요?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("아니오"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  child: Text("네"),
                  onPressed: () => SystemNavigator.pop(),
                )
              ],
            ));
  }

  void _idCheck(id, pw) async {
    final snapshot = await FireBaseDAO.idCheck(id);

    if (snapshot.exists) {
      print('이미 사용 중');
      showToast('이미 사용 중인 아이디에요.');
    } else {
      FireBaseDAO.signUp(id, pw);
      setState(() {
        _visible = !_visible;
      });
      clear();
      showToast('회원가입이 완료되었어요.');
    }
  }

  void _loginCheck(String id, String pw) async {
    DocumentSnapshot snapshot = await FireBaseDAO.loginIdCheck(id);
    String savedPW = snapshot['pw'];
    if (pw == savedPW) {
      print('일치함');
      showToast(id + '님, 안녕하세요!');
      _prefs.setString('id', id);
      _prefs.setString('pw', pw);
      _loginToken = true;
    } else {
      print('일치하지 않음');
      showToast('아이디와 비밀번호를 확인해주세요.');
      _loginToken = false;
    }
  }



  void showToast(String msg) {
    Toast.show(msg, context, duration: 2);
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
                          clear();
                          setState(() {
                            _visible = !_visible;
                          });
                        },
                      ),
                      RaisedButton(
                        child: Text('LOGIN'),
                        onPressed: () async {
                          await _login(context);
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
                          clear();
                          setState(() {
                            _visible = !_visible;
                          });
                        },
                      ),
                      RaisedButton(
                        child: Text('Sign Up'),
                        onPressed: () {
                          if (_usernameController.text.isEmpty ||
                              _passwordController.text.isEmpty ||
                              _passwordConfirmController.text.isEmpty) {
                            showToast('빈 칸 없이 입력해주세요.');
                          } else {
                            if (_passwordController.text ==
                                _passwordConfirmController.text) {
                              _idCheck(_usernameController.text, _passwordController.text);
                            } else {
                              showToast('비밀번호가 일치하지 않아요.');
                            }
                          }
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

  Future _login(BuildContext context) async {
    if (_usernameController.text.isEmpty) {
      showToast('아이디를 입력해주세요.');
    } else if (_passwordController.text.isEmpty) {
      showToast('비밀번호를 입력해주세요.');
    } else {
      await _loginCheck(_usernameController.text,
          _passwordController.text);
      if (_loginToken) {
        String name;
        name = _usernameController.text;
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => TodoMain(name)));
      }
    }
  }

  void clear() {
    _usernameController.clear();
    _passwordController.clear();
    _passwordConfirmController.clear();
  }
}
