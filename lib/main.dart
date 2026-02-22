import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'ui/board_screen.dart';

/// Application entry point.
///
/// Initializes Firebase using the shared configuration from
/// [firebase_options.dart], then launches the collaborative board UI.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StickyBoardApp());
}

class StickyBoardApp extends StatelessWidget {
  const StickyBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticky Board',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.brown,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFC5A880), // Corkboard brown
      ),
      home: const BoardScreen(),
    );
  }
}
