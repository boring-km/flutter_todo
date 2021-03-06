import 'package:cloud_firestore/cloud_firestore.dart';
import 'todo.dart';

class FireBaseDAO {
  static addTodo(String userName, Todo todo) {
    Firestore.instance
        .collection('todo')
        .document(userName)
        .collection(todo.selectedDay)
        .add({'rank': todo.rank, 'data': todo.data, 'isDone': todo.isDone});
  }

  static void deleteTodo(String userName, Todo todo) {
    Firestore.instance
        .collection('todo')
        .document(userName)
        .collection(todo.selectedDay)
        .document(todo.docId).delete();
  }

  static void toggleTodo(String userName, Todo todo) {
    Firestore.instance
        .collection('todo')
        .document(userName)
        .collection(todo.selectedDay)
        .document(todo.docId)
        .updateData({'isDone': !todo.isDone});
  }

  static void updateTodo(String userName, Todo todo) {
    Firestore.instance
        .collection('todo')
        .document(userName)
        .collection(todo.selectedDay)
        .document(todo.docId)
        .updateData({'data': todo.data});
  }

  static void signUp(String id, String pw) {
    Firestore.instance
        .collection('todo')
        .document(id)
        .setData({'pw': pw});
  }

  static Future<DocumentSnapshot> idCheck(String id) async {
    return await Firestore.instance
        .collection('todo')
        .document(id)
        .get();
  }

  static Future<bool> loginIdCheck(String id, String pw) async {
    DocumentSnapshot snapshot =
    await Firestore.instance.collection('todo').document(id).get();
    bool result = snapshot['pw'] == pw;
    return result;
  }
}