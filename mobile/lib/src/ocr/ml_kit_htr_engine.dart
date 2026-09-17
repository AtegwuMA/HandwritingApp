import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'htr_engine.dart';
import 'htr_result.dart';

/// MVP HTR backend: ML Kit's on-device text recognizer. This is the
/// Phase 2 baseline the guide calls for before any custom model training —
/// it runs fully offline and needs no bundled model beyond what ML Kit ships.
class MlKitHtrEngine implements HtrEngine {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<HtrResult> recognize(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(input);

    final tokens = <RecognizedToken>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          // ML Kit doesn't return a confidence score for on-device text
          // recognition, so every token gets a neutral placeholder score.
          // The fast SymSpell pass and the context model both work fine
          // without real confidence; the review UI's highlighting becomes
          // meaningful once the custom HTR model supplies real scores.
          tokens.add(RecognizedToken(element.text, 0.5));
        }
      }
    }

    return HtrResult(fullText: result.text, tokens: tokens);
  }

  @override
  Future<void> dispose() => _recognizer.close();
}
