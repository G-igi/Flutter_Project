import 'package:flutter/material.dart';



void main() {
  runApp( MyApp());
}
class MyApp extends StatefulWidget{
  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {

  List<Task> tasks = [
    Task(title: "Zadania z dzielenia partycji", deadline: "wtorek"),
    Task(title: "Grafy przeszukiwań", deadline: "następny tydzień"),
    Task(title: "Przeczytać o Window Sliding", deadline: "jurto"),
    Task(title: "Kupić bulki", deadline: "jutro"),
  ];

  @override
  Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Moje Zadania',
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Moje Zadania'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
    ),
    body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text('Termin: ${task.deadline}'),
          );
    },
    ),
    ),
  );
  }
}

class Task{
  late final String title;
  late final String deadline;
  Task({required this.title, required this.deadline});
}


