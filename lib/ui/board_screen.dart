import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  // ============================================================
  // TODO: STEP 5 — SORT NOTES BY CREATION TIME
  //
  // Right now notes appear in no particular order. After you've
  // completed STEP 3 (which saves a 'created_at' server timestamp
  // with each note), upgrade this getter to sort newest-first:
  //
  //   _notesCollection
  //       .orderBy('created_at', descending: true)
  //       .snapshots()
  //
  // This teaches Firestore QUERY COMPOSITION — you build queries
  // by chaining methods like .orderBy(), .where(), .limit(), etc.
  // ============================================================
  Stream<QuerySnapshot> get _notesStream => _notesCollection.snapshots();

  // ============================================================
  // TODO: STEP 3 — CREATE A NEW NOTE
  //
  // Show a dialog for the user to type a message, then create a
  // new Firestore document.
  //
  // Steps:
  //   1. Show an AlertDialog with a TextField (see STEP 4 for
  //      a similar dialog pattern in sticky_note.dart)
  //   2. If the user submits text, build a NoteModel:
  //      - id: '' (Firestore auto-generates)
  //      - text: the user's message
  //      - colorCode: ColorGenerator.randomColorCode()
  //      - xPos: ColorGenerator.randomX(size.width)
  //      - yPos: ColorGenerator.randomY(size.height)
  //   3. Write to Firestore with a server timestamp:
  //      await _notesCollection.add({
  //        ...newNote.toJson(),
  //        'created_at': FieldValue.serverTimestamp(),
  //      });
  //
  // FieldValue.serverTimestamp() stamps creation time on the
  // server, not the client — important for consistent ordering.
  //
  // Imports needed at the top of the file:
  //   import '../models/note_model.dart';
  //   import '../utils/color_generator.dart';
  // ============================================================
  Future<void> _addNote(BuildContext context) async {
    // YOUR CODE HERE
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
        // ============================================================
        // TODO: STEP 1 — CONNECT THE REAL-TIME STREAM
        //
        // Replace the static placeholder below with a StreamBuilder
        // that listens to Firestore and rebuilds the UI automatically.
        //
        //   StreamBuilder<QuerySnapshot>(
        //     stream: _notesStream,
        //     builder: (context, snapshot) { ... }
        //   )
        //
        // Inside the builder:
        //   a. Handle loading: snapshot.connectionState == waiting
        //   b. Handle errors: snapshot.hasError
        //   c. Map docs to models:
        //      snapshot.data!.docs
        //          .map((doc) => NoteModel.fromFirestore(doc)).toList()
        //   d. Return a Stack of StickyNote widgets
        //
        // Why StreamBuilder?
        //   A Future resolves ONCE. A Stream stays OPEN — every time
        //   any user changes any note, this builder fires again.
        //
        // Imports needed at the top of the file:
        //   import '../models/note_model.dart';
        // ============================================================
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 64, color: Colors.white54),
              SizedBox(height: 16),
              Text(
                'Static placeholder — no Firebase connection yet.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 8),
              Text(
                'Complete STEP 1 to connect the real-time stream!',
                style: TextStyle(fontSize: 14, color: Colors.white54),
              ),
            ],
          ),
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
