import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/todo.dart';

const String _name = "kangmin";

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
      home: MyToDo(title: 'To Do'),
    );
  }
}

class MyToDo extends StatefulWidget {
  MyToDo({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyToDoState createState() => _MyToDoState();
}

class _MyToDoState extends State<MyToDo> with TickerProviderStateMixin {
  final _todoTextEditController = TextEditingController();
  final List<TodoWidget> _todoList = <TodoWidget>[];
  List<Todo> _initList = <Todo>[];
  bool isFirst = true;
  DateTime selectedDate = DateTime.now();
  bool _isComposing = false;
  int rank = -1;

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  _MyToDoState() {
    // TODO 처음 로딩 시 불러올 수 있도록 수정 필요함
    Stream<QuerySnapshot> stream = Firestore.instance
        .collection('todo')
        .document(_name)
        .collection(getToday()).snapshots();
    stream.forEach((qs) {
      qs.documents.forEach((doc) {
        _initList.add(Todo(doc['rank'], doc['data'], doc['isDone']));
      });
    });
    _initList.sort((a,b) => a.rank.compareTo(b.rank));
    for(var i=0, len = _initList.length; i < len; i++) {
      var widget = TodoWidget(
        text: _initList[i].data,
        animationController: AnimationController(
          duration: Duration(milliseconds: 700),
          vsync: this,
        ),
      );
      widget.animationController.forward();
      _todoList.insert(0, widget);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 주 축 기준 중앙
              crossAxisAlignment: CrossAxisAlignment.center, // 교차 축 기준 중앙
              children: <Widget> [
                Text(
                  getToday(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.date_range),
                  color: Colors.blue,
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                reverse: false,
                itemCount: _todoList.length,
                itemBuilder: (_, index) => _todoList[index],
              ),
            ),
            Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }

  String getToday() {
    return "${selectedDate.toLocal()}".split(' ')[0];
  }

  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).accentColor),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget> [
              Flexible(
                child: TextField(
                  controller: _todoTextEditController,
                  decoration: InputDecoration(
                    hintText: '할 일을 입력하세요.',
                  ),
                  onChanged: (text) {
                    print(text);
                    setState(() {
                      _isComposing = text.length > 0;
                    });
                  },
                  onSubmitted: _isComposing ? _handleSubmitted : null,
                ),
              ),
              Container(
                child: IconButton(
                  color: Colors.blue,
                  icon: Icon(Icons.send),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_todoTextEditController.text)
                      : null,
                ),
              )
            ],
          ),
        )
    );
  }

  void _handleSubmitted(String text) {
    _todoTextEditController.clear();
    setState(() {
      _isComposing = false;
      _addTodo(Todo(rank+1, text, false));
      var widget = TodoWidget(
        text: text,
        animationController: AnimationController(
          duration: Duration(milliseconds: 700),
          vsync: this,
        ),
      );
      setState(() {
        _todoList.insert(0, widget);
      });
      widget.animationController.forward();
    });
  }

  // 할 일 추가 메서드
  void _addTodo(Todo todo) {
    Firestore.instance
        .collection('todo')
        .document(_name)
        .collection(getToday())
        .add({'rank': todo.rank, 'data': todo.data, 'isDone': todo.isDone});
  }
}


class TodoWidget extends StatelessWidget {
  final String text;
  final AnimationController animationController;

  TodoWidget({this.text, this.animationController});

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text(_name[0])),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_name, style: Theme.of(context).textTheme.headline6),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Text(text),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
