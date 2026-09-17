/// A single recognized word/token with a confidence score in [0, 1].
/// ML Kit doesn't expose per-word confidence directly, so the MVP derives a
/// proxy score from block/line structure; this is replaced with the real
/// per-token confidence once the custom ONNX HTR model lands (Phase 4).
class RecognizedToken {
  final String text;
  final double confidence;

  const RecognizedToken(this.text, this.confidence);
}

class HtrResult {
  final String fullText;
  final List<RecognizedToken> tokens;

  const HtrResult({required this.fullText, required this.tokens});

  bool get isEmpty => fullText.trim().isEmpty;
}
