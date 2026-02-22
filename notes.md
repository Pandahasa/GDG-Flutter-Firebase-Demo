# Notes

So it'll be neccesary to install the flutter vscode extension

# Commands to run to get firebase cli setup and flutterfire configured

brew install firebase-cli
firebase login
dart pub global activate flutterfire_cli
flutterfire configure

**Firebase Security Rules:**
`rules_version = '2';`
`service cloud.firestore {`
`  match /databases/{database}/documents {`
`    match /sticky_notes/{document=**} {`
`      allow read, write: if request.time < timestamp.date(2026, 02, 27);`
`    }`
`  }`
`}`