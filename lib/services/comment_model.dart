class CommentModel {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String contentId;
  final String text;
  final DateTime timestamp;
  final DateTime? editedAt;
  final List<String> likes;
  final String? parentId;
  bool _isLikedByCurrentUser = false;

  CommentModel({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.contentId,
    required this.text,
    required this.timestamp,
    this.editedAt,
    this.likes = const [],
    this.parentId,
  });

  bool get isLikedByCurrentUser => _isLikedByCurrentUser;
  bool get isReply => parentId != null;
  int get likeCount => likes.length;

  void setLikedByCurrentUser(bool value) {
    _isLikedByCurrentUser = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'contentId': contentId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
      'likes': likes,
      'parentId': parentId,
    };
  }

  factory CommentModel.fromMap(String id, Map<String, dynamic> map) {
    return CommentModel(
      id: id,
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      contentId: map['contentId'] ?? '',
      text: map['text'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      editedAt: map['editedAt'] != null ? DateTime.tryParse(map['editedAt']) : null,
      likes: List<String>.from(map['likes'] ?? []),
      parentId: map['parentId'] as String?,
    );
  }
}
