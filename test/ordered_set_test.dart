import 'package:test/test.dart';
import 'package:ordered_set/ordered_set.dart';

import 'comparable_object.dart';

void main() {
  group('OrderedSet', () {
    group('#removeWhere', () {
      test('remove single ement', () {
        OrderedSet<int> a = OrderedSet();
        expect(a.addAll([7, 4, 3, 1, 2, 6, 5]), 7);
        expect(a.length, 7);
        expect(a.removeWhere((e) => e == 3).length, 1);
        expect(a.length, 6);
        expect(a.toList().join(), '124567');
      });

      test('remove with property', () {
        OrderedSet<int> a = OrderedSet();
        expect(a.addAll([7, 4, 3, 1, 2, 6, 5]), 7);
        expect(a.removeWhere((e) => e % 2 == 1).length, 4);
        expect(a.length, 3);
        expect(a.toList().join(), '246');
      });

      test('remove returns the removed elements', () {
        OrderedSet<int> a = OrderedSet();
        a.addAll([7, 4, 3, 1, 2, 6, 5]);
        final removed = a.removeWhere((e) => e <= 2);
        expect(removed.length, 2);
        expect(removed.toList().join(), '12');
      });

      test('remove from same group and different groups', () {
        OrderedSet<ComparableObject> a = OrderedSet();
        expect(a.add(ComparableObject(0, 'a1')), true);
        expect(a.add(ComparableObject(0, 'a2')), true);
        expect(a.add(ComparableObject(0, 'b1')), true);
        expect(a.add(ComparableObject(1, 'a3')), true);
        expect(a.add(ComparableObject(1, 'b2')), true);
        expect(a.add(ComparableObject(1, 'b3')), true);
        expect(a.add(ComparableObject(2, 'a4')), true);
        expect(a.add(ComparableObject(2, 'b4')), true);
        expect(a.removeWhere((e) => e.name.startsWith('a')).length, 4);
        expect(a.length, 4);
        expect(a.toList().join(), 'b1b2b3b4');
      });

      test('remove all', () {
        OrderedSet<ComparableObject> a = OrderedSet();
        expect(a.add(ComparableObject(0, 'a1')), true);
        expect(a.add(ComparableObject(0, 'a2')), true);
        expect(a.add(ComparableObject(0, 'b1')), true);
        expect(a.add(ComparableObject(1, 'a3')), true);
        expect(a.add(ComparableObject(1, 'b2')), true);
        expect(a.add(ComparableObject(1, 'b3')), true);
        expect(a.add(ComparableObject(2, 'a4')), true);
        expect(a.add(ComparableObject(2, 'b4')), true);
        expect(a.removeWhere((e) => true).length, 8);
        expect(a.length, 0);
        expect(a.toList().join(), '');
      });
    });

    group('#clear', () {
      test('removes all and updates length', () {
        OrderedSet<int> a = OrderedSet();
        expect(a.addAll([1, 2, 3, 4, 5, 6]), 6);
        a.clear();
        expect(a.length, 0);
        expect(a.toList().length, 0);
      });
    });

    group('#addAll', () {
      test('maintains order', () {
        OrderedSet<int> a = OrderedSet();
        expect(a.length, 0);
        expect(a.addAll([7, 4, 3, 1, 2, 6, 5]), 7);
        expect(a.length, 7);
        expect(a.toList().join(), '1234567');
      });

      test('with repeated priority elements', () {
        OrderedSet<int> a = OrderedSet((a, b) => (a % 2) - (b % 2));
        expect(a.addAll([7, 4, 3, 1, 2, 6, 5]), 7);
        expect(a.length, 7);
        expect(a.toList().join(), '4267315');

        OrderedSet<int> b = OrderedSet((a, b) => 0);
        expect(b.addAll([7, 4, 3, 1, 2, 6, 5]), 7);
        expect(a.length, 7);
        expect(b.toList().join(), '7431265');
      });

      test('with identical elements', () {
        OrderedSet<int> a = OrderedSet();
        expect(a.addAll([4, 3, 3, 2, 2, 2, 1]), 7);
        expect(a.length, 7);
        expect(a.toList().join(), '1222334');
      });
    });

    group('#length', () {
      test('keeps track of lenth when adding', () {
        OrderedSet<int> a = OrderedSet();
        expect(a.add(1), true);
        expect(a.length, 1);
        expect(a.add(2), true);
        expect(a.length, 2);
        expect(a.add(3), true);
        expect(a.length, 3);
      });

      test('keeps track of lenth when removing', () {
        OrderedSet<int> a = OrderedSet((a, b) => 0); // no priority
        expect(a.addAll([1, 2, 3, 4]), 4);
        expect(a.length, 4);

        expect(a.remove(1), true);
        expect(a.length, 3);
        expect(a.remove(1), false);
        expect(a.length, 3);

        expect(a.remove(5), false); // never been there
        expect(a.length, 3);

        expect(a.remove(2), true);
        expect(a.remove(3), true);
        expect(a.length, 1);

        expect(a.remove(4), true);
        expect(a.length, 0);
        expect(a.remove(4), false);
      });
    });

    group('#add/#remove', () {
      test('no comparator test with int', () {
        OrderedSet<int> a = OrderedSet();
        expect(a.add(2), true);
        expect(a.add(1), true);
        expect(a.toList(), [1, 2]);
      });

      test('no comparator test with string', () {
        OrderedSet<String> a = OrderedSet();
        expect(a.add('aab'), true);
        expect(a.add('cab'), true);
        expect(a.add('bab'), true);
        expect(a.toList(), ['aab', 'bab', 'cab']);
      });

      test('no comparator test with comparable', () {
        OrderedSet<ComparableObject> a = OrderedSet();
        expect(a.add(ComparableObject(12, 'Klaus')), true);
        expect(a.add(ComparableObject(1, 'Sunny')), true);
        expect(a.add(ComparableObject(14, 'Violet')), true);
        List<String> expected = ['Sunny', 'Klaus', 'Violet'];
        expect(a.toList().map((e) => e.name).toList(), expected);
      });

      test('test with custom comparator', () {
        OrderedSet<ComparableObject> a =
            OrderedSet((a, b) => a.name.compareTo(b.name));
        expect(a.add(ComparableObject(1, 'Sunny')), true);
        expect(a.add(ComparableObject(12, 'Klaus')), true);
        expect(a.add(ComparableObject(14, 'Violet')), true);
        List<String> expected = ['Klaus', 'Sunny', 'Violet'];
        expect(a.toList().map((e) => e.name).toList(), expected);
      });

      test('test items with repeated comparables, maintain insertion order',
          () {
        OrderedSet<int> a = OrderedSet<int>((a, b) => (a % 2) - (b % 2));
        for (int i = 0; i < 10; i++) {
          expect(a.add(i), true);
        }
        expect(a.toList(), [0, 2, 4, 6, 8, 1, 3, 5, 7, 9]);
      });

      test('test items with actual duplicated items', () {
        OrderedSet<int> a = OrderedSet<int>();
        expect(a.add(1), true);
        expect(a.add(1), true);
        expect(a.toList(), [1, 1]);
      });

      test('test remove items', () {
        OrderedSet<int> a = OrderedSet<int>();
        expect(a.add(1), true);
        expect(a.add(2), true);
        expect(a.add(0), true);
        expect(a.remove(1), true);
        expect(a.remove(3), false);
        expect(a.toList(), [0, 2]);
      });

      test('test remove with duplicates', () {
        OrderedSet<int> a = OrderedSet<int>();
        expect(a.add(0), true);
        expect(a.add(1), true);
        expect(a.add(1), true);
        expect(a.add(2), true);
        expect(a.toList(), [0, 1, 1, 2]);
        expect(a.remove(1), true);
        expect(a.toList(), [0, 1, 2]);
        expect(a.remove(1), true);
        expect(a.toList(), [0, 2]);
      });

      test('with custom comparator, repeated items and removal', () {
        OrderedSet<ComparableObject> a =
            OrderedSet((a, b) => -a.priority.compareTo(b.priority));
        ComparableObject a1, a2, a3, a4, a5, a6;
        expect(a.add(a6 = ComparableObject(0, '6')), true);
        expect(a.add(a3 = ComparableObject(1, '3')), true);
        expect(a.add(a4 = ComparableObject(1, '4')), true);
        expect(a.add(a5 = ComparableObject(1, '5')), true);
        expect(a.add(a1 = ComparableObject(2, '1')), true);
        expect(a.add(a2 = ComparableObject(2, '2')), true);
        expect(a.toList().join(), '123456');

        expect(a.remove(a4), true);
        expect(a.toList().join(), '12356');
        expect(a.remove(a4), false);
        expect(a.toList().join(), '12356');

        expect(a.remove(ComparableObject(1, '5')), false);
        expect(a.toList().join(), '12356');
        expect(a.remove(a5), true);
        expect(a.toList().join(), '1236');

        expect(a.add(ComparableObject(10, '*')), true);
        expect(a.toList().join(), '*1236');

        expect(a.remove(a1), true);
        expect(a.remove(a6), true);
        expect(a.toList().join(), '*23');

        expect(a.add(ComparableObject(-10, '*')), true);
        expect(a.toList().join(), '*23*');
        expect(a.remove(a2), true);
        expect(a.toList().join(), '*3*');
        expect(a.remove(a2), false);
        expect(a.remove(a2), false);
        expect(a.toList().join(), '*3*');
        expect(a.remove(a3), true);
        expect(a.toList().join(), '**');
      });
    });
  });
}
