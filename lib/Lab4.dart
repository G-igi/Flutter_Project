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
    Task(title: "Zadania z dzielenia partycji", deadline: "wtorek", done: true),
    Task(title: "Grafy przeszukiwań", deadline: "następny tydzień", done: false),
    Task(title: "Przeczytać o Window Sliding", deadline: "jutro", done: true),
    Task(title: "Kupić bulki", deadline: "jutro", done: false),
  ];

  String getPriority(String deadline) {
    if (deadline.contains('jutro')) return 'wysoki';
    if (deadline.contains('wtorek')) return 'średnie';
    if (deadline.contains('następny tydzień')) return 'mały';
    return 'brak';
  }
  
  @override
  Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Dziesiejsze Zadania',
    home: Scaffold(
      appBar:    AppBar(
        title: Column(children: [Text("Masz dziś ${tasks.where((task) => task.done).length} zadania. ${tasks.where((task) => task.done).length}/${tasks.length}"),SizedBox(height: 4), const Text('Dziesiejsze Zadania', style: TextStyle( fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red))]),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: TaskCard(title: task.title,),
            subtitle: TaskCard(title: 'Termin: ${task.deadline} priority: ${getPriority(task.deadline)}'),
            trailing: Icon(
              task.done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: task.done ? Colors.green : Colors.grey, // Optional: adding color for better UX
            ),
            
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
  final bool done;
  Task({required this.title, required this.deadline, required this.done});
}

class TaskCard extends StatelessWidget {
  final String title;
  const TaskCard({ super.key,  required this.title });

  @override Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          title: Text(title, textAlign: TextAlign.center, style: TextStyle(wordSpacing: 5)),
      )
    );
  }
}
