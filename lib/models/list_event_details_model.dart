class ListEventDetail {
  int? id;
  int listId;
  int giftId;
  String status;

  ListEventDetail({
    this.id,
    required this.listId,
    required this.giftId,
    this.status = 'available',
  });

  factory ListEventDetail.fromMap(Map<String, dynamic> json) => ListEventDetail(
    id: json['ID'],
    listId: json['LIST_ID'],
    giftId: json['GIFT_ID'],
    status: json['STATUS'],
  );

  Map<String, dynamic> toMap() => {
    'ID': id,
    'LIST_ID': listId,
    'GIFT_ID': giftId,
    'STATUS': status,
  };
}
