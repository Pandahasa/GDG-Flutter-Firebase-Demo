import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/note_model.dart';
import '../../utils/color_generator.dart';

/// A single draggable sticky note rendered on the collaborative board.
///
/// Wrapped in a [Positioned] widget to place it at the exact (x, y)
/// coordinates stored in Firestore, and a [GestureDetector] to capture
/// drag events and synchronize position updates back to the database.
class StickyNote extends StatelessWidget {
  final NoteModel note;

  const StickyNote({super.key, required this.note});

  /// Reference to the Firestore collection for coordinate updates.
  static final _notesCollection =
      FirebaseFirestore.instance.collection('sticky_notes');

  /// Handles the continuous drag event.
  ///
  /// Calculates new coordinates from the drag delta and fires an update
  /// to Firestore. Every connected client's [StreamBuilder] will pick up
  /// the new position instantly.
  void _onDrag(DragUpdateDetails details, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Calculate new position from drag delta
    double newX = note.xPos + details.delta.dx;
    double newY = note.yPos + details.delta.dy;

    // Clamp coordinates to prevent the note from being dragged off-canvas
    newX = newX.clamp(0.0, screenSize.width - 150);
    newY = newY.clamp(0.0, screenSize.height - 200);

    // Push the updated coordinates to Firestore
    _notesCollection.doc(note.id).update({
      'x_pos': newX,
      'y_pos': newY,
    });
  }

  @override
  Widget build(BuildContext context) {
    // ─── Positioned + GestureDetector Wrapper ──────────────────
    // The Positioned widget maps the Firestore x_pos/y_pos fields
    // directly to the 'left' and 'top' properties of the Stack.
    // The GestureDetector captures drag input via onPanUpdate.
    return Positioned(
      left: note.xPos,
      top: note.yPos,
      child: GestureDetector(
        onPanUpdate: (details) => _onDrag(details, context),
        child: _buildNoteCard(),
      ),
    );
  }

  /// Builds the visual sticky note card.
  ///
  /// A square container with a soft drop shadow, dynamic background color,
  /// and centered text label.
  Widget _buildNoteCard() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: ColorGenerator.fromCode(note.colorCode),
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
          note.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
