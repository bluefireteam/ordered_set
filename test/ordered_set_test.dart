import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';
import 'package:test/test.dart';

import 'comparable_object.dart';

void main() {
  group('OrderedSet', () {
    group('#removeWhere', () {
      test('remove single element', () {
        final a = OrderedSet<int>();
        expect(a.addAll([7, 4, 3, 1, 2, 6, 5]), 7);
        expect(a.length, 7);
        expect(a.removeWhere((e) => e == 3).length, 1);
        expect(a.length, 6);
        expect(a.toList().join(), '124567');
      });

      test('remove with property', () {
        final a = OrderedSet<int>();
        expect(a.addAll([7, 4, 3, 1, 2, 6, 5]), 7);
        expect(a.removeWhere((e) => e.isOdd).length, 4);
        expect(a.length, 3);
        expect(a.toList().join(), '246');
      });

      test('remove when element has changed', () {
        final a = OrderedSet<ComparableObject>();

        final e1 = ComparableObject(1, 'e1');
        final e2 = ComparableObject(1, 'e2');
        final e3 = ComparableObject(2, 'e3');
        final e4 = ComparableObject(2, 'e4');

        a.addAll([e1, e2, e3, e4]);
        e1.priority = 2;
        // no rebalance! note that this is a broken state until rebalance is
        // called.
        expect(a.remove(e1), isTrue);
        expect(a.toList().join(), 'e2e3e4');
      });

      test('remove returns the removed elements', () {
        final a = OrderedSet<int>();
        a.addAll([7, 4, 3, 1, 2, 6, 5]);
        final removed = a.removeWhere((e) => e <= 2);
        expect(removed.length, 2);
        expect(removed.toList().join(), '12');
      });

      test('remove from same group and different groups', () {
        final a = OrderedSet<ComparableObject>();
        expect(a.add(ComparableObject(0, 'a1')), isTrue);
        expect(a.add(ComparableObject(0, 'a2')), isTrue);
        expect(a.add(ComparableObject(0, 'b1')), isTrue);
        expect(a.add(ComparableObject(1, 'a3')), isTrue);
        expect(a.add(ComparableObject(1, 'b2')), isTrue);
        expect(a.add(ComparableObject(1, 'b3')), isTrue);
        expect(a.add(ComparableObject(2, 'a4')), isTrue);
        expect(a.add(ComparableObject(2, 'b4')), isTrue);
        expect(a.removeWhere((e) => e.name.startsWith('a')).length, 4);
        expect(a.length, 4);
        expect(a.toList().join(), 'b1b2b3b4');
      });

      test('remove all', () {
        final a = OrderedSet<ComparableObject>();
        expect(a.add(ComparableObject(0, 'a1')), isTrue);
        expect(a.add(ComparableObject(0, 'a2')), isTrue);
        expect(a.add(ComparableObject(0, 'b1')), isTrue);
        expect(a.add(ComparableObject(1, 'a3')), isTrue);
        expect(a.add(ComparableObject(1, 'b2')), isTrue);
        expect(a.add(ComparableObject(1, 'b3')), isTrue);
        expect(a.add(ComparableObject(2, 'a4')), isTrue);
        expect(a.add(ComparableObject(2, 'b4')), isTrue);
        expect(a.removeWhere((e) => true).length, 8);
        expect(a.length, 0);
        expect(a.toList().join(), '');
      });
    });

    group('#removeAt', () {
      test('removes the element at index', () {
        final a = OrderedSet<int>();
        a.addAll([1, 2, 3, 4, 5, 6]);
        expect(a.length, 6);
        expect(a.removeAt(3), isTrue);
        expect(a.length, 5);
        expect(a.contains(4), isFalse);
      });

      test('does not remove non-existing index', () {
        final a = OrderedSet<int>();
        a.addAll([1, 2, 3, 4, 5, 6]);
        expect(a.length, 6);
        expect(() => a.removeAt(7), throwsRangeError);
        expect(a.length, 6);
      });
    });

    group('#clear', () {
      test('removes all and updates length', () {
        final a = OrderedSet<int>();
        expect(a.addAll([1, 2, 3, 4, 5, 6]), 6);
        a.clear();
        expect(a.length, 0);
        expect(a.toList().length, 0);
      });
    });

    group('#addAll', () {
      test('maintains order', () {
        final a = OrderedSet<int>();
        expect(a.length, 0);
        expect(a.addAll([7, 4, 3, 1, 2, 6, 5]), 7);
        expect(a.length, 7);
        expect(a.toList().join(), '1234567');
      });

      test('with repeated priority elements', () {
        final a = OrderedSet<int>((a, b) => (a % 2) - (b % 2));
        expect(a.addAll([7, 4, 3, 1, 2, 6, 5]), 7);
        expect(a.length, 7);
        expect(a.toList().join(), '4267315');

        final b = OrderedSet<int>((a, b) => 0);
        expect(b.addAll([7, 4, 3, 1, 2, 6, 5]), 7);
        expect(a.length, 7);
        expect(b.toList().join(), '7431265');
      });

      test('with identical elements', () {
        final a = OrderedSet<int>();
        expect(a.addAll([4, 3, 3, 2, 2, 2, 1]), 4);
        expect(a.length, 4);
        expect(a.toList().join(), '1234');
      });

      test('elements with same priorities', () {
        final a = OrderedSet<ComparableObject>();

        final e1 = ComparableObject(1, 'e1');
        final e2 = ComparableObject(1, 'e2');
        final e3 = ComparableObject(2, 'e3');
        final e4 = ComparableObject(2, 'e4');
        a.addAll([e1, e3, e2, e4]);

        expect(a.toList().join(), 'e1e2e3e4');
        a.remove(e2);
        expect(a.toList().join(), 'e1e3e4');
        a.add(e2);
        expect(a.toList().join(), 'e1e2e3e4');
      });

      test('duplicated item is discarded', () {
        final a = OrderedSet<int>();
        a.add(2);
        a.add(1);
        a.add(2);
        expect(a.length, 2);
        expect(a.toList().join(), '12');
      });
    });

    group('#length', () {
      test('keeps track of length when adding', () {
        final a = OrderedSet<int>();
        expect(a.add(1), isTrue);
        expect(a.length, 1);
        expect(a.add(2), isTrue);
        expect(a.length, 2);
        expect(a.add(3), isTrue);
        expect(a.length, 3);
      });

      test('keeps track of length when removing', () {
        final a = OrderedSet<int>((a, b) => 0); // no priority
        expect(a.addAll([1, 2, 3, 4]), 4);
        expect(a.length, 4);

        expect(a.remove(1), isTrue);
        expect(a.length, 3);
        expect(a.remove(1), isFalse);
        expect(a.length, 3);

        expect(a.remove(5), isFalse); // never been there
        expect(a.length, 3);

        expect(a.remove(2), isTrue);
        expect(a.remove(3), isTrue);
        expect(a.length, 1);

        expect(a.remove(4), isTrue);
        expect(a.length, 0);
        expect(a.remove(4), isFalse);
      });
    });

    group('#add/#remove', () {
      test('no comparator test with int', () {
        final a = OrderedSet<int>();
        expect(a.add(2), isTrue);
        expect(a.add(1), isTrue);
        expect(a.toList(), [1, 2]);
      });

      test('no comparator test with string', () {
        final a = OrderedSet<String>();
        expect(a.add('aab'), isTrue);
        expect(a.add('cab'), isTrue);
        expect(a.add('bab'), isTrue);
        expect(a.toList(), ['aab', 'bab', 'cab']);
      });

      test('no comparator test with comparable', () {
        final a = OrderedSet<ComparableObject>();
        expect(a.add(ComparableObject(12, 'Klaus')), isTrue);
        expect(a.add(ComparableObject(1, 'Sunny')), isTrue);
        expect(a.add(ComparableObject(14, 'Violet')), isTrue);
        final expected = ['Sunny', 'Klaus', 'Violet'];
        expect(a.toList().map((e) => e.name).toList(), expected);
      });

      test('test with custom comparator', () {
        final a = OrderedSet<ComparableObject>(
          (a, b) => a.name.compareTo(b.name),
        );
        expect(a.add(ComparableObject(1, 'Sunny')), isTrue);
        expect(a.add(ComparableObject(12, 'Klaus')), isTrue);
        expect(a.add(ComparableObject(14, 'Violet')), isTrue);
        final expected = ['Klaus', 'Sunny', 'Violet'];
        expect(a.toList().map((e) => e.name).toList(), expected);
      });

      test(
        'test items with repeated comparables, maintain insertion order',
        () {
          final a = OrderedSet<int>((a, b) => (a % 2) - (b % 2));
          for (var i = 0; i < 10; i++) {
            expect(a.add(i), isTrue);
          }
          expect(a.toList(), [0, 2, 4, 6, 8, 1, 3, 5, 7, 9]);
        },
      );

      test('test items with actual duplicated items', () {
        final a = OrderedSet<int>();
        expect(a.add(1), isTrue);
        expect(a.add(1), isFalse);
        expect(a.toList(), [1]);
      });

      test('test remove items', () {
        final a = OrderedSet<int>();
        expect(a.add(1), isTrue);
        expect(a.add(2), isTrue);
        expect(a.add(0), isTrue);
        expect(a.remove(1), isTrue);
        expect(a.remove(3), isFalse);
        expect(a.toList(), [0, 2]);
      });

      test('test remove with duplicates', () {
        final a = OrderedSet<int>();
        expect(a.add(0), isTrue);
        expect(a.add(1), isTrue);
        expect(a.add(1), isFalse);
        expect(a.add(2), isTrue);
        expect(a.toList(), [0, 1, 2]);
        expect(a.remove(1), isTrue);
        expect(a.toList(), [0, 2]);
        expect(a.remove(1), isFalse);
        expect(a.toList(), [0, 2]);
      });

      test('with custom comparator, repeated items and removal', () {
        final a = OrderedSet<ComparableObject>(
          (a, b) => -a.priority.compareTo(b.priority),
        );
        final a1 = ComparableObject(2, '1');
        final a2 = ComparableObject(2, '2');
        final a3 = ComparableObject(1, '3');
        final a4 = ComparableObject(1, '4');
        final a5 = ComparableObject(1, '5');
        final a6 = ComparableObject(0, '6');
        expect(a.add(a6), isTrue);
        expect(a.add(a3), isTrue);
        expect(a.add(a4), isTrue);
        expect(a.add(a5), isTrue);
        expect(a.add(a1), isTrue);
        expect(a.add(a2), isTrue);
        expect(a.toList().join(), '123456');

        expect(a.remove(a4), isTrue);
        expect(a.toList().join(), '12356');
        expect(a.remove(a4), isFalse);
        expect(a.toList().join(), '12356');

        expect(a.remove(ComparableObject(1, '5')), isFalse);
        expect(a.toList().join(), '12356');
        expect(a.remove(a5), isTrue);
        expect(a.toList().join(), '1236');

        expect(a.add(ComparableObject(10, '*')), isTrue);
        expect(a.toList().join(), '*1236');

        expect(a.remove(a1), isTrue);
        expect(a.remove(a6), isTrue);
        expect(a.toList().join(), '*23');

        expect(a.add(ComparableObject(-10, '*')), isTrue);
        expect(a.toList().join(), '*23*');
        expect(a.remove(a2), isTrue);
        expect(a.toList().join(), '*3*');
        expect(a.remove(a2), isFalse);
        expect(a.remove(a2), isFalse);
        expect(a.toList().join(), '*3*');
        expect(a.remove(a3), isTrue);
        expect(a.toList().join(), '**');
      });

      test('removeAll', () {
        final orderedSet = OrderedSet<ComparableObject>(
          Comparing.on((e) => e.priority),
        );

        final a = ComparableObject(0, 'a');
        final b = ComparableObject(1, 'b');
        final c = ComparableObject(2, 'c');
        final d = ComparableObject(3, 'd');

        orderedSet.addAll([d, b, a, c]);
        expect(orderedSet.removeAll([c, a]).join(), 'ca');
        expect(orderedSet.toList().join(), 'bd');
        orderedSet.addAll([d, b, a, c]);
        expect(orderedSet.removeAll([d, b]).join(), 'db');
        expect(orderedSet.toList().join(), 'ac');
      });

      test('sorts after remove', () {
        final orderedSet = OrderedSet<int>();
        orderedSet.addAll([1, 3, 4]);
        expect(orderedSet.toList().join(), '134');
        expect(orderedSet.remove(4), true);
        expect(orderedSet.toList().join(), '13');
        expect(orderedSet.add(2), true);
        expect(orderedSet.toList().join(), '123');
      });

      test('correct order after remove', () {
        final orderedSet = OrderedSet<int>();
        orderedSet.add(10);
        orderedSet.add(9);
        orderedSet.remove(10);
        orderedSet.add(11);
        orderedSet.add(8);
        expect(orderedSet.toList(), [8, 9, 11]);
      });
    });

    group('rebalancing', () {
      test('rebalanceWhere and rebalanceAll', () {
        final orderedSet = OrderedSet<ComparableObject>(
          Comparing.on((e) => e.priority),
        );

        final a = ComparableObject(0, 'a');
        final b = ComparableObject(1, 'b');
        final c = ComparableObject(2, 'c');
        final d = ComparableObject(3, 'd');

        orderedSet.addAll([d, b, a, c]);
        expect(orderedSet.toList().join(), 'abcd');

        a.priority = 4;
        expect(orderedSet.toList().join(), 'abcd');
        orderedSet.rebalanceWhere((e) => identical(e, a));
        expect(orderedSet.toList().join(), 'bcda');

        b.priority = 5;
        c.priority = -1;
        expect(orderedSet.toList().join(), 'bcda');
        orderedSet.rebalanceAll();
        expect(orderedSet.toList().join(), 'cdab');
      });
    });

    group('reversed', () {
      test('reversed properly invalidates cache', () {
        final orderedSet = OrderedSet<ComparableObject>(
          Comparing.on((e) => e.priority),
        );

        final a = ComparableObject(0, 'a');
        final b = ComparableObject(1, 'b');
        final c = ComparableObject(2, 'c');
        final d = ComparableObject(3, 'd');

        orderedSet.addAll([d, b, a, c]);
        expect(orderedSet.reversed().join(), 'dcba');

        a.priority = 4;
        expect(orderedSet.reversed().join(), 'dcba');
        orderedSet.rebalanceWhere((e) => identical(e, a));
        expect(orderedSet.reversed().join(), 'adcb');

        b.priority = 5;
        c.priority = -1;
        expect(orderedSet.reversed().join(), 'adcb');
        orderedSet.rebalanceAll();
        expect(orderedSet.reversed().join(), 'badc');

        orderedSet.remove(d);
        expect(orderedSet.reversed().join(), 'bac');
        orderedSet.add(d);
        expect(orderedSet.reversed().join(), 'badc');
        orderedSet.removeAll([a, b]);
        expect(orderedSet.reversed().join(), 'dc');
        orderedSet.addAll([a, b]);
        expect(orderedSet.reversed().join(), 'badc');
      });
    });
  });
}
