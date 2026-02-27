# Presenter Notes — Real-Time Collaborative Sticky Board

## Pre-Workshop Setup

### Student Prerequisites (send 1 week before)

- Flutter SDK 3.19+ installed and on PATH
- VS Code with extensions: `Dart-Code.flutter`, `Dart-Code.dart-code`
- Chrome browser
- Git CLI
- **No Firebase account needed**

### Presenter Checklist

- [ ] Firebase project created (Analytics disabled)
- [ ] Cloud Firestore provisioned (nearest region)
- [ ] Security rules deployed (see below)
- [ ] `flutterfire configure` run (Web only)
- [ ] `firebase_options.dart` committed and pushed
- [ ] Both branches pushed: `main` (starter) and `solution-complete`

### Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /sticky_notes/{document=**} {
      allow read, write: if request.time < timestamp.date(2026, 02, 27);
    }
  }
}
```

---

## Opening (0:00–5:00)

- Display repo URL on projector
- Students run:
  ```
  git clone <REPO_URL>
  cd GDG-Flutter-Firebase-Demo
  flutter pub get
  flutter run -d chrome
  ```
- They'll see a corkboard background with a static placeholder message
- Walk the floor, verify screens. Anyone stuck → pair up.

## Architecture Tour (5:00–10:00)

> **Say:** "Before we write any code, let's understand the architecture. Every single one of you is connected to the same Firestore database right now. When you change something, it pushes to the cloud, and the cloud pushes it to everyone else — instantly. There's no polling, no refresh button. That's the power of real-time streams."

- Whiteboard: **Firestore ↔ Stream ↔ Flutter UI**
- Open `main.dart` → `Firebase.initializeApp`
- Open `firebase_options.dart` → "connects everyone to the same DB"
- Open `note_model.dart` → `fromFirestore` / `toJson`
- Open `sticky_note.dart` → "drag is already built for you"

---

## STEP 1 — StreamBuilder (10:00–20:00) — READ

> **Say:** "This is the most important step. We're going to replace that static placeholder with a live connection to Firebase. In traditional apps you'd fetch data once and manually refresh — with StreamBuilder, the UI rebuilds itself every time the data changes. This is what makes Firebase feel like magic. One widget, and your entire app becomes real-time."
>
> **Teaches:** `StreamBuilder` widget, snapshot states (waiting/error/data), Firestore `.snapshots()` real-time listener, mapping raw documents to Dart objects.

**File:** `lib/ui/board_screen.dart`

> "Search for STEP 1"

Add imports at the top:

```dart
import '../models/note_model.dart';
```

Delete the `Center(child: Column(...))` placeholder and replace with:

```dart
// StreamBuilder listens to a Firestore stream and rebuilds the UI on every change
child: StreamBuilder<QuerySnapshot>(
  stream: _notesStream, // the live stream from our Firestore collection
  builder: (context, snapshot) {
    // while the first batch of data is loading, show a spinner
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    // if something went wrong with the connection, show the error
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    // convert each raw Firestore document into our NoteModel dart object
    final notes = snapshot.data!.docs
        .map((doc) => NoteModel.fromFirestore(doc))
        .toList();

    // Stack lets us layer widgets on top of each other with absolute positioning
    return Stack(
      children: [
        // show a hint message when the board is empty
        if (notes.isEmpty)
          const Center(
            child: Text(
              'Tap + to pin your first note!',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ),
        // spread all notes into the Stack — each StickyNote positions itself
        ...notes.map((note) => StickyNote(note: note)),
      ],
    );
  },
),
```

**Key concepts:** Stream vs Future. `.snapshots()` keeps a live connection open. Every time ANY document changes, the builder fires. Demo by creating a doc in Firebase Console — it appears instantly.

---

## STEP 2 — Delete a Note (20:00–25:00) — DELETE

> **Say:** "Now let's see how easy it is to remove data. This is literally one line of code. But the important thing to notice is what you DON'T have to do — you don't remove it from a list, you don't call setState, you don't refresh the page. You delete the document in Firestore, and the StreamBuilder we just built handles the rest. That's the reactive pattern."
>
> **Teaches:** Firestore `.delete()` operation, reactive UI updates — demonstrating that the StreamBuilder from STEP 1 automatically reflects data changes without manual state management.

**File:** `lib/ui/widgets/sticky_note.dart`

> "Search for STEP 2"

Inside the `onTap: () { }` of the X button, add one line:

```dart
// grab the document by its ID and delete it — StreamBuilder handles the UI update
_notesCollection.doc(widget.note.id).delete();
```

**Key concept:** One line deletes the Firestore document. The StreamBuilder from STEP 1 automatically removes it from everyone's screen — no manual state management.

---

## STEP 3 — Add a Note (25:00–33:00) — CREATE

> **Say:** "Now we complete the loop — we can read and delete, but we need to create. We'll show a dialog to collect the user's message, build a data model, and push it to Firestore. Notice we're also adding a server timestamp — this is important because it uses Firebase's server clock, not whatever time is on your laptop. That makes it reliable for sorting later, which we'll do in STEP 5."
>
> **Teaches:** `showDialog` + `Navigator.pop` pattern for user input, Firestore `.add()` for creating documents with auto-generated IDs, `FieldValue.serverTimestamp()` for server-authoritative timestamps, model serialization with `.toJson()`.

**File:** `lib/ui/board_screen.dart`

> "Search for STEP 3"

Add imports at the top:

```dart
import '../models/note_model.dart';
import '../utils/color_generator.dart';
```

Replace `// YOUR CODE HERE` inside `_addNote` with:

```dart
// create a controller to capture what the user types
final controller = TextEditingController();
// showDialog pauses execution and waits for the user to submit or cancel
final message = await showDialog<String>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('New Sticky Note'),
    content: TextField(
      controller: controller, // binds the text field to our controller
      autofocus: true, // keyboard opens immediately
      maxLines: 3,
      maxLength: 80, // limit to keep notes short
      decoration: const InputDecoration(
        hintText: 'Write your message...',
        border: OutlineInputBorder(),
      ),
    ),
    actions: [
      // Cancel — pops the dialog returning null (no value)
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      // Add — pops the dialog returning the typed text
      FilledButton(
        onPressed: () => Navigator.pop(context, controller.text),
        child: const Text('Add'),
      ),
    ],
  ),
);

// if user cancelled or typed nothing, bail out
if (message == null || message.trim().isEmpty) return;

// get screen dimensions so we can place the note randomly within bounds
final size = MediaQuery.of(context).size;
// build our data model with random color and position
final newNote = NoteModel(
  id: '', // Firestore will auto-generate the document ID
  text: message.trim(),
  colorCode: ColorGenerator.randomColorCode(), // pick a random pastel color
  xPos: ColorGenerator.randomX(size.width), // random x within screen
  yPos: ColorGenerator.randomY(size.height), // random y within screen
);
// write to Firestore — .add() creates a new document with auto ID
await _notesCollection.add({
  ...newNote.toJson(), // spread the model fields into the map
  'created_at': FieldValue.serverTimestamp(), // server clock, not client — reliable for sorting
});
```

**Key concepts:** `showDialog` + `Navigator.pop` to collect input. `.add()` creates a new doc with auto-ID. `FieldValue.serverTimestamp()` stamps creation time on the server (not client clock) — we'll use this in STEP 5.

---

## STEP 4 — Edit Note Text (33:00–39:00) — UPDATE

> **Say:** "We can create and delete — now let's modify existing data. The key difference here is `.add()` vs `.update()`. Add creates a brand new document. Update takes an existing document by its ID and changes specific fields — it doesn't overwrite the whole thing. Also notice we're reusing the same dialog pattern from STEP 3, just pre-filling the text field. In real apps, you reuse UI building blocks like this all the time."
>
> **Teaches:** Firestore `.doc(id).update()` for partial document updates vs `.add()` for creation, `TextEditingController` pre-filled with existing data, `GestureDetector.onDoubleTap` for secondary interactions.

**File:** `lib/ui/widgets/sticky_note.dart`

> "Search for STEP 4"

Add this method above `build()`:

```dart
void _editNote(BuildContext context) async {
  // pre-fill the controller with the note's current text so user can edit it
  final controller = TextEditingController(text: widget.note.text);
  // same dialog pattern as STEP 3, but for editing instead of creating
  final newText = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Note'),
      content: TextField(
        controller: controller, // starts with existing text already in the field
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
          onPressed: () => Navigator.pop(context), // cancel — returns null
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text), // save — returns new text
          child: const Text('Save'),
        ),
      ],
    ),
  );

  // only update if user actually typed something
  if (newText != null && newText.trim().isNotEmpty) {
    // .update() modifies ONLY the 'text' field — doesn't touch position or color
    _notesCollection.doc(widget.note.id).update({'text': newText.trim()});
  }
}
```

Then add to the GestureDetector in `build()`:

```dart
// double-tap triggers the edit dialog — onTap is already used by the delete button
onDoubleTap: () => _editNote(context),
```

**Key concept:** `.add()` creates new docs, `.doc(id).update()` modifies existing ones. The dialog reuses the same pattern from STEP 3 but with a pre-filled controller.

---

## STEP 5 — Sort by Timestamp (39:00–42:00) — QUERY

> **Say:** "This is a one-line change but it teaches a big concept. Firestore queries are composable — you chain methods like `.orderBy()`, `.where()`, and `.limit()` to build exactly the query you need. And because we're still using `.snapshots()` at the end, the sorted stream stays live. The timestamps we saved in STEP 3 now pay off — newest notes render on top."
>
> **Teaches:** Firestore query composition with `.orderBy()`, the difference between an unordered collection stream and a sorted query stream, how server timestamps enable reliable cross-client ordering.

**File:** `lib/ui/board_screen.dart`

> "Search for STEP 5"

Change the `_notesStream` getter from:

```dart
// currently just gets all docs in no particular order
Stream<QuerySnapshot> get _notesStream => _notesCollection.snapshots();
```

to:

```dart
// chain .orderBy() to sort — descending: true puts newest first
// the stream stays live, so new notes automatically slot into the right position
Stream<QuerySnapshot> get _notesStream =>
    _notesCollection.orderBy('created_at', descending: true).snapshots();
```

**Key concept:** Firestore queries are built by chaining — `.orderBy()`, `.where()`, `.limit()`. The stream auto-updates with the new sort. Notes created in STEP 3 have `created_at` timestamps, so they'll now sort newest-first.

---

## Wrap-Up (42:00–45:00)

> **Say:** "In 35 minutes you built a full CRUD app with real-time sync across every device in this room. No REST APIs, no WebSockets, no state management library — just StreamBuilder and five Firestore methods. That's Read, Delete, Create, Update, and Query. This same pattern scales to chat apps, dashboards, collaborative tools — anything where multiple users need to see the same data change in real time."

- Recap the 5 operations: Read (StreamBuilder) → Delete → Create → Update → Query
- "You just built full CRUD with real-time sync in 35 minutes"
- Share `solution-complete` branch for anyone who fell behind
- Remind: Firestore rules expire tomorrow — database locks automatically
- After workshop: delete the Firebase project for cleanup
