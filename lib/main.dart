import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _todoTextEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Flexible(
                child: TextFormField(
                  controller: _todoTextEditController,
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return '할 일을 입력하세요.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '할 일을 입력하세요.',
                  ),
                  onChanged: (text) {
                    print(text);
                  },
                ),
              ),
              Container(
                child: IconButton(
                  color: Colors.blue,
                  icon: Icon(Icons.send),

                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
