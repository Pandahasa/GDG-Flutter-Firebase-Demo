import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../utils/color_generator.dart';
import 'widgets/sticky_note.dart';

/// The main collaborative bulletin board screen.
///
/// Renders a [Stack] of [StickyNote] widgets whose positions and data are
/// driven in real-time by a Firestore [StreamBuilder].
///
/// The [FloatingActionButton] allows any connected user to spawn a new
/// sticky note into the shared 'sticky_notes' collection.
class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  /// Reference to the shared Firestore collection.
  static final _notesCollection =
      FirebaseFirestore.instance.collection('sticky_notes');

  /// Sorted stream — newest notes appear on top of the stack.
  Stream<QuerySnapshot> get _notesStream =>
      _notesCollection.orderBy('created_at', descending: true).snapshots();

  /// Shows a dialog for the user to type a custom note message,
  /// then creates a new sticky note document in Firestore.
  Future<void> _addNote(BuildContext context) async {
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Sticky Note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          maxLength: 80,
          decoration: const InputDecoration(
            hintText: 'Write your message...',
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
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (message == null || message.trim().isEmpty) return;

    final size = MediaQuery.of(context).size;
    final newNote = NoteModel(
      id: '',
      text: message.trim(),
      colorCode: ColorGenerator.randomColorCode(),
      xPos: ColorGenerator.randomX(size.width),
      yPos: ColorGenerator.randomY(size.height),
    );
    await _notesCollection.add({
      ...newNote.toJson(),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar — the board IS the entire screen
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/board_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _notesStream,
          builder: (context, snapshot) {
            // Handle loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Handle error state
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            // Map Firestore documents to NoteModel objects
            final notes = snapshot.data!.docs
                .map((doc) => NoteModel.fromFirestore(doc))
                .toList();

            return Stack(
              children: [
                // Empty-state prompt
                if (notes.isEmpty)
                  const Center(
                    child: Text(
                      'Tap + to pin your first note!',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(blurRadius: 4, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                // Render all notes using absolute positioning
                ...notes.map((note) => StickyNote(note: note)),
              ],
            );
          },
        ),
      ),
      // ─── Floating Action Button ────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNote(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
        backgroundColor: Colors.amber,
      ),
    );
  }
}
