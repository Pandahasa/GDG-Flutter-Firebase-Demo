import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/note_model.dart';
import '../../utils/color_generator.dart';

/// A single draggable sticky note rendered on the collaborative board.
///
/// Drag behavior is fully implemented — notes track the cursor locally
/// and sync their final position to Firestore when the drag ends.
class StickyNote extends StatefulWidget {
  final NoteModel note;

  const StickyNote({super.key, required this.note});

  @override
  State<StickyNote> createState() => _StickyNoteState();
}

class _StickyNoteState extends State<StickyNote> {
  /// Reference to the Firestore collection for updates.
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
      _localX =
          (_localX + details.delta.dx).clamp(0.0, screenSize.width - 150);
      _localY =
          (_localY + details.delta.dy).clamp(0.0, screenSize.height - 200);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    _notesCollection.doc(widget.note.id).update({
      'x_pos': _localX,
      'y_pos': _localY,
    });
  }

  // ============================================================
  // TODO: STEP 4 — EDIT NOTE TEXT
  //
  // Create an _editNote(BuildContext context) method that:
  //   1. Shows an AlertDialog with a TextField pre-filled with
  //      the current text: TextEditingController(text: widget.note.text)
  //   2. On submit, updates only the 'text' field in Firestore:
  //      _notesCollection.doc(widget.note.id).update({
  //        'text': newText.trim(),
  //      });
  //
  // This teaches .update() on an EXISTING document:
  //   .add(data)          → creates doc with auto-generated ID
  //   .doc(id).update()   → modifies specific fields on existing doc
  //
  // Then wire it in the build() method below:
  //   onDoubleTap: () => _editNote(context),
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _localX,
      top: _localY,
      child: GestureDetector(
        onPanStart: _onDragStart,
        onPanUpdate: _onDragUpdate,
        onPanEnd: _onDragEnd,
        // TODO: STEP 4 — add onDoubleTap here to call your _editNote method
        child: _buildNoteCard(),
      ),
    );
  }

  /// Builds the visual sticky note card.
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
          // ============================================================
          // TODO: STEP 2 — DELETE A NOTE
          //
          // The X button is built below, but its onTap does nothing.
          // Replace the empty function body with ONE line:
          //
          //   _notesCollection.doc(widget.note.id).delete()
          //
          // That's it! Firestore removes the document and the
          // StreamBuilder (STEP 1) automatically updates everyone's
          // screen — no manual refresh needed.
          // ============================================================
          Positioned(
            top: 2,
            left: 2,
            child: GestureDetector(
              onTap: () {
                // grab the document by its ID and delete it — StreamBuilder handles the UI update
                _notesCollection.doc(widget.note.id).delete();
              },
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
