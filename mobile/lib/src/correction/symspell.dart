/// A compact SymSpell implementation: dictionary lookup by precomputed
/// deletes, so correction is a hash lookup instead of an edit-distance scan
/// against the whole vocabulary. This is the "fast pass" in the pipeline —
/// it runs before the context correction model and catches simple
/// single/double-character recognition errors cheaply.
class SymSpell {
  final int maxEditDistance;
  final Map<String, int> _wordFrequency = {};
  final Map<String, Set<String>> _deletes = {};

  SymSpell({this.maxEditDistance = 2});

  int get vocabularySize => _wordFrequency.length;

  /// Loads a frequency dictionary of `word<TAB>count` lines (or
  /// `word,count`), one entry per line.
  void loadDictionary(String contents) {
    for (final rawLine in contents.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      final parts = line.contains('\t') ? line.split('\t') : line.split(',');
      if (parts.length < 2) continue;
      final word = parts[0].trim().toLowerCase();
      final count = int.tryParse(parts[1].trim());
      if (word.isEmpty || count == null) continue;
      _addWord(word, count);
    }
  }

  void _addWord(String word, int frequency) {
    _wordFrequency[word] = (_wordFrequency[word] ?? 0) + frequency;
    for (final deleteVariant in _deletesOf(word, maxEditDistance)) {
      _deletes.putIfAbsent(deleteVariant, () => {}).add(word);
    }
  }

  Set<String> _deletesOf(String word, int distance) {
    final results = <String>{word};
    var frontier = <String>{word};
    for (var d = 0; d < distance; d++) {
      final next = <String>{};
      for (final w in frontier) {
        for (var i = 0; i < w.length; i++) {
          final candidate = w.substring(0, i) + w.substring(i + 1);
          if (candidate.isNotEmpty && results.add(candidate)) {
            next.add(candidate);
          }
        }
      }
      if (next.isEmpty) break;
      frontier = next;
    }
    return results;
  }

  /// Returns the best correction for [word], or [word] itself if it's
  /// already known or no candidate is found within [maxEditDistance].
  String correct(String word) {
    final lower = word.toLowerCase();
    if (lower.isEmpty || _wordFrequency.containsKey(lower)) return word;

    final candidates = <String, int>{};
    for (final deleteVariant in _deletesOf(lower, maxEditDistance)) {
      final suggestions = _deletes[deleteVariant];
      if (suggestions == null) continue;
      for (final suggestion in suggestions) {
        final distance = _editDistance(lower, suggestion);
        if (distance <= maxEditDistance) {
          final freq = _wordFrequency[suggestion] ?? 0;
          candidates[suggestion] = freq;
        }
      }
    }

    if (candidates.isEmpty) return word;

    final best = candidates.entries.reduce(
      (a, b) => b.value > a.value ? b : a,
    );
    return _matchCase(word, best.key);
  }

  /// Corrects a whole line, word by word, preserving punctuation/spacing.
  String correctText(String text) {
    final wordPattern = RegExp(r"[A-Za-z']+");
    return text.replaceAllMapped(wordPattern, (m) => correct(m.group(0)!));
  }

  String _matchCase(String original, String corrected) {
    if (original.isEmpty) return corrected;
    if (original == original.toUpperCase()) return corrected.toUpperCase();
    if (original[0] == original[0].toUpperCase()) {
      return corrected[0].toUpperCase() + corrected.substring(1);
    }
    return corrected;
  }

  int _editDistance(String a, String b) {
    final dp = List.generate(
      a.length + 1,
      (_) => List.filled(b.length + 1, 0),
    );
    for (var i = 0; i <= a.length; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      dp[0][j] = j;
    }
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 +
              [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]]
                  .reduce((x, y) => x < y ? x : y);
        }
      }
    }
    return dp[a.length][b.length];
  }
}
