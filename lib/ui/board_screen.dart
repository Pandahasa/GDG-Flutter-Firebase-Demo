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
  // TODO: STEP 3 - IMPLEMENT THE ADD NOTE FUNCTION
  //
  // When the FloatingActionButton is tapped, we need to create a
  // brand new document in the 'sticky_notes' Firestore collection.
  //
  // Use: _notesCollection.add(newNote.toJson())
  //
  // Steps:
  //   1. Get the screen size using MediaQuery.of(context).size
  //   2. Create a NoteModel with:
  //      - id: '' (Firestore auto-generates)
  //      - text: 'New Note 📝'
  //      - colorCode: ColorGenerator.randomColorCode()
  //      - xPos: ColorGenerator.randomX(size.width)
  //      - yPos: ColorGenerator.randomY(size.height)
  //   3. Call: await _notesCollection.add(newNote.toJson())
  // ============================================================
  Future<void> _addNote(BuildContext context) async {
    // YOUR CODE HERE
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
      // ============================================================
      // TODO: STEP 1 - DELETE THIS STATIC PLACEHOLDER LIST
      //
      // We are going to replace this static UI with a dynamic
      // Firebase StreamBuilder. The StreamBuilder will continuously
      // listen to our 'sticky_notes' collection using .snapshots().
      //
      // Why StreamBuilder instead of FutureBuilder?
      //   - A Future resolves data ONCE and stops.
      //   - A Stream keeps an OPEN CONNECTION and fires every time
      //     ANY document in the collection changes.
      //
      // Steps:
      //   1. Delete the static body below.
      //   2. Replace it with: StreamBuilder<QuerySnapshot>(
      //        stream: _notesCollection.snapshots(),
      //        builder: (context, snapshot) { ... }
      //      )
      //   3. Inside the builder:
      //      a. Handle loading: if snapshot.connectionState == waiting
      //      b. Handle errors: if snapshot.hasError
      //      c. Map docs: snapshot.data!.docs.map(NoteModel.fromFirestore)
      //      d. Return a Stack of StickyNote widgets
      // ============================================================
      body: Center(
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
              'Follow TODO: STEP 1 to connect the real-time stream!',
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ],
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
