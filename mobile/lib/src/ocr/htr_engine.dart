import 'htr_result.dart';

/// A pluggable handwriting-recognition backend. The MVP (Phase 2) implements
/// this with ML Kit Text Recognition v2; the custom fine-tuned TrOCR model
/// (Phase 3/4) implements the same interface via ONNX Runtime Mobile so the
/// rest of the pipeline (SymSpell + context correction) doesn't change.
abstract class HtrEngine {
  Future<HtrResult> recognize(String imagePath);

  Future<void> dispose();
}
