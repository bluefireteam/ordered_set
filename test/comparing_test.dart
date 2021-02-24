import 'package:test/test.dart';
import 'package:ordered_set/ordered_set.dart';
import 'package:ordered_set/comparing.dart';

import 'comparable_object.dart';

void main() {
  group('Comparing', () {
    group('#on', () {
      test('simple comparison test', () {
        final byLength = Comparing.on<String>((a) => a.length);
        expect(byLength('a', 'aa'), -1);
        expect(byLength('aaa', 'aa'), 1);
        expect(byLength('aa', 'aa'), 0);
      });
      test('list sorting test', () {
        const phrase = 'The quick brown fox jumps over the lazy dog';
        final words = phrase.split(' ');
        words.sort(Comparing.on((a) => a.length));
        expect(words, [
          'The',
          'fox',
          'the',
          'dog',
          'over',
          'lazy',
          'quick',
          'brown',
          'jumps',
        ]);
      });
      test('using complex object', () {
        final set = OrderedSet<ComparableObject>(Comparing.on((o) => o.name));
        set.add(ComparableObject(0, 'd'));
        set.add(ComparableObject(1, 'b'));
        set.add(ComparableObject(2, 'a'));
        set.add(ComparableObject(3, 'c'));
        expect(set.toList().join(), 'abcd');
      });
    });

    group('#reverse', () {
      test('from regular comparator', () {
        int intComparator(int a, int b) => a - b;
        expect(intComparator(0, 10).sign, -1);

        expect(Comparing.reverse(intComparator)(0, 10).sign, 1);
        expect(Comparing.reverse(intComparator)(10, 0).sign, -1);
        expect(Comparing.reverse(intComparator)(0, 0).sign, 0);
      });

      test('from on', () {
        final c = Comparing.reverse<ComparableObject>(
          Comparing.on((t) => t.name),
        );
        final set = OrderedSet(c);
        set.add(ComparableObject(0, 'd'));
        set.add(ComparableObject(1, 'b'));
        set.add(ComparableObject(2, 'a'));
        set.add(ComparableObject(3, 'c'));
        expect(set.toList().join(), 'dcba');
      });
    });

    group('#join', () {
      test('second level comparison', () {
        final c = Comparing.join<ComparableObject>([
          (ComparableObject t) => t.priority,
          (ComparableObject t) => t.name,
        ]);
        final set = OrderedSet(c);
        set.add(ComparableObject(1, 'b'));
        set.add(ComparableObject(0, 'b'));
        set.add(ComparableObject(3, 'a'));
        set.add(ComparableObject(0, 'c'));
        set.add(ComparableObject(2, 'a'));
        set.add(ComparableObject(3, 'b'));
        set.add(ComparableObject(3, 'c'));
        set.add(ComparableObject(1, 'a'));
        set.add(ComparableObject(0, 'a'));
        expect(
          set.map((e) => '${e.priority}${e.name}').toList().join(),
          '0a0b0c1a1b2a3a3b3c',
        );
      });
    });
  });
}
