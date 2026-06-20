class CustomListModel {
  final String id;
  final String name;
  final String description;
  final List<String> itemIds;
  final DateTime createdAt;
  final String? coverUrl;
  final bool isPublic;
  final int likeCount;
  final List<String> likedBy;
  final List<String> followedBy;
  final String ownerUid;

  CustomListModel({
    required this.id,
    required this.name,
    this.description = '',
    this.itemIds = const [],
    required this.createdAt,
    this.coverUrl,
    this.isPublic = false,
    this.likeCount = 0,
    this.likedBy = const [],
    this.followedBy = const [],
    this.ownerUid = '',
  });

  bool likedByUser(String userId) => likedBy.contains(userId);
  bool followedByUser(String userId) => followedBy.contains(userId);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'itemIds': itemIds,
      'createdAt': createdAt.toIso8601String(),
      'coverUrl': coverUrl,
      'isPublic': isPublic,
      'likeCount': likeCount,
      'likedBy': likedBy,
      'followedBy': followedBy,
      'ownerUid': ownerUid,
    };
  }

  factory CustomListModel.fromMap(String id, Map<String, dynamic> map, {String ownerUid = ''}) {
    return CustomListModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      itemIds: List<String>.from(map['itemIds'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      coverUrl: map['coverUrl'],
      isPublic: map['isPublic'] ?? false,
      likeCount: map['likeCount'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      followedBy: List<String>.from(map['followedBy'] ?? []),
      ownerUid: map['ownerUid'] ?? ownerUid,
    );
  }

  CustomListModel copyWith({
    String? name,
    String? description,
    List<String>? itemIds,
    String? coverUrl,
    bool? isPublic,
    int? likeCount,
    List<String>? likedBy,
    List<String>? followedBy,
    String? ownerUid,
  }) {
    return CustomListModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      itemIds: itemIds ?? this.itemIds,
      createdAt: createdAt,
      coverUrl: coverUrl ?? this.coverUrl,
      isPublic: isPublic ?? this.isPublic,
      likeCount: likeCount ?? this.likeCount,
      likedBy: likedBy ?? this.likedBy,
      followedBy: followedBy ?? this.followedBy,
      ownerUid: ownerUid ?? this.ownerUid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomListModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
