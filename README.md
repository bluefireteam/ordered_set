# ordered_set

[![Pub Version](https://img.shields.io/pub/v/ordered_set)](https://pub.dev/packages/ordered_set)
[![Build Status](https://github.com/flame-engine/flame/workflows/cicd/badge.svg?branch=master&event=push)](https://github.com/luanpotter/ordered_set/actions/workflows/cicd.yml)
[![Coverage Status](https://coveralls.io/repos/github/luanpotter/ordered_set/badge.svg?branch=master)](https://coveralls.io/github/luanpotter/ordered_set?branch=master)

A simple implementation for an ordered set for Dart.

It accepts a compare function that compares items for their priority.

Unlike Dart's [SplayTreeSet](https://api.dartlang.org/stable/1.24.3/dart-collection/SplayTreeSet/SplayTreeSet.html), it allows for several different elements with the same priority to be added.

It also implements [Iterable](https://api.dartlang.org/stable/1.24.3/dart-core/Iterable-class.html), so you can iterate it in O(n).

## Usage

A simple usage example:

```dart
  import 'package:ordered_set/ordered_set.dart';

  main() {
    final items = OrderedSet<int>();
    items.add(2);
    items.add(1);
    print(items.toList()); // [1, 2]
  }
```

## Comparing

In order to assist the creation of OrderedSet's, there is a Comparing class to easily create Comparables:

```dart
  // sort by name length
  final people = OrderedSet<Person>(Comparing.on((p) => p.name.length));

  // sort by name desc
  final people = OrderedSet<Person>(Comparing.reverse(Comparing.on((p) => p.name)));

  // sort by role and then by name
  final people = OrderedSet<Person>(Comparing.join([(p) => p.role, (p) => p.name]));
```

## Contributing

All contributions are very welcome! Please feel free to create Issues, help us with PR's or comment your suggestions, feature requests, bugs, et cetera. Give us a star if you liked it!
