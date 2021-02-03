import 'package:flutter/material.dart';

void main() => runApp(Sign_up());

class Sign_up extends StatefulWidget {
  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<Sign_up> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: Text(
            '회원가입',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal
            ),
          ),
        ),
      ),

      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    icon: Icon(Icons.account_circle),
                    labelText: "아이디를 입력해주세요.",
                    border: OutlineInputBorder(),
                    hintText: '2자 - 8자 이내로 입력해주세요.'
                ),
                validator: (String value) {
                  if (value.isEmpty) {
                    return "아이디를 입력해주세요";
                  }
                  return null;
                },
              ),

              /*Container(
                margin: const EdgeInsets.only(top: 16.0),
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  onPressed: () {
                    //클릭시 검증
                  },
                  child: Text(
                      '아이디 중복체크'
                  ),
                ),
              ),*/

              SizedBox(
                height: 16.0,
              ),

              TextFormField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                    icon: Icon(Icons.vpn_key),
                    labelText: "비밀번호를 입력해주세요.",
                    border: OutlineInputBorder(),
                    hintText: '4자 이상으로 입력해주세요.'
                ),
                validator: (String value) {
                  if (value.isEmpty) {
                    return "비밀번호를 입력해주세요.";
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16.0,
              ),
              TextFormField(
                obscureText: true, // 비밀번호를 적을때 안보이도록
                decoration: InputDecoration(
                    icon: Icon(Icons.vpn_key),
                    labelText: "비밀번호를 한 번 더 입력해주세요.",
                    border: OutlineInputBorder(),
                    hintText: ''
                ),
                validator: (String value) {
                  if (value != _passwordController) {
                    return "비밀번호가 일치하지 않습니다.";
                  }
                  return null;
                },
              ),
              Container(
                margin: const EdgeInsets.only(top: 16.0),
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  onPressed: () {

                    // _register();
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => MyToDoApp())
                    // );

                    Navigator.pop(context);
                  },
                  child: Text('회원가입'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


//   // 회원가입 메소드
//   void _register() async {
//     final AuthResult result = await FirebaseAuth.instance
//         .createUserWithEmailAndPassword(
//         email: _emailController.text, password: _passwordController.text);
//     final FirebaseUser user = result.user;
//
//     if (user == null) {
//       final snacBar = SnackBar(
//         content: Text("Please try again later"),
//       );
//       Scaffold.of(context).showSnackBar(snacBar);
//     }
//   }
}