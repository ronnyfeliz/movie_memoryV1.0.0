import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/list_comment_model.dart';
import 'list_comment_service.dart';

final listCommentServiceProvider = Provider<ListCommentService>((ref) {
  return ListCommentService();
});

final listCommentsProvider = StreamProvider.family<List<ListComment>, ({String ownerUid, String listId})>((ref, params) {
  return ref.watch(listCommentServiceProvider).watchComments(params.ownerUid, params.listId);
});
