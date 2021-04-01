import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {

  SharedPreferences _prefs;

  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void clear() {
    _prefs.clear();
  }

  String getId() {
    return _prefs.getString("id");
  }

  String getPw() {
    return _prefs.getString("pw");
  }

  void save(String id, String pw) {
    _prefs.setString('id', id);
    _prefs.setString('pw', pw);
    _prefs.commit();
  }
}