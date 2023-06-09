class Note {
  final String id;
  final String title;
  final String body;
  final DateTime created;

  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.created,
  });

  Note.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        body = json['body'],
        created = json['created'];

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "body": body,
        "created": created.toIso8601String(),
      };
}

List<Note> notes = [
  Note(
    id: "1",
    body:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
    created: DateTime.now(),
    title: "The standard Lorem Ipsum passage, used since the 1500s",
  ),
  Note(
    id: "2",
    body:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
    created: DateTime.now(),
    title: "1914 translation by H. Rackham",
  ),
];
