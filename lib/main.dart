import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/FireBase.dart';
import 'package:flutter_todo/todo.dart';

String _name = "test";

class TodoMain extends StatelessWidget {

  TodoMain(String name){
    _name = name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyToDo(title: "To do",),
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
  DateTime selectedDate = DateTime.now();
  int _rank = -1;

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
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('todo')
                  .document(_name)
                  .collection(_getSelectedDay())
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final documents = snapshot.data.documents;
                final sortedDocuments = _sortDataToInsert(documents);
                return Expanded(
                  child: ListView(
                    children: sortedDocuments.map((sortedTodo) => _buildTodoListWidget(sortedTodo)).toList(),
                  ),
                );
              },
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

  void _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _rank = -1;
      });
    }
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

  // 할일을 추가한 순서대로 다시 불러온다.
  List<Todo> _sortDataToInsert(List<DocumentSnapshot> documents) {
    List<Todo> _insertedList = <Todo>[];
    String day = _getSelectedDay();
    if (documents.isNotEmpty) {
      documents.forEach((doc) => _insertedList.add(Todo(doc['rank'], doc['data'], doc['isDone'], doc.documentID, day)));
      _insertedList.sort((a, b) => b.rank.compareTo(a.rank));
      _rank = _insertedList[0].rank;
    }
    return _insertedList;
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
                  },
                  onSubmitted: _handleSubmitted,
                ),
              ),
              Container(
                child: IconButton(
                  color: Colors.blue,
                  icon: Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_todoTextEditController.text),
                ),
              )
            ],
          ),
        )
    );
  }

  // 추가버튼 클릭 시 Firestore에 저장한다.
  void _handleSubmitted(String text) {
    if(text == null || text == "") return;
    _todoTextEditController.clear();
    FireBaseDAO.addTodo(_name, Todo(_rank + 1, text, false, null, _getSelectedDay()));
  }

  // 할 일 객체를 ListTile 형태로 변경하는 메서드
  Widget _buildTodoListWidget(Todo sortedTodo) {
    bool isDone = sortedTodo.isDone;
    IconData iconImage = generateIcon(isDone);
    TextEditingController changeTextController = TextEditingController(text: sortedTodo.data);
    return ListTile(
      onTap: () => null,
      onLongPress: () => showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('할일 변경'),
            content: TextField(
              controller: changeTextController,
              autofocus: true,
            ),
            actions: [
              FlatButton(
                child: Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('확인'),
                onPressed: () {
                  String text = changeTextController.value.text;
                  sortedTodo.data = text;
                  FireBaseDAO.updateTodo(_name, sortedTodo);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
      ),  // TODO: 길게 누르면 수정 모드로 변경
      leading: IconButton(  // 왼쪽
        icon: Icon(
          iconImage,
          color: Colors.blue,
        ),
        onPressed: () => FireBaseDAO.toggleTodo(_name, sortedTodo),
      ),
      title: Text(      // 할일 내용
        sortedTodo.data,
        style: sortedTodo.isDone ? TextStyle(
          decoration: TextDecoration.lineThrough,
          fontStyle: FontStyle.italic,
        ) : null,
      ),
      trailing: IconButton(   // 오른쪽
        icon: Icon(
          Icons.delete,
          color: Colors.redAccent,
        ),
        onPressed: () => FireBaseDAO.deleteTodo(_name, sortedTodo),
      ),
    );
  }

  IconData generateIcon(bool isDone) {
    IconData icon;
    if (isDone) icon = Icons.check_circle;
    else icon = Icons.radio_button_unchecked_rounded;
    return icon;
  }
}
