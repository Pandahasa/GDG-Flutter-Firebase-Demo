import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/note_model.dart';
import '../../utils/color_generator.dart';

/// A single draggable sticky note rendered on the collaborative board.
///
/// Uses local state to track position during drags for smooth, 1:1 cursor
/// tracking. Syncs the final position to Firestore on drag end so all
/// connected clients see the updated location.
class StickyNote extends StatefulWidget {
  final NoteModel note;

  const StickyNote({super.key, required this.note});

  @override
  State<StickyNote> createState() => _StickyNoteState();
}

class _StickyNoteState extends State<StickyNote> {
  /// Reference to the Firestore collection for coordinate updates.
  static final _notesCollection =
      FirebaseFirestore.instance.collection('sticky_notes');

  /// Local position tracked during a drag for instant visual feedback.
  late double _localX;
  late double _localY;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _localX = widget.note.xPos;
    _localY = widget.note.yPos;
  }

  @override
  void didUpdateWidget(covariant StickyNote oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync from Firestore when NOT actively dragging
    if (!_isDragging) {
      _localX = widget.note.xPos;
      _localY = widget.note.yPos;
    }
  }

  void _onDragStart(DragStartDetails details) {
    _isDragging = true;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      _localX = (_localX + details.delta.dx).clamp(0.0, screenSize.width - 150);
      _localY =
          (_localY + details.delta.dy).clamp(0.0, screenSize.height - 200);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    // Push final position to Firestore
    _notesCollection.doc(widget.note.id).update({
      'x_pos': _localX,
      'y_pos': _localY,
    });
  }

  /// Shows a dialog to edit the note's text, then updates Firestore.
  void _editNote(BuildContext context) async {
    final controller = TextEditingController(text: widget.note.text);
    final newText = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          maxLength: 80,
          decoration: const InputDecoration(
            hintText: 'Update your message...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newText != null && newText.trim().isNotEmpty) {
      _notesCollection.doc(widget.note.id).update({'text': newText.trim()});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _localX,
      top: _localY,
      child: GestureDetector(
        onPanStart: _onDragStart,
        onPanUpdate: _onDragUpdate,
        onPanEnd: _onDragEnd,
        onDoubleTap: () => _editNote(context),
        child: _buildNoteCard(),
      ),
    );
  }

  /// Builds the visual sticky note card.
  ///
  /// A square container with a soft drop shadow, dynamic background color,
  /// and centered text label.
  Widget _buildNoteCard() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        children: [
          // Note body
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: ColorGenerator.fromCode(widget.note.colorCode),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text(
                widget.note.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          // Delete button (top-left)
          Positioned(
            top: 2,
            left: 2,
            child: GestureDetector(
              onTap: () => _notesCollection.doc(widget.note.id).delete(),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
