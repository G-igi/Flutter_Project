
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
    this.priority = "średni"
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

class TaskRepository {
  static List<Task> tasks = [
    Task(title: "Projekt Flutter", deadline: "jutro", done: false, priority: "wysoki"),
    Task(title: "Oddać raport", deadline: "dzisiaj", done: true, priority: "wysoki"),
  ];
}