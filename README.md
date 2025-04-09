# ordered_set

[![Pub Version](https://img.shields.io/pub/v/ordered_set)](https://pub.dev/packages/ordered_set)
[![Build Status](https://github.com/flame-engine/flame/workflows/cicd/badge.svg?branch=main&event=push)](https://github.com/bluefireteam/ordered_set/actions/workflows/cicd.yml)
[![Coverage Status](https://coveralls.io/repos/github/bluefireteam/ordered_set/badge.svg?branch=main)](https://coveralls.io/github/bluefireteam/ordered_set?branch=main)

A simple implementation for an Ordered Set for Dart.

It accepts either a comparator function that compares items for their priority or a mapper function that maps items to their priority.

Unlike Dart's [SplayTreeSet](https://api.dart.dev/dart-collection/SplayTreeSet-class.html) or [SplayTreeMap](https://api.dart.dev/dart-collection/SplayTreeMap-class.html) classes, it allows for several different elements with the same "priority" to be added.

It also implements [Iterable](https://api.dart.dev/dart-core/Iterable-class.html), allowing you to iterate the contents (in order) in O(n) (no additional overhead).

## Usage

A simple usage example:

```dart
  import 'package:ordered_set/ordered_set.dart';

  main() {
    final items = OrderedSet.simple<num, int>();
    items.add(2);
    items.add(1);
    print(items.toList()); // [1, 2]
  }
```

But it can accept multiple items with the same priority:

```dart
  import 'package:ordered_set/ordered_set.dart';

  main() {
    final items = OrderedSet.mapping<String, Person>((p) => p.name);
    items.add(Person('Alice', 'Engineering'));
    items.add(Person('Bob', 'Accounting'));
    items.add(Person('Alice', 'Marketing'));
    print(items.toList()); // [Alice, Alice, Bob]
  }
```

## Comparing

In order to assist the creation of `Comparator`s, the `Comparing` class can be used:

```dart
  // sort by name length
  final people = OrderedSet.comparing<Person>(Comparing.on((p) => p.name.length));

  // sort by name desc
  final people = OrderedSet.comparing<Person>(Comparing.reverse(Comparing.on((p) => p.name)));

  // sort by role and then by name
  final people = OrderedSet.comparing<Person>(Comparing.join([(p) => p.role, (p) => p.name]));
```

Note that you could instead just create a `MappingOrderedSet` instead:

```dart
  final people = OrderedSet.mapping<num, Person>((p) => p.name.length);
  // ...
```

## Mapping vs Comparing vs Queryable

There are three main implementations of the `OrderedSet` interface:

* `ComparingOrderedSet`: the simplest implementation, takes in a `Comparator` and does not cache priorities. It uses Dart's `SplayTreeSet` as a backing implementation.
* `MappingOrderedSet`: a slightly more advanced implementation that takes in a mapper function (maps elements to their priorities) and caches them. It uses Dart's `SplayTreeMap` as a backing implementation.
* `QueryableOrderedSet`: a simple wrapper over either `OrderedSet` that allows for O(1) type queries; if you find yourself doing `.whereType<T>()` a lot, you should consider using this.

In order to create an `OrderedSet`, however, you can just use the static methods on the interface itself:

* `comparing<E>([comparator])`: creates a `ComparingOrderedSet` with the given `Comparator`.
* `mapping<K, E>([mapper])`: creates a `MappingOrderedSet` with the given mapper function.
* `comparable<K, E>()`: if `E extends Comparable<K>`, this is a simpler way of creating a `MappingOrderedSet` with identity mapping.
* `simple<E>()`: if `E extends Comparable<E>`, this is an even simpler way of creating a `MappingOrderedSet` with identity mapping.
* `queryable<E>(orderedSet)`: wraps the given `OrderedSet` into a `QueryableOrderedSet`.

## Contributing

All contributions are very welcome! Please feel free to create Issues, help us with PR's or comment your suggestions, feature requests, bugs, et cetera. Give us a star if you liked it!
