class Friend {
  int userId;
  int friendId;

  Friend({
    required this.userId,
    required this.friendId,
  });

  factory Friend.fromMap(Map<String, dynamic> json) => Friend(
    userId: json['USER_ID'],
    friendId: json['FRIEND_ID'],
  );

  Map<String, dynamic> toMap() => {
    'USER_ID': userId,
    'FRIEND_ID': friendId,
  };
}
