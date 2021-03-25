import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static Future<SharedPreferences> sharedPref() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }
}