import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart'
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
  bool _loginToken = false;

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
  
  void _idCheck() async {
    final snapshot = await Firestore.instance
        .collection('todo')
        .document(_usernameController.text)
        .get();

    if (snapshot.exists) {
      print('이미 사용 중');
      showToast('이미 사용 중인 아이디에요.');
    } else {
      _signUp();
      setState(() {
        _visible = !_visible;
      });
      clear();
      showToast('회원가입이 완료되었어요.');
    }
  }

  void _signUp() {
    Firestore.instance
        .collection('todo')
        .document(_usernameController.text)
        .setData({'pw':_passwordController.text});
  }


  void _login(String id, String pw) async {
    DocumentSnapshot snapshot = await Firestore.instance
        .collection('todo')
        .document(id)
        .get();
    String savedPW = snapshot['pw'];
    if (pw == savedPW) {
      print('일치함');
      showToast(id + '님, 안녕하세요!');
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
                        onPressed: () async {
                          if (_usernameController.text.isEmpty) {
                            showToast('아이디를 입력해주세요.');
                          } else if (_passwordController.text.isEmpty) {
                            showToast('비밀번호를 입력해주세요.');
                          } else {
                            await _login(_usernameController.text, _passwordController.text);
                            if (_loginToken) {
                              String name;
                              name = _usernameController.text;
                              Navigator.push(context, CupertinoPageRoute(builder: (context) => TodoMain(name)));
                            }
                          }
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
                          if (_usernameController.text.isEmpty || _passwordController.text.isEmpty || _passwordConfirmController.text.isEmpty) {
                            showToast('빈 칸 없이 입력해주세요.');
                          } else {
                            if (_passwordController.text == _passwordConfirmController.text) {
                              _idCheck();
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

  void clear() {
    _usernameController.clear();
    _passwordController.clear();
    _passwordConfirmController.clear();
  }
}