# Handwriting App (Flutter)

Phase 2 MVP: camera/gallery capture -> ML Kit Text Recognition v2 -> SymSpell
fast-pass correction -> review/edit UI -> local storage (sqflite). Fully
offline; no network calls anywhere in this pipeline.

## First-time setup

This directory was hand-scaffolded (Flutter SDK isn't installed on the
machine that generated it), so the `android/` and `ios/` platform folders
don't exist yet. Run once, from `mobile/`:

```bash
flutter create . --project-name handwriting_app --org com.example
flutter pub get
```

`flutter create .` will not overwrite `lib/`, `pubspec.yaml`, or `test/` —
it only fills in the missing platform scaffolding.

## Permissions to add after `flutter create .`

**Android** (`android/app/src/main/AndroidManifest.xml`), inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

**iOS** (`ios/Runner/Info.plist`), inside the top-level `<dict>`:

```xml
<key>NSCameraUsageDescription</key>
<string>Used to scan handwritten pages.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to import photos of handwritten pages.</string>
```

## Running

```bash
flutter run
```

## Testing

```bash
flutter test
```

## Architecture notes

- `src/preprocessing/` — grayscale/contrast/binarize before recognition.
  Deskew is deferred (see code comment) to the custom HTR phase.
- `src/ocr/` — `HtrEngine` is the swappable interface; `MlKitHtrEngine` is
  the Phase 2 baseline. The Phase 3/4 custom ONNX model implements the same
  interface via `onnxruntime` Flutter bindings, so `pipeline.dart` doesn't
  change when that lands.
- `src/correction/` — SymSpell fast pass. The bundled
  `assets/dictionaries/frequency_dictionary_en.txt` is a small starter list;
  swap in the full SymSpell `frequency_dictionary_en_82_765.txt` (or a
  domain-specific one) before shipping.
- `src/storage/` — sqflite-backed local persistence (stands in for the
  Kotlin/Room store in the original architecture doc).
- `pipeline.dart` — wires preprocessing -> HTR -> correction -> storage.
  The context correction model (Phase 5/6) inserts between the SymSpell
  pass and storage without touching the other stages.
