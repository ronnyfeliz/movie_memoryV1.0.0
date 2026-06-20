import 'notification_category.dart';

enum NotificationType {
  newFollower,
  listFollow,
  listLike,
  comment,
  reply,
  general,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;
  final NotificationCategory category;
  final String? senderUid;
  final String? senderName;
  final String? senderPhotoUrl;
  final String? targetId;
  final String? targetType;
  final int? mediaId;
  final String? mediaTitle;
  final String? mediaType;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    required this.type,
    this.category = NotificationCategory.seriesUpdate,
    this.senderUid,
    this.senderName,
    this.senderPhotoUrl,
    this.targetId,
    this.targetType,
    this.mediaId,
    this.mediaTitle,
    this.mediaType,
    this.actionUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': type.name,
      'category': category.name,
      'senderUid': senderUid,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'targetId': targetId,
      'targetType': targetType,
      'mediaId': mediaId,
      'mediaTitle': mediaTitle,
      'mediaType': mediaType,
      'actionUrl': actionUrl,
    };
  }

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: map['isRead'] ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.general,
      ),
      category: NotificationCategory.fromName(map['category'] ?? ''),
      senderUid: map['senderUid'],
      senderName: map['senderName'],
      senderPhotoUrl: map['senderPhotoUrl'],
      targetId: map['targetId'],
      targetType: map['targetType'],
      mediaId: map['mediaId'],
      mediaTitle: map['mediaTitle'],
      mediaType: map['mediaType'],
      actionUrl: map['actionUrl'],
    );
  }

  NotificationModel copyWith({
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    NotificationType? type,
    NotificationCategory? category,
    String? senderUid,
    String? senderName,
    String? senderPhotoUrl,
    String? targetId,
    String? targetType,
    int? mediaId,
    String? mediaTitle,
    String? mediaType,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      category: category ?? this.category,
      senderUid: senderUid ?? this.senderUid,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      mediaId: mediaId ?? this.mediaId,
      mediaTitle: mediaTitle ?? this.mediaTitle,
      mediaType: mediaType ?? this.mediaType,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}
