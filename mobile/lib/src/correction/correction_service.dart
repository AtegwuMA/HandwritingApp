import 'package:flutter/services.dart' show rootBundle;

import 'symspell.dart';

/// Loads the bundled frequency dictionary once and exposes the fast
/// SymSpell correction pass. The context correction model (Phase 5/6) sits
/// in front of this pipeline stage later — this service stays as the fast,
/// always-available first pass even after that model is integrated.
class CorrectionService {
  final SymSpell _symSpell = SymSpell();
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final contents = await rootBundle.loadString(
      'assets/dictionaries/frequency_dictionary_en.txt',
    );
    _symSpell.loadDictionary(contents);
    _loaded = true;
  }

  Future<String> correct(String rawText) async {
    await ensureLoaded();
    return _symSpell.correctText(rawText);
  }
}
