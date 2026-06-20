import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/comment_service.dart';
import '../../services/comment_model.dart';
import '../../core/sound/sound_service.dart';
import '../../core/sound/sound_provider.dart';
import '../../shared/comment_utils.dart';

final commentServiceProvider = Provider<CommentService>((ref) => CommentService());

class CommentsSection extends ConsumerStatefulWidget {
  final int tmdbId;
  final String mediaType;
  const CommentsSection({super.key, required this.tmdbId, required this.mediaType});

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playClick(prefs);
    await ref.read(commentServiceProvider).addComment(widget.tmdbId, text);
    _textController.clear();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _toggleLike(String commentId) async {
    await ref.read(commentServiceProvider).toggleLike(widget.tmdbId, commentId);
  }

  Future<void> _deleteComment(String commentId, DateTime timestamp) async {
    if (isEditWindowExpired(timestamp)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solo puedes eliminar comentarios dentro de los primeros 15 minutos')),
        );
      }
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Deseas eliminar este comentario?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(commentServiceProvider).deleteComment(widget.tmdbId, commentId);
    }
  }

  void _showEditDialog(String commentId, String currentText, DateTime timestamp) {
    if (isEditWindowExpired(timestamp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes editar comentarios dentro de los primeros 15 minutos')),
      );
      return;
    }
    final editController = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar comentario'),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Escribe tu comentario...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final newText = editController.text.trim();
              if (newText.isNotEmpty) {
                await ref.read(commentServiceProvider).editComment(widget.tmdbId, commentId, newText);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(String parentId, String parentUsername) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Responder a $parentUsername'),
        content: TextField(
          controller: replyController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Escribe tu respuesta...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final text = replyController.text.trim();
              if (text.isNotEmpty) {
                await ref.read(commentServiceProvider).addComment(widget.tmdbId, text, parentId: parentId);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Responder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final comments = ref.watch(commentServiceProvider).watchComments(widget.tmdbId);
    final countStream = ref.watch(commentServiceProvider).watchCommentCount(widget.tmdbId);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        StreamBuilder<int>(
          stream: countStream,
          builder: (context, snap) {
            final count = snap.data ?? 0;
            return Row(
              children: [
                Text('Comentarios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$count', style: TextStyle(fontSize: 12, color: cs.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: 2,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Escribe un comentario...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addComment,
              icon: const Icon(Icons.send, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<CommentModel>>(
          stream: comments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ));
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error al cargar comentarios', style: TextStyle(color: cs.onSurfaceVariant)),
              );
            }
            final items = snapshot.data ?? [];
            final topComments = items.where((c) => !c.isReply).toList();
            if (topComments.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text('No hay comentarios aún. ¡Sé el primero!',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
                ),
              );
            }
            return ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topComments.length,
              itemBuilder: (_, i) => _CommentTile(
                key: ValueKey(topComments[i].id),
                comment: topComments[i],
                userId: userId,
                onToggleLike: () => _toggleLike(topComments[i].id),
                onEdit: () => _showEditDialog(topComments[i].id, topComments[i].text, topComments[i].timestamp),
                onDelete: () => _deleteComment(topComments[i].id, topComments[i].timestamp),
                onReply: () => _showReplyDialog(topComments[i].id, topComments[i].username),
                commentService: ref.read(commentServiceProvider),
                tmdbId: widget.tmdbId,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CommentTile extends ConsumerStatefulWidget {
  final CommentModel comment;
  final String? userId;
  final VoidCallback onToggleLike;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReply;
  final CommentService commentService;
  final int tmdbId;

  const _CommentTile({
    super.key,
    required this.comment,
    required this.userId,
    required this.onToggleLike,
    required this.onEdit,
    required this.onDelete,
    required this.onReply,
    required this.commentService,
    required this.tmdbId,
  });

  @override
  ConsumerState<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<_CommentTile> {
  bool _showReplies = false;
  late Stream<List<CommentModel>> _repliesStream;

  @override
  void initState() {
    super.initState();
    _repliesStream = widget.commentService.watchReplies(widget.tmdbId, widget.comment.id);
  }

  @override
  void didUpdateWidget(_CommentTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comment.id != oldWidget.comment.id || widget.tmdbId != oldWidget.tmdbId) {
      _repliesStream = widget.commentService.watchReplies(widget.tmdbId, widget.comment.id);
    }
  }

  Future<void> _confirmDeleteReply(String replyId, DateTime timestamp) async {
    if (isEditWindowExpired(timestamp)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solo puedes eliminar comentarios dentro de los primeros 15 minutos')),
        );
      }
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Deseas eliminar esta respuesta?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await widget.commentService.deleteComment(widget.tmdbId, replyId);
    }
  }

  void _showEditReplyDialog(String replyId, String currentText, DateTime timestamp) {
    if (isEditWindowExpired(timestamp)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solo puedes editar comentarios dentro de los primeros 15 minutos')),
        );
      }
      return;
    }
    final editController = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar respuesta'),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Escribe tu respuesta...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final newText = editController.text.trim();
              if (newText.isNotEmpty) {
                await widget.commentService.editComment(widget.tmdbId, replyId, newText);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = widget.comment;
    final isOwner = c.userId == widget.userId;
    final canEdit = isOwner && canModifyComment(c.timestamp);
    final canDelete = isOwner && canModifyComment(c.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: c.avatarUrl != null && c.avatarUrl!.isNotEmpty
                    ? NetworkImage(c.avatarUrl!)
                    : null,
                child: c.avatarUrl == null || c.avatarUrl!.isEmpty
                    ? Text(c.username.isNotEmpty ? c.username[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(c.username, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: cs.onSurface)),
                        const SizedBox(width: 8),
                        Text(_timeAgo(c.timestamp), style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                        if (c.editedAt != null) ...[
                          const SizedBox(width: 4),
                          Text('(editado)', style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(c.text, style: TextStyle(fontSize: 14, color: cs.onSurface)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        InkWell(
                          onTap: widget.onToggleLike,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                c.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: c.isLikedByCurrentUser ? Colors.red : cs.onSurfaceVariant,
                              ),
                              if (c.likeCount > 0) ...[
                                const SizedBox(width: 4),
                                Text('${c.likeCount}', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: widget.onReply,
                          child: Text('Responder', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                        ),
                        if (canEdit) ...[
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: widget.onEdit,
                            child: Icon(Icons.edit, size: 16, color: cs.onSurfaceVariant),
                          ),
                        ],
                        if (canDelete) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: widget.onDelete,
                            child: Icon(Icons.delete_outline, size: 16, color: Colors.red.withValues(alpha: 0.7)),
                          ),
                        ],
                        const Spacer(),
                        if (!_showReplies)
                          InkWell(
                            onTap: () => setState(() => _showReplies = true),
                            child: Text('Ver respuestas', style: TextStyle(fontSize: 12, color: cs.primary)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showReplies)
            StreamBuilder<List<CommentModel>>(
              stream: _repliesStream,
              builder: (context, snapshot) {
                final replies = snapshot.data ?? [];
                if (replies.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(left: 44, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: replies.map((reply) {
                      final isReplyOwner = reply.userId == widget.userId;
                      final canEditReply = isReplyOwner && canModifyComment(reply.timestamp);
                      final canDeleteReply = isReplyOwner && canModifyComment(reply.timestamp);
                      return Padding(
                        key: ValueKey(reply.id),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: reply.avatarUrl != null && reply.avatarUrl!.isNotEmpty
                                  ? NetworkImage(reply.avatarUrl!)
                                  : null,
                              child: reply.avatarUrl == null || reply.avatarUrl!.isEmpty
                                  ? Text(reply.username.isNotEmpty ? reply.username[0].toUpperCase() : '?',
                                      style: const TextStyle(fontSize: 11))
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(reply.username, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: cs.onSurface)),
                                      const SizedBox(width: 6),
                                      Text(_timeAgo(reply.timestamp), style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
                                      if (reply.editedAt != null) ...[
                                        const SizedBox(width: 4),
                                        Text('(editado)', style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant)),
                                      ],
                                      if (canEditReply || canDeleteReply)
                                        const Spacer(),
                                      if (canEditReply) ...[
                                        GestureDetector(
                                          onTap: () => _showEditReplyDialog(reply.id, reply.text, reply.timestamp),
                                          child: Icon(Icons.edit, size: 12, color: cs.onSurfaceVariant),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (canDeleteReply)
                                        GestureDetector(
                                          onTap: () => _confirmDeleteReply(reply.id, reply.timestamp),
                                          child: Icon(Icons.delete_outline, size: 12, color: Colors.red.withValues(alpha: 0.6)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(reply.text, style: TextStyle(fontSize: 13, color: cs.onSurface)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'ahora';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${diff.inDays ~/ 7}sem';
}
