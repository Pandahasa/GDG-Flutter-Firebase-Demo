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

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // TODO: STEP 2 - WRAP THE CONTAINER WITH POSITIONED + GESTURE DETECTOR
    //
    // Right now _buildNoteCard() is returned directly with no positioning
    // or drag interaction. We need to:
    //
    //   1. Wrap it in a Positioned widget:
    //      Positioned(
    //        left: note.xPos,    ← maps to Firestore 'x_pos'
    //        top: note.yPos,     ← maps to Firestore 'y_pos'
    //        child: ...
    //      )
    //
    //   2. Inside Positioned, wrap _buildNoteCard() with GestureDetector:
    //      GestureDetector(
    //        onPanUpdate: (details) {
    //          // Calculate new coordinates from drag delta:
    //          final screen = MediaQuery.of(context).size;
    //          double newX = (note.xPos + details.delta.dx)
    //              .clamp(0.0, screen.width - 150);
    //          double newY = (note.yPos + details.delta.dy)
    //              .clamp(0.0, screen.height - 200);
    //
    //          // Push update to Firestore:
    //          _notesCollection.doc(note.id).update({
    //            'x_pos': newX,
    //            'y_pos': newY,
    //          });
    //        },
    //        child: _buildNoteCard(),
    //      )
    // ============================================================
    return _buildNoteCard();
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
          ),
          // Delete button (top-left)
          Positioned(
            top: 2,
            left: 2,
            child: GestureDetector(
              onTap: () => _notesCollection.doc(note.id).delete(),
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
