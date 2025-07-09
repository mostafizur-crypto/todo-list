import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/todo.dart';
import '../widgets/todo_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> todos = [];
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  void saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> data = todos.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('todos', data);
  }

  void loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? data = prefs.getStringList('todos');
    if (data != null) {
      setState(() {
        todos = data.map((e) => Todo.fromJson(json.decode(e))).toList();
      });
    }
  }

  void addTodo(String title) {
    setState(() {
      todos.add(Todo(title: title));
    });
    saveTodos();
    controller.clear();
  }

  void toggleDone(int index) {
    setState(() {
      todos[index].isDone = !todos[index].isDone;
    });
    saveTodos();
  }

  void deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
    saveTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter task...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      addTodo(controller.text.trim());
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (_, index) {
                return TodoItem(
                  todo: todos[index],
                  onToggle: () => toggleDone(index),
                  onDelete: () => deleteTodo(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}