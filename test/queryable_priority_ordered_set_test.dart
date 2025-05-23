import 'package:ordered_set/ordered_set.dart';
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
  group('QueryableOrderedSet - Priority', () {
    group('#add and #query', () {
      test('registration is mandatory on strict mode', () {
        final orderedSet = _create();

        expect(
          () => orderedSet.query<Bird>(),
          throwsA('Cannot query unregistered query Bird'),
        );
      });
      test('registration is optional with strict mode = false', () {
        final orderedSet = _create(strictMode: false);
        final bird = Bird()..name = 'Louise';
        final cod = Cod()..name = 'Leroy';
        orderedSet.addAll([bird, cod]);

        orderedSet.register<Cod>();
        expect(orderedSet.isRegistered<Cod>(), isTrue);
        expect(orderedSet.isRegistered<Bird>(), isFalse);

        expect(orderedSet.query<Cod>(), unorderedMatches(<Cod>[cod]));
        expect(orderedSet.isRegistered<Cod>(), isTrue);
        expect(orderedSet.isRegistered<Bird>(), isFalse);

        expect(orderedSet.query<Bird>(), unorderedMatches(<Bird>[bird]));
        expect(orderedSet.isRegistered<Cod>(), isTrue);
        expect(orderedSet.isRegistered<Bird>(), isTrue);
      });
      test('#add after #register', () {
        final dog = Dog()..name = 'Joey';
        final bird = Bird()..name = 'Louise';

        final orderedSet = _create();
        orderedSet.register<Animal>();
        orderedSet.register<Dog>();
        orderedSet.register<Bird>();

        orderedSet.add(dog);
        orderedSet.add(bird);

        expect(
          orderedSet.query<Animal>(),
          unorderedMatches(<Animal>[dog, bird]),
        );
        expect(orderedSet.query<Dog>(), unorderedMatches(<Dog>[dog]));
        expect(orderedSet.query<Bird>(), unorderedMatches(<Bird>[bird]));
      });
      test('#register after #add', () {
        final dog = Dog()..name = 'Joey';
        final bird = Bird()..name = 'Louise';

        final orderedSet = _create();

        orderedSet.add(dog);
        orderedSet.add(bird);

        orderedSet.register<Animal>();
        orderedSet.register<Dog>();
        orderedSet.register<Bird>();

        expect(
          orderedSet.query<Animal>(),
          unorderedMatches(<Animal>[dog, bird]),
        );
        expect(orderedSet.query<Dog>(), unorderedMatches(<Dog>[dog]));
        expect(orderedSet.query<Bird>(), unorderedMatches(<Bird>[bird]));
      });
      test('complex hierarchy', () {
        final dog = Dog()..name = 'Joey';
        final fish = Fish()..name = 'Abigail';
        final cod = Cod()..name = 'Leroy';

        final orderedSet = _create();

        orderedSet.register<Animal>();
        orderedSet.add(dog);

        orderedSet.register<Mammal>();
        orderedSet.add(fish);

        orderedSet.register<Dog>();
        orderedSet.add(cod);

        orderedSet.register<Fish>();
        orderedSet.register<Cod>();

        expect(
          orderedSet.query<Animal>(),
          unorderedMatches(<Animal>[dog, fish, cod]),
        );
        expect(orderedSet.query<Mammal>(), unorderedMatches(<Mammal>[dog]));
        expect(orderedSet.query<Dog>(), unorderedMatches(<Dog>[dog]));

        expect(orderedSet.query<Fish>(), unorderedMatches(<Fish>[fish, cod]));
        expect(orderedSet.query<Cod>(), unorderedMatches(<Cod>[cod]));
      });
      test('#remove', () {
        final dog = Dog()..name = 'Joey';
        final bird = Bird()..name = 'Louise';

        final orderedSet = _create();
        orderedSet.register<Animal>();
        orderedSet.register<Dog>();
        orderedSet.register<Bird>();

        orderedSet.add(dog);
        orderedSet.add(bird);

        orderedSet.remove(dog);

        expect(orderedSet.query<Animal>(), unorderedMatches(<Animal>[bird]));
        expect(orderedSet.query<Dog>(), unorderedMatches(<Dog>[]));
        expect(orderedSet.query<Bird>(), unorderedMatches(<Bird>[bird]));

        orderedSet.remove(bird);

        expect(orderedSet.query<Animal>(), unorderedMatches(<Animal>[]));
        expect(orderedSet.query<Dog>(), unorderedMatches(<Dog>[]));
        expect(orderedSet.query<Bird>(), unorderedMatches(<Bird>[]));
      });
      test('#removeWhere', () {
        final dog1 = Dog()..name = 'Joey';
        final dog2 = Dog()..name = 'Thomas';
        final bird1 = Bird()..name = 'Louise';
        final bird2 = Bird()..name = 'Sally';

        final orderedSet = _create();
        orderedSet.register<Animal>();
        orderedSet.register<Mammal>();
        orderedSet.register<Dog>();
        orderedSet.register<Bird>();

        orderedSet.add(dog1);
        orderedSet.add(dog2);
        orderedSet.add(bird1);
        orderedSet.add(bird2);

        expect(
          orderedSet.query<Animal>(),
          unorderedMatches(<Animal>[dog1, dog2, bird1, bird2]),
        );
        expect(
          orderedSet.query<Mammal>(),
          unorderedMatches(<Mammal>[dog1, dog2]),
        );
        expect(
          orderedSet.query<Dog>(),
          unorderedMatches(<Dog>[dog1, dog2]),
        );
        expect(
          orderedSet.query<Bird>(),
          unorderedMatches(<Bird>[bird1, bird2]),
        );

        orderedSet.removeWhere((e) => e.name.endsWith('y')); // Joey and Sally

        expect(
          orderedSet.query<Animal>(),
          unorderedMatches(<Animal>[dog2, bird1]),
        );
        expect(
          orderedSet.query<Mammal>(),
          unorderedMatches(<Mammal>[dog2]),
        );
        expect(
          orderedSet.query<Dog>(),
          unorderedMatches(<Dog>[dog2]),
        );
        expect(
          orderedSet.query<Bird>(),
          unorderedMatches(<Bird>[bird1]),
        );

        orderedSet.removeWhere((e) => e is Dog); // Thomas

        expect(orderedSet.query<Animal>(), unorderedMatches(<Animal>[bird1]));
        expect(orderedSet.query<Mammal>(), unorderedMatches(<Mammal>[]));
        expect(orderedSet.query<Dog>(), unorderedMatches(<Dog>[]));
        expect(orderedSet.query<Bird>(), unorderedMatches(<Bird>[bird1]));

        orderedSet.removeWhere((e) => true); // Louise

        expect(orderedSet.query<Animal>(), unorderedMatches(<Animal>[]));
        expect(orderedSet.query<Mammal>(), unorderedMatches(<Mammal>[]));
        expect(orderedSet.query<Dog>(), unorderedMatches(<Dog>[]));
        expect(orderedSet.query<Bird>(), unorderedMatches(<Bird>[]));
      });
      test('#clear', () {
        final dog1 = Dog()..name = 'Joey';
        final dog2 = Dog()..name = 'Thomas';
        final bird1 = Bird()..name = 'Louise';
        final bird2 = Bird()..name = 'Sally';

        final orderedSet = _create();
        orderedSet.register<Animal>();
        orderedSet.register<Mammal>();
        orderedSet.register<Dog>();
        orderedSet.register<Bird>();

        orderedSet.add(dog1);
        orderedSet.add(dog2);
        orderedSet.add(bird1);
        orderedSet.add(bird2);

        orderedSet.clear();

        expect(orderedSet.query<Animal>(), unorderedMatches(<Animal>[]));
        expect(orderedSet.query<Mammal>(), unorderedMatches(<Mammal>[]));
        expect(orderedSet.query<Dog>(), unorderedMatches(<Dog>[]));
        expect(orderedSet.query<Bird>(), unorderedMatches(<Bird>[]));
        expect(orderedSet.toList(), isEmpty);
      });
      test('#isRegistered', () {
        final orderedSet = _create();
        // No caches should be registered on a clean set
        expect(orderedSet.isRegistered<Animal>(), isFalse);
        expect(orderedSet.isRegistered<Mammal>(), isFalse);
        orderedSet.register<Animal>();
        // It shouldn't return isTrue for a subclass of a registered cache
        expect(orderedSet.isRegistered<Mammal>(), isFalse);
        // The Animal cache should report as registered after it has been
        // registered
        expect(orderedSet.isRegistered<Animal>(), isTrue);
        orderedSet.register<Mammal>();
        // The Mammal cache should report as registered after it has been
        // registered
        expect(orderedSet.isRegistered<Mammal>(), isTrue);
        // The Animal cache should still be reported as registered after another
        // cache has been registered
        expect(orderedSet.isRegistered<Animal>(), isTrue);
        orderedSet.register<Animal>();
        // Both caches should still be reported as registered after a cache has
        // been re-registered (no-op)
        expect(orderedSet.isRegistered<Animal>(), isTrue);
        expect(orderedSet.isRegistered<Mammal>(), isTrue);
        // A call to isRegistered without a type should always be isFalse
      });
      test('#query returns Iterable', () {
        final dog = Dog()..name = 'Joey';
        final bird = Bird()..name = 'Louise';

        final orderedSet = _create();
        orderedSet.register<Dog>();

        orderedSet.add(dog);
        orderedSet.add(bird);

        final dogs = orderedSet.query<Dog>();
        expect(dogs, isA<Iterable<Dog>>());
      });
      test('overridden #whereType works as expected', () {
        final dog = Dog()..name = 'Joey';
        final bird = Bird()..name = 'Louise';

        final orderedSet = _create();
        orderedSet.register<Dog>();

        orderedSet.add(dog);
        orderedSet.add(bird);

        final dogs = orderedSet.whereType<Dog>();
        expect(dogs, unorderedMatches(<Dog>[dog]));
        final birds = orderedSet.whereType<Bird>();
        expect(birds, unorderedMatches(<Bird>[bird]));
        final fish = orderedSet.whereType<Fish>();
        expect(fish, unorderedMatches(<Fish>[]));
      });
    });
  });
}

OrderedSet<Animal> _create({
  bool strictMode = true,
}) {
  return OrderedSet.mapping<String, Animal>(
    (e) => e.name,
    strictMode: strictMode,
  );
}
