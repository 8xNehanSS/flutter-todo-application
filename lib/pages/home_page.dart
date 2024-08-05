import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_todo/pages/about_page.dart';
import 'package:flutter_todo/pages/deleted_tasks.dart';
import 'package:flutter_todo/utils/todo_list.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  List todoList = [];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tasks.txt');
  }

  Future<File> deleteTasks() async {
    final file = await _localFile;
    return file.writeAsString('');
  }

  Future<String?> readTasks() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return null;
    }
  }

  Future<List<List<dynamic>>> readTasksList() async {
    final contents = await readTasks();
    if (contents == null) {
      return [];
    }
    final List<List<dynamic>> tasks = [];
    final List splittedTasks = contents.split('\n');
    splittedTasks.removeLast();
    for (var i = 0; i < splittedTasks.length; i++) {
      final task = splittedTasks[i].split('%20');
      final b = stringToBool(task[1]);
      tasks.add([task[0], b]);
    }
    return tasks;
  }

  bool stringToBool(String str) {
    return str.toLowerCase() == 'true';
  }

  Future<File> writeTasks(String task) async {
    final file = await _localFile;
    return file.writeAsString('$task\n', mode: FileMode.append);
  }

  Future<File> writeTaskStatus(String task, bool status, int index) async {
    final file = await _localFile;
    final newTask = '$task%20$status';
    final contents = await file.readAsString();
    final newContents = contents.split('\n');
    newContents.removeAt(index);
    newContents.insert(index, newTask);
    final newFile = await _localFile;
    return newFile.writeAsString(newContents.join('\n'));
  }

  Future<File> deleteTaskFile(int index) async {
    final file = await _localFile;
    final contents = await file.readAsString();
    final newContents = contents.split('\n');
    String deletedTask = newContents.removeAt(index);
    final delFile = await _localDelFile;
    delFile.writeAsString('$deletedTask\n', mode: FileMode.append);
    final newFile = await _localFile;
    return newFile.writeAsString(newContents.join('\n'));
  }

  Future<File> get _localDelFile async {
    final path = await _localPath;
    return File('$path/deletedTasks.txt');
  }

  void checkBoxChanged(int index) {
    setState(() {
      writeTaskStatus(todoList[index][0], !todoList[index][1], index);
      todoList[index][1] = !todoList[index][1];
    });
  }

  void saveNewTask() {
    if (_controller.text.isEmpty) {
      return;
    } else if (_controller.text.contains('%20')) {
      return;
    } else if (_controller.text.contains('\n')) {
      return;
    } else if (_controller.text.trim().isEmpty) {
      return;
    }
    setState(() {
      writeTasks('${_controller.text}%20false');
      todoList.add([_controller.text, false]);
      _controller.clear();
    });
  }

  void loadTasks() {
    readTasksList().then((value) {
      setState(() {
        todoList = value;
      });
    });
  }

  void deleteTask(int index) {
    setState(() {
      deleteTaskFile(index);
      todoList.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade300,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 70,
        title: const Text(
          'Simple ToDo',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        backgroundColor: Colors.deepPurple.shade300,
        child: ListView(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: ListTile(
                title: const Center(
                  child: Text(
                    'Simple ToDo',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text(
                'ToDo List',
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                'Deleted Tasks',
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeletedPage()),
                );
                loadTasks();
              },
            ),
            ListTile(
              title: const Text(
                'About Simple ToDo',
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: todoList.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet!',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      textAlign: TextAlign.left,
                      'Today is ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                        itemCount: todoList.length,
                        itemBuilder: (BuildContext context, index) {
                          return TodoList(
                            taskName: todoList[index][0],
                            taskCompleted: todoList[index][1],
                            onChanged: (value) => checkBoxChanged(index),
                            deleteFunction: (context) => deleteTask(index),
                          );
                        }),
                  ),
                ],
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Add a new todo item',
                    filled: true,
                    fillColor: Colors.deepPurple.shade200,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: saveNewTask,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
