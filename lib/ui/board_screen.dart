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

  /// Creates a new sticky note document in Firestore with random position
  /// and color, using screen dimensions to keep it within bounds.
  Future<void> _addNote(BuildContext context) async {
    final size = MediaQuery.of(context).size;
    final newNote = NoteModel(
      id: '', // Firestore auto-generates the document ID
      text: 'New Note 📝',
      colorCode: ColorGenerator.randomColorCode(),
      xPos: ColorGenerator.randomX(size.width),
      yPos: ColorGenerator.randomY(size.height),
    );
    await _notesCollection.add(newNote.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📌 Collaborative Sticky Board',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // ─── Real-Time StreamBuilder ───────────────────────────────
      // The StreamBuilder continuously listens to the 'sticky_notes'
      // collection. Every time ANY connected user adds, moves, or
      // modifies a note, this builder fires and rebuilds the entire
      // Stack with updated positions.
      body: StreamBuilder<QuerySnapshot>(
        stream: _notesCollection.snapshots(),
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

          // If the collection is empty, show a helpful prompt
          if (notes.isEmpty) {
            return const Center(
              child: Text(
                'No notes yet!\nTap the + button to add one. 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            );
          }

          // Render all notes in a Stack using absolute positioning
          return Stack(
            children: notes.map((note) => StickyNote(note: note)).toList(),
          );
        },
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
