class Exercise {
  int? id;
  final String name;
  final String type;
  final String description;

  Exercise({
    this.id,
    required this.name,
    required this.type,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      description: map['description'],
    );
  }
}