import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {

  SharedPreferences _prefs;

  SharedPref() {
    _load();
  }

  _load() async {
    _prefs = await _sharedPref();
  }

  _sharedPref() async {
    return await SharedPreferences.getInstance();
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
  }
}