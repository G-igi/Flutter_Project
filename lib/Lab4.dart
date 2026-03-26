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
    title: 'Dziesiejsze Zadania',
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Dziesiejsze Zadania', style: TextStyle( fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
    ),

    body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: TaskCard(title: task.title,),
            subtitle: TaskCard(title: 'Termin: ${task.deadline}'),
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

class TaskCard extends StatelessWidget {
  final String title;
  const TaskCard({ super.key,  required this.title });

  @override Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          title: Text(title),
      )
    );
  }
}
