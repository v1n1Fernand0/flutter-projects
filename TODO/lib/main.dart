import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/item.dart';
import 'dart:convert';

void main() {
  runApp(APP());
}

class APP extends StatelessWidget {
  APP({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = [];
  HomePage() {
    items.add(Item(title: "Banana", done: false));
    items.add(Item(title: "Abacate", done: true));
    items.add(Item(title: "Tomate", done: false));
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskController = TextEditingController();

  void add() {
    final texto = newTaskController.text;

    if (texto.isEmpty) return;
    setState(() {
      widget.items.add(Item(title: newTaskController.text, done: false));
      newTaskController.clear();
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');
    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((e) => Item.fromJson(e)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState() {
    load();
  }
  @override
  Widget build(BuildContext context) {
    newTaskController.clear();
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskController,
          keyboardType: TextInputType.text,
          style: TextStyle(color: Colors.white, fontSize: 24),
          decoration: InputDecoration(
              labelText: "Nova Tarefa",
              labelStyle: TextStyle(color: Colors.white)),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctxt, int index) {
          final item = widget.items[index];
          return Dismissible(
              key: Key(item.title),
              background: Container(
                color: Colors.red.withOpacity(0.2),
              ),
              onDismissed: (direction) {
                remove(index);
              },
              child: CheckboxListTile(
                  title: Text(item.title),
                  value: item.done,
                  onChanged: (value) {
                    setState(() {
                      item.done = value;
                      save();
                    });
                  }));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
