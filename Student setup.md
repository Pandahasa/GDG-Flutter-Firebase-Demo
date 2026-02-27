# Pre-Workshop Setup Guide

Complete these steps **before** the workshop so we can jump straight into coding.

---

## 1. Install Flutter SDK

Download and install Flutter **3.19 or newer** for your OS:

👉 [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

After installing, open a terminal and verify:

```
flutter --version
```

You should see version 3.19.0 or higher. Then run:

```
flutter doctor
```

Fix any issues marked with ✗. You only need the **Chrome** row to pass — we're building for web.

---

## 2. Install VS Code

Download from [https://code.visualstudio.com](https://code.visualstudio.com) if you don't have it already.

---

## 3. Install VS Code Extensions

Open VS Code and install these two extensions:

- **Flutter** — search `Dart-Code.flutter` in the Extensions panel
- **Dart** — search `Dart-Code.dart-code` (usually installed automatically with Flutter)

Or install from the terminal:

```
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

---

## 4. Install Git

Download from [https://git-scm.com/downloads](https://git-scm.com/downloads) if you don't have it.

Verify:

```
git --version
```

---

## 5. Clone the Workshop Repository

We'll do this together at the start of the workshop, but feel free to do it early:

```
git clone https://github.com/Pandahasa/GDG-Flutter-Firebase-Demo
cd GDG-Flutter-Firebase-Demo
flutter pub get
```

---

## 6. Test Run

Make sure everything works:

```
flutter run -d chrome
```

You should see a corkboard background with a placeholder message. If this loads, you're all set!

Press `q` in the terminal to quit.

## Troubleshooting

| Problem                 | Fix                                                        |
| ----------------------- | ---------------------------------------------------------- |
| `flutter` not found     | Add Flutter's `bin` folder to your system PATH (see below) |
| `flutterfire` not found | Add the Dart pub global bin to your PATH (see below)       |
| Chrome not detected     | Set `CHROME_EXECUTABLE` env variable to your Chrome path   |
| `flutter pub get` fails | Check your internet connection and retry                   |
| Build errors on run     | Run `flutter clean` then `flutter pub get` again           |

### Fixing "command not found" on macOS (`.zshrc`)

macOS uses **zsh** as the default shell. If you get `flutter: command not found` or `flutterfire: command not found`, you need to add them to your PATH via `~/.zshrc`.

1. Open your `.zshrc` in a text editor:

   ```
   open ~/.zshrc
   ```

   If the file doesn't exist yet, create it:

   ```
   touch ~/.zshrc && open ~/.zshrc
   ```

2. Add the following lines at the bottom (adjust the Flutter path to where you installed it):

   ```bash
   # Flutter SDK
   export PATH="$HOME/development/flutter/bin:$PATH"

   # Dart pub global packages (needed for flutterfire_cli)
   export PATH="$HOME/.pub-cache/bin:$PATH"
   ```

   > **Tip:** If you installed Flutter somewhere else (e.g. `/Users/yourname/flutter`), replace `$HOME/development/flutter` with your actual path. You can find it by running `which flutter` in a terminal where Flutter already works, or checking where you unzipped it.

3. Save the file, then reload it:

   ```
   source ~/.zshrc
   ```

4. Verify the commands work:

   ```
   flutter --version
   dart --version
   ```

If you're stuck, don't worry — we'll help sort it out at the start of the workshop.

---

## (Optional) Set Up Your Own Firebase Project

Want to keep building after the workshop? The shared Firebase project will expire, so here's how to replace it with your own.

### A. Create a Firebase Project

1. Go to [https://console.firebase.google.com](https://console.firebase.google.com) and sign in with a Google account
2. Click **Add project**
3. Name it whatever you like (e.g. `my-sticky-board`)
4. Disable Google Analytics (not needed) → **Create project**

### B. Enable Cloud Firestore

1. In the Firebase Console, click **Build → Firestore Database** in the left sidebar
2. Click **Create database**
3. Choose the region closest to you (e.g. `us-central1`, `europe-west1`)
4. Select **Start in test mode** → **Create**

The default test mode rules allow all reads and writes for 30 days — that's plenty for experimenting.

### C. Install the Firebase CLI & FlutterFire CLI

```
# Install Firebase CLI (requires Node.js)
npm install -g firebase-tools

# Log in
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### D. Connect Your Project

From the project root folder, run:

```
flutterfire configure
```

When prompted:

1. Select your Firebase project from the list
2. For platforms, select **Web** only (deselect everything else)

This will overwrite `lib/firebase_options.dart` with your project's config. That's the only file that changes.

### E. Verify

```
flutter run -d chrome
```

Your app should now connect to your own Firestore. Add a note and check the Firebase Console → **Firestore Database → Data** to confirm you see documents in the `sticky_notes` collection.

### File Reference

| File                              | Purpose                                                           |
| --------------------------------- | ----------------------------------------------------------------- |
| `lib/firebase_options.dart`       | Auto-generated Firebase config — connects the app to your project |
| `lib/models/note_model.dart`      | Data model — maps Firestore documents to Dart objects             |
| `lib/ui/board_screen.dart`        | Main screen — StreamBuilder, add note, query                      |
| `lib/ui/widgets/sticky_note.dart` | Single note widget — drag, delete, edit                           |
| `lib/utils/color_generator.dart`  | Random pastel colors for notes                                    |
