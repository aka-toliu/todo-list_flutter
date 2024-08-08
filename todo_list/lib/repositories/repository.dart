import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

const key = 'tasks';

class Repository {
  late SharedPreferences _sharedPreferences; // Make it private

  Future<void> _initSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<List<Todo>> getTodoList() async {
    await _initSharedPreferences(); // Ensure initialization
    final String jsonString = _sharedPreferences.getString(key) ?? '[]';
    final List jsonDecoded = jsonDecode(jsonString) as List;
    return jsonDecoded.map((e) => Todo.fromJson(e)).toList();
  }

  Future<void> saveTodoList(List<Todo> todos) async {
    await _initSharedPreferences(); // Ensure initialization
    final String jsonString = jsonEncode(todos);
    await _sharedPreferences.setString(key, jsonString); // Use await for async operation
  }
}