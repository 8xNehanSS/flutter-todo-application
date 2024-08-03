import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade300,
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: true,
        title: const Text(
          'About',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Text(
                textAlign: TextAlign.center,
                'This is the about page of the FlutterToDo app. It provides information about the app and its developer.',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Spacer(),
            Text(
              textAlign: TextAlign.center,
              'Version 1.0.1',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              textAlign: TextAlign.center,
              'Developed by: 8xNehanSS',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
