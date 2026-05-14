import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("tasks");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrakFlow',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}


class Task {
  final int id;
  String title;
  String deadline;
  bool done;
  String priority;

  Task({
    required this.id,
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });


  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "deadline": deadline,
      "priority": priority,
      "done": done,
    };
  }


  factory Task.fromMap(Map map) {
    return Task(
      id: map["id"],
      title: map["title"],
      deadline: map["deadline"],
      priority: map["priority"],
      done: map["done"],
    );
  }
}


class TaskLocalDatabase {
  static Box get _box => Hive.box("tasks");

  static List<Task> getTasks() {
    return _box.values.map((item) => Task.fromMap(Map<String, dynamic>.from(item))).toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    for (var task in tasks) {
      await _box.put(task.id, task.toMap());
    }
  }

  static Future<void> addTask(Task task) async => await _box.put(task.id, task.toMap());
  static Future<void> updateTask(Task task) async => await _box.put(task.id, task.toMap());
  static Future<void> deleteTask(int id) async => await _box.delete(id);
  static bool isEmpty() => _box.isEmpty;
}

class TaskApiService {
  static const String baseUrl = "https://dummyjson.com";

  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse("$baseUrl/todos"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List todos = data["todos"];
      final random = Random();
      final priorities = ["niski", "średni", "wysoki"];
      final deadlines = ["dzisiaj", "jutro", "w piątek", "za tydzień"];

      return todos.map((todo) {
        return Task(
          id: todo["id"], // ID z API
          title: todo["todo"],
          deadline: deadlines[random.nextInt(deadlines.length)],
          done: todo["completed"],
          priority: priorities[random.nextInt(priorities.length)],
        );
      }).toList();
    } else {
      throw Exception("Błąd pobierania danych");
    }
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "wszystkie";
  late Future<List<Task>> tasksFuture;

  @override
  void initState() {
    super.initState();
    tasksFuture = _loadTasks();
  }


  Future<List<Task>> _loadTasks() async {
    if (TaskLocalDatabase.isEmpty()) {
      final tasksFromApi = await TaskApiService.fetchTasks();
      await TaskLocalDatabase.saveTasks(tasksFromApi);
    }
    return TaskLocalDatabase.getTasks();
  }

  List<Task> _applyFilter(List<Task> tasks) {
    if (selectedFilter == "wykonane") return tasks.where((t) => t.done).toList();
    if (selectedFilter == "do zrobienia") return tasks.where((t) => !t.done).toList();
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("KrakFlow (Hive DB)")),
      body: FutureBuilder<List<Task>>(
        future: tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          }

          final allTasks = snapshot.data ?? [];
          final filteredTasks = _applyFilter(allTasks);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Zadania w bazie: ${allTasks.length}"),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["wszystkie", "do zrobienia", "wykonane"].map((filter) {
                  return TextButton(
                    onPressed: () => setState(() => selectedFilter = filter),
                    child: Text(filter, style: TextStyle(
                      fontWeight: selectedFilter == filter ? FontWeight.bold : FontWeight.normal,
                      color: selectedFilter == filter ? Colors.blue : Colors.grey,
                    )),
                  );
                }).toList(),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return Dismissible(
                      key: ValueKey(task.id),
                      direction: DismissDirection.endToStart,
                      background: Container(color: Colors.red, alignment: Alignment.centerRight, child: const Icon(Icons.delete, color: Colors.white)),
                      onDismissed: (_) async {
                        await TaskLocalDatabase.deleteTask(task.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Usunięto ${task.title}")));
                      },
                      child: ListTile(
                        leading: Checkbox(
                          value: task.done,
                          onChanged: (val) async {
                            task.done = val!;
                            await TaskLocalDatabase.updateTask(task);
                            setState(() { tasksFuture = _loadTasks(); });
                          },
                        ),
                        title: Text(task.title, style: TextStyle(
                          decoration: task.done ? TextDecoration.lineThrough : null,
                        )),
                        subtitle: Text("${task.deadline} | Priorytet: ${task.priority}"),
                        onTap: () async {
                          final updated = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)));
                          if (updated != null) {
                            await TaskLocalDatabase.updateTask(updated);
                            setState(() { tasksFuture = _loadTasks(); });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddTaskScreen()));
          if (newTask != null) {
            await TaskLocalDatabase.addTask(newTask);
            setState(() { tasksFuture = _loadTasks(); });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


class AddTaskScreen extends StatelessWidget {
  final titleController = TextEditingController();
  AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nowe zadanie")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tytuł")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final task = Task(
                  id: DateTime.now().millisecondsSinceEpoch, // Generowanie ID
                  title: titleController.text,
                  deadline: "dzisiaj",
                  priority: "średni",
                  done: false,
                );
                Navigator.pop(context, task);
              },
              child: const Text("Dodaj"),
            )
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  final Task task;
  late final TextEditingController titleController;

  EditTaskScreen({super.key, required this.task}) {
    titleController = TextEditingController(text: task.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edytuj zadanie")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tytuł")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                task.title = titleController.text;
                Navigator.pop(context, task);
              },
              child: const Text("Zapisz"),
            )
          ],
        ),
      ),
    );
  }
}