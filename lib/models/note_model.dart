import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a single sticky note on the collaborative board.
///
/// Maps directly to a document in the 'sticky_notes' Firestore collection.
/// Handles serialization (toJson) and deserialization (fromFirestore) for
/// seamless NoSQL ↔ Dart object translation.
class NoteModel {
  final String id;
  final String text;
  final int colorCode;
  final double xPos;
  final double yPos;

  const NoteModel({
    required this.id,
    required this.text,
    required this.colorCode,
    required this.xPos,
    required this.yPos,
  });

  /// Creates a [NoteModel] from a Firestore [DocumentSnapshot].
  ///
  /// The document ID is extracted from the snapshot itself, while all other
  /// fields are pulled from the document's data map.
  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      text: data['text'] ?? '',
      colorCode: data['color_code'] ?? 0xFFFFEB3B,
      xPos: (data['x_pos'] ?? 100.0).toDouble(),
      yPos: (data['y_pos'] ?? 100.0).toDouble(),
    );
  }

  /// Converts this [NoteModel] into a JSON-compatible map for Firestore writes.
  ///
  /// Note: The document ID is NOT included in the map because Firestore
  /// assigns it automatically during the `add()` operation.
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'color_code': colorCode,
      'x_pos': xPos,
      'y_pos': yPos,
    };
  }
}
