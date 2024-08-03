import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_todo/pages/home_page.dart';
import 'package:flutter_todo/utils/deleted_list.dart';
import 'package:flutter_todo/utils/todo_list.dart';
import 'package:path_provider/path_provider.dart';

class DeletedPage extends StatefulWidget {
  DeletedPage({super.key});

  @override
  State<DeletedPage> createState() => _DeletedPageState();
}

class _DeletedPageState extends State<DeletedPage> {
  final _controller = TextEditingController();
  List todoList = [];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/deletedTasks.txt');
  }

  Future<File> get _localActiveFile async {
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

  Future<File> deleteTaskFilePermanently(int index) async {
    final file = await _localFile;
    final contents = await file.readAsString();
    final newContents = contents.split('\n');
    newContents.removeAt(index);
    final newFile = await _localFile;
    return newFile.writeAsString(newContents.join('\n'));
  }

  Future<File> writeInActive(int index) async {
    final file = await _localFile;
    final contents = await file.readAsString();
    final newContents = contents.split('\n');
    String restoredTask = newContents[index];
    final newFile = await _localActiveFile;
    return newFile.writeAsString('$restoredTask\n', mode: FileMode.append);
  }

  void checkBoxChanged(int index) {
    setState(() {
      writeTaskStatus(todoList[index][0], !todoList[index][1], index);
      todoList[index][1] = !todoList[index][1];
    });
  }

  void saveNewTask() {
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
      deleteTaskFilePermanently(index);
      todoList.removeAt(index);
    });
  }

  void restoreTask(int index) {
    setState(() {
      writeInActive(index);
      deleteTaskFilePermanently(index);
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
        title: const Text(
          'Deleted Tasks',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
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
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false);
                },
              ),
            ),
            ListTile(
              title: const Text(
                'ToDo List',
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.deepPurple,
                ),
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (route) => false);
              },
            ),
            const ListTile(
              title: Text(
                'Deleted Tasks',
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'About Simple ToDo',
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.deepPurple,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: todoList.isEmpty
          ? const Center(
              child: Text(
                'No tasks deleted yet!',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                        itemCount: todoList.length,
                        itemBuilder: (BuildContext context, index) {
                          return DeletedList(
                            taskName: todoList[index][0],
                            taskCompleted: todoList[index][1],
                            onChanged: (value) => checkBoxChanged(index),
                            deleteFunction: (context) => deleteTask(index),
                            restoreFunction: (context) => restoreTask(index),
                          );
                        }),
                  ),
                ],
              ),
            ),
    );
  }
}
