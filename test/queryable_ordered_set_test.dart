import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/queryable_ordered_set.dart';
import 'package:test/test.dart';

abstract class Animal {
  String name = '';
}

abstract class Mammal extends Animal {}

class Bird extends Animal {}

class Fish extends Animal {}

class Dog extends Mammal {}

class Cat extends Mammal {}

class Cod extends Fish {}

void main() {
  group('QueryableOrderedSet', () {
    group('#add and #query', () {
      test('query after registering', () {
        final dog = Dog()..name = 'Joey';
        final bird = Bird()..name = 'Louise';

        final orderedSet = QueryableOrderedSet<Animal>(
          Comparing.on((e) => e.name),
        );
        orderedSet.register<Animal>();
        orderedSet.register<Dog>();
        orderedSet.register<Bird>();

        orderedSet.add(dog);
        orderedSet.add(bird);

        expect(orderedSet.query<Animal>(), containsAll(<Animal>[dog, bird]));
        expect(orderedSet.query<Dog>(), containsAll(<Dog>[dog]));
        expect(orderedSet.query<Bird>(), containsAll(<Bird>[bird]));
      });
    });
  });
}
