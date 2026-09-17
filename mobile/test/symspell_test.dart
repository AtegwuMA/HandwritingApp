import 'package:flutter_test/flutter_test.dart';
import 'package:handwriting_app/src/correction/symspell.dart';

void main() {
  test('corrects a single-edit-distance misspelling', () {
    final symSpell = SymSpell()..loadDictionary('the\t100\nworld\t80');
    expect(symSpell.correct('teh'), 'the');
    expect(symSpell.correct('wrld'), 'world');
  });

  test('leaves known words and out-of-range typos unchanged', () {
    final symSpell = SymSpell()..loadDictionary('the\t100');
    expect(symSpell.correct('the'), 'the');
    expect(symSpell.correct('zzzzzzzz'), 'zzzzzzzz');
  });

  test('preserves capitalization on correction', () {
    final symSpell = SymSpell()..loadDictionary('the\t100');
    expect(symSpell.correct('Teh'), 'The');
  });

  test('corrects whole sentences word by word', () {
    final symSpell = SymSpell()..loadDictionary('the\t100\nworld\t80\nhello\t60');
    expect(symSpell.correctText('helo teh wrld'), 'hello the world');
  });
}
