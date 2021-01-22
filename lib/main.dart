import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/todo.dart';

// TODO 로그인 화면에서 불러오는 형식으로 변경할 예정
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
  DateTime selectedDate = DateTime.now();
  bool _isComposing = false;
  int _rank = -1;

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
        _rank = -1;
        _todoList.clear();
      });
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
            _buildDateSelector(context),
            _buildTodoListView(),
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

  Row _buildDateSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // 주 축 기준 중앙
      crossAxisAlignment: CrossAxisAlignment.center, // 교차 축 기준 중앙
      children: <Widget>[
        Text(
          _getSelectedDay(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.date_range),
          color: Colors.blue,
          onPressed: () => _selectDate(context),
        ),
      ],
    );
  }

  
  StreamBuilder<QuerySnapshot> _buildTodoListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('todo')
          .document(_name)
          .collection(_getSelectedDay())
          .snapshots(),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.active) {
          List<DocumentSnapshot> documents = snapshots.data.documents;
          // 할일의 갯수가 변경되었을 때만 변경된다. || 처음 앱 구동 시 호출한다.
          if (_rank != documents.length - 1 || _rank == -1) {
            List<Todo> _insertedList = _sortData(documents);
            _insertTodoList(_insertedList);
            _rank = documents.length - 1; // 현재 할일의 갯수를 갱신한다.
          }
          return _getTodoListView();
        } else if (snapshots.connectionState == ConnectionState.waiting) {
          return _getTodoListView();
        } else {
          return _showFirebaseError();
        }
      },
    );
  }

  Container _showFirebaseError() {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.warning),
          ),
          Text('Error in loadind data')
        ],
      ),
    );
  }

  // 리스트뷰에 불러온 할일들을 추가한다.
  void _insertTodoList(List<Todo> _insertedList) {
    for (var i = 0, len = _insertedList.length; i < len; i++) {
      var widget = TodoWidget(
        text: _insertedList[i].data,
        animationController: AnimationController(
          duration: Duration(milliseconds: 700),
          vsync: this,
        ),
      );
      _todoList.insert(0, widget);  // global 변수로 있는 할일 리스트에 추가한다.
      widget.animationController.forward();
    }
  }

  // 할일을 추가한 순서대로 다시 불러온다.
  List<Todo> _sortData(List<DocumentSnapshot> documents) {
    List<Todo> _insertedList = <Todo>[];
    documents.forEach((doc) {
      if (doc['rank'] > _rank) {
        _insertedList.add(Todo(doc['rank'], doc['data'], doc['isDone']));
      }
    });
    _insertedList.sort((a, b) => a.rank.compareTo(b.rank));
    return _insertedList;
  }

  // TodoWidget을 저장하고 있는 리스트뷰를 반환한다.
  Flexible _getTodoListView() {
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        reverse: false,
        itemCount: _todoList.length,
        itemBuilder: (_, index) => _todoList[index],
      ),
    );
  }

  // 선택된 날짜를 YYYY-MM-dd 형태로 가져오게 된다.
  String _getSelectedDay() {
    return "${selectedDate.toLocal()}".split(' ')[0];
  }

  // 할일을 입력하는 부분
  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).accentColor),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget>[
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
        ));
  }

  // 추가버튼 클릭 시 Firestore에 저장한다.
  void _handleSubmitted(String text) {
    _todoTextEditController.clear();
    setState(() {
      _isComposing = false;
      _addTodo(Todo(_rank + 1, text, false));
    });
  }

  // TODO db 연동 메서드가 계속 추가될 예정이므로 코드를 따로 분리하는게 좋아 보임
  // Firestore 할 일 추가 메서드
  void _addTodo(Todo todo) {
    Firestore.instance
        .collection('todo')
        .document(_name)
        .collection(_getSelectedDay())
        .add({'rank': todo.rank, 'data': todo.data, 'isDone': todo.isDone});
  }
}

// TODO 코드 분리 필요?
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
