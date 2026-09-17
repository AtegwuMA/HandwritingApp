import 'package:uuid/uuid.dart';

import 'correction/correction_service.dart';
import 'models/scan.dart';
import 'ocr/htr_engine.dart';
import 'preprocessing/image_preprocessor.dart';
import 'storage/scan_store.dart';

/// Runs the full offline pipeline for one captured image:
/// preprocess -> HTR -> SymSpell fast pass -> persist.
///
/// The context correction model (Phase 5/6) inserts between the SymSpell
/// pass and persistence; everything upstream and downstream of that stays
/// the same, which is why each stage is its own swappable component.
class HandwritingPipeline {
  final ImagePreprocessor _preprocessor;
  final HtrEngine _htrEngine;
  final CorrectionService _correctionService;
  final ScanStore _scanStore;
  final Uuid _uuid = const Uuid();

  HandwritingPipeline({
    required HtrEngine htrEngine,
    required CorrectionService correctionService,
    required ScanStore scanStore,
    ImagePreprocessor? preprocessor,
  })  : _htrEngine = htrEngine,
        _correctionService = correctionService,
        _scanStore = scanStore,
        _preprocessor = preprocessor ?? ImagePreprocessor();

  Future<Scan> run(String capturedImagePath) async {
    final preprocessedPath = await _preprocessor.process(capturedImagePath);
    final htrResult = await _htrEngine.recognize(preprocessedPath);
    final correctedText = await _correctionService.correct(
      htrResult.fullText,
    );

    final scan = Scan(
      id: _uuid.v4(),
      imagePath: preprocessedPath,
      rawText: htrResult.fullText,
      correctedText: correctedText,
      createdAt: DateTime.now(),
    );

    await _scanStore.save(scan);
    return scan;
  }
}
