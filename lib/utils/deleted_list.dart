import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DeletedList extends StatelessWidget {
  const DeletedList(
      {super.key,
      required this.taskName,
      required this.taskCompleted,
      required this.onChanged,
      required this.deleteFunction,
      required this.restoreFunction});

  final String taskName;
  final bool taskCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;
  final Function(BuildContext)? restoreFunction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(15),
            ),
            SlidableAction(
              onPressed: restoreFunction,
              icon: Icons.rotate_left,
              borderRadius: BorderRadius.circular(15),
            )
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Checkbox(
                value: taskCompleted,
                onChanged: onChanged,
                checkColor: Colors.black,
                activeColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    taskName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      decoration: taskCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Colors.white,
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
