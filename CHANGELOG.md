## 6.1.1

- Fix bug if inner sub set is empty causing null pointer exception.

## 6.1.0

- Add `elementAt` method, which returns the element at a certain index.
- Add benchmark harness skeleton.
- Optimize iterator by using a custom iterator.

## 6.0.1

- Use cached results in `whereType()` when available, making `whereType()` 
  return in constant time when the type is registered

## 6.0.0

- Make `QueryableOrderedSet.query()` return an `Iterable` instead of a `List`,
  in order to prevent hard-to-track bugs with accidental cache modification
  from outside

## 5.0.3

- Fix bug with sorting after removal of element in root bucket

## 5.0.2

- Fix bug with sorting after removal of element that leaves a bucket empty

## 5.0.1

- Remove `ìmplements Iterable` to make Dart 3.10 happy

## 5.0.0

- Relaunch of 4.1.0

## 4.1.0

- Add `OrderedSet.reversed`
- Add `OrderedSet.removeAll`
- Elements that already exists in the set are not added

## 4.0.0

- Add `Comparing#mapper`
- Add `strictMode` to QueryableOrderedSet

## 3.2.0

- Change `QueryableOrderedSet.register` to be no-op if type is already registered

## 3.1.0

- Add QueryableOrderedSet

## 3.0.0

- Add null safety for this package
- Add methods for rebalancing

## 2.0.2

- Improve repository organization

## 2.0.1

- Simplify implementation of iterator and removeWhere

## 2.0.0

- Change removeWhere api

## 1.1.5

- Fix coveralls, bump dependencies

## 1.1.4

- Improve build and fix warnings

## 1.1.3

- Formatting, removing warnings

## 1.1.2

- Fix for dart2

## 1.1.0

- Improving documentation via dartdocs

## 1.0.0

- Adding Comparing class

## 0.1.0

- Initial version, adding Ordered Set with basic operations
