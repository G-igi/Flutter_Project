import 'package:flutter/material.dart';
void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class Task {
  String title;
  String deadline;
  bool done;
  String priority;

  Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}

class TaskRepository {
  static List<Task> tasks = [
    Task(
      title: "Projekt Flutter",
      deadline: "jutro",
      done: false,
      priority: "wysoki",
    ),
    Task(
      title: "Oddać raport",
      deadline: "dzisiaj",
      done: true,
      priority: "wysoki",
    ),
    Task(
      title: "Powtórzyć widgety",
      deadline: "w piątek",
      done: false,
      priority: "średni",
    ),
  ];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "wszystkie";


  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = TaskRepository.tasks;

    if (selectedFilter == "wykonane") {
      filteredTasks = TaskRepository.tasks
          .where((task) => task.done)
          .toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = TaskRepository.tasks
          .where((task) => !task.done)
          .toList();
    }


    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Masz dziś ${TaskRepository.tasks.length} zadania",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedFilter = "wszystkie";
                  });
                },
                child: Text(
                  "Wszystkie",
                  style: TextStyle(
                    color: selectedFilter == "wszystkie"
                        ? Colors.blue
                        : Colors.grey,
                    fontWeight: selectedFilter == "wszystkie"
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedFilter = "do zrobienia";
                  });
                },
                child: Text(
                  "Do zrobienia",
                  style: TextStyle(
                    color: selectedFilter == "do zrobienia"
                        ? Colors.blue
                        : Colors.grey,
                    fontWeight: selectedFilter == "do zrobienia"
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedFilter = "wykonane";
                  });
                },
                child: Text(
                  "Wykonane",
                  style: TextStyle(
                    color: selectedFilter == "wykonane"
                        ? Colors.blue
                        : Colors.grey,
                    fontWeight: selectedFilter == "wykonane"
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];

                return Dismissible(
                  key: ValueKey(task.title),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    final removedTitle = task.title;

                    setState(() {
                      TaskRepository.tasks.remove(task);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Usunięto zadanie: $removedTitle"),
                      ),
                    );
                  },
                  child: ListTile(
                    onTap: () async {
                      final Task? updatedTask = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(task: task),
                        ),
                      );

                      if (updatedTask != null) {
                        setState(() {
                          TaskRepository.tasks[
                          TaskRepository.tasks.indexOf(task)] = updatedTask;
                        });
                      }
                    },
                    leading: Checkbox(
                      value: task.done,
                      onChanged: (value) {
                        setState(() {
                          task.done = value!;
                        });
                      },
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: task.done ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text("${task.deadline} | ${task.priority}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => AddTaskScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );

          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nowe zadanie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              //callback
              onPressed: () {
                final newTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: false,
                );

                Navigator.pop(context,  newTask);
              },
              child: Text("Zapisz zmiany"),
            ),
          ],
        ),
      ),
    );
  }
}


class EditTaskScreen extends StatelessWidget {
  final Task task;

  EditTaskScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController =
    TextEditingController(text: task.title);
    final TextEditingController deadlineController =
    TextEditingController(text: task.deadline);
    final TextEditingController priorityController =
    TextEditingController(text: task.priority);

    return Scaffold(
      appBar: AppBar(
        title: Text("Edytuj zadanie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: task.done,
                );

                Navigator.pop(context, updatedTask);
              },
              child: Text("Zapisz wszytskie zmiany"),
            ),
          ],
        ),
      ),
    );
  }
}