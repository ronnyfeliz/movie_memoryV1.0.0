class ListComment {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String listOwnerUid;
  final String listId;
  final String text;
  final DateTime timestamp;
  final DateTime? editedAt;
  final List<String> likes;
  final bool isLikedByCurrentUser;
  final String? parentId;

  ListComment({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.listOwnerUid,
    required this.listId,
    required this.text,
    required this.timestamp,
    this.editedAt,
    this.likes = const [],
    this.isLikedByCurrentUser = false,
    this.parentId,
  });

  bool get isReply => parentId != null && parentId!.isNotEmpty;
  int get likeCount => likes.length;

  ListComment copyWith({
    String? id,
    String? userId,
    String? username,
    String? avatarUrl,
    String? listOwnerUid,
    String? listId,
    String? text,
    DateTime? timestamp,
    DateTime? editedAt,
    List<String>? likes,
    bool? isLikedByCurrentUser,
    String? parentId,
  }) {
    return ListComment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      listOwnerUid: listOwnerUid ?? this.listOwnerUid,
      listId: listId ?? this.listId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
      likes: likes ?? this.likes,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      parentId: parentId ?? this.parentId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'listOwnerUid': listOwnerUid,
      'listId': listId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
      'likes': likes,
      'parentId': parentId,
    };
  }

  factory ListComment.fromMap(String id, Map<String, dynamic> map) {
    return ListComment(
      id: id,
      userId: map['userId'] ?? '',
      username: map['username'] ?? 'Anonymous',
      avatarUrl: map['avatarUrl'],
      listOwnerUid: map['listOwnerUid'] ?? '',
      listId: map['listId'] ?? '',
      text: map['text'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      editedAt: map['editedAt'] != null ? DateTime.parse(map['editedAt']) : null,
      likes: List<String>.from(map['likes'] ?? []),
      parentId: map['parentId'],
    );
  }
}
