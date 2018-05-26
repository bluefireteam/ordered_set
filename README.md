# ordered_set

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
    OrderedSet<int> items = new OrderedSet();
    items.add(2);
    items.add(1);
    print(items.toList()); // [1, 2]
  }
```

## Contributing

All contributions are very welcome! Please feel free to create Issues, help us with PR's or comment your suggestions, feature requests, bugs, et cetera. Give us a star if you liked it!
