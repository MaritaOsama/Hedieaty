class ListEvent {
  int? id;
  String name;
  int? listDetailsId;
  int userId;
  String status;

  ListEvent({
    this.id,
    required this.name,
    this.listDetailsId,
    required this.userId,
    this.status = 'open',
  });

  factory ListEvent.fromMap(Map<String, dynamic> json) => ListEvent(
    id: json['ID'],
    name: json['NAME'],
    listDetailsId: json['LIST_DETAILS_ID'],
    userId: json['USER_ID'],
    status: json['STATUS'],
  );

  Map<String, dynamic> toMap() => {
    'ID': id,
    'NAME': name,
    'LIST_DETAILS_ID': listDetailsId,
    'USER_ID': userId,
    'STATUS': status,
  };
}
