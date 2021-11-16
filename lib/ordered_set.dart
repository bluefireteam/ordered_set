import 'dart:collection';

/// A simple implementation for an ordered set for Dart.
///
/// It accepts a compare function that compares items for their priority. Unlike
/// [SplayTreeSet], it allows for several different elements with the same
/// priority to be added. It also implements [Iterable], so you can iterate it
/// in O(n).
class OrderedSet<E> extends IterableMixin<E> implements Iterable<E> {
  // If the default implementation of `Set` changes from `LinkedHashSet` to
  // something else that isn't ordered we'll have to change this to explicitly
  // be `LinkedHashSet` (or some other data structure that preserves order).
  late SplayTreeSet<Set<E>> _backingSet;
  late int _length;

  bool _validReverseCache = true;
  Iterable<E> _reverseCache = const Iterable.empty();

  // Copied from SplayTreeSet, but those are private there
  static int _dynamicCompare(dynamic a, dynamic b) => Comparable.compare(
        a as Comparable,
        b as Comparable,
      );
  static Comparator<K> _defaultCompare<K>() {
    const Object compare = Comparable.compare;
    if (compare is Comparator<K>) {
      return compare;
    }
    return _dynamicCompare;
  }

  /// Creates a new [OrderedSet] with the given compare function.
  ///
  /// If the [compare] function is omitted, it defaults to [Comparable.compare],
  /// and the elements must be comparable.
  OrderedSet([int Function(E e1, E e2)? compare]) {
    final comparator = compare ?? _defaultCompare<E>();
    _backingSet = SplayTreeSet<LinkedHashSet<E>>((Set<E> l1, Set<E> l2) {
      if (l1.isEmpty) {
        if (l2.isEmpty) {
          return 0;
        }
        return -1;
      }
      if (l2.isEmpty) {
        return 1;
      }
      return comparator(l1.first, l2.first);
    });
    _length = 0;
  }

  /// Gets the current length of this.
  ///
  /// Returns the cached length of this, in O(1). This is the full length, i.e.,
  /// the sum of the lengths of each bucket.
  @override
  int get length => _length;

  @override
  Iterator<E> get iterator {
    return _backingSet.expand<E>((es) => es).iterator;
  }

  /// The tree's elements in reversed order, cached when possible.
  Iterable<E> reversed() {
    if (!_validReverseCache) {
      _reverseCache = toList(growable: false).reversed;
    }
    return _reverseCache;
  }

  /// Adds each element of the provided [elements] to this and returns the
  /// number of elements added.
  int addAll(Iterable<E> elements) => elements.map(add).where((e) => e).length;

  /// Adds the element [e] to this, and returns whether the element was
  /// added or not. If the element already exists in the collection, it isn't
  /// added.
  bool add(E e) {
    final elementSet = {e};
    var added = false;
    final isRootSet = added = _backingSet.add(elementSet);
    if (!isRootSet) {
      added = _backingSet.lookup(elementSet)!.add(e);
    }
    if (added) {
      _length++;
      _validReverseCache = false;
    }
    return added;
  }

  /// Allows you to rebalance the whole tree. If you are dealing with
  /// non-deterministic compare functions, you probably need to consider
  /// rebalancing.
  /// If the result of the priority function for some elements
  /// changes, rebalancing is needed.
  /// In general, be careful with using comparing functions that can change.
  /// If only a few known elements need rebalancing, you can use
  /// [rebalanceWhere].
  /// Note: rebalancing is **not** stable.
  void rebalanceAll() {
    final elements = toList(growable: false);
    clear();
    addAll(elements);
  }

  /// Allows you to rebalance only a portion of the tree. If you are dealing
  /// with non-deterministic compare functions, you probably need to consider
  /// rebalancing.
  /// If the priority function changed for certain known elements but not all,
  /// you can use this instead of [rebalanceAll].
  /// In general be careful with using comparing functions that can change.
  /// Note: rebalancing is **not** stable.
  void rebalanceWhere(bool Function(E element) test) {
    final elements = removeWhere(test);
    addAll(elements);
  }

  /// Remove all elements that match the [test] condition; returns the removed
  /// elements.
  Iterable<E> removeWhere(bool Function(E element) test) {
    return where(test).toList(growable: false)..forEach(remove);
  }

  /// Remove all [elements] and returns the removed elements.
  Iterable<E> removeAll(Iterable<E> elements) {
    return elements.where(remove).toList(growable: false);
  }

  /// Remove a single element that is equal to [e].
  ///
  /// If there are multiple elements identical to [e], only the first will be
  /// removed. To remove all, use something like:
  ///
  ///     set.removeWhere((a) => a == e);
  ///
  bool remove(E e) {
    var bucket = _backingSet.lookup([e]);
    if (bucket == null || !bucket.contains(e)) {
      // We need a fallback in case [e] has changed and it's no longer found by
      // lookup. Note: changing priorities will leave the splay set on an
      // unknown state; other methods might not work. You must call rebalance to
      // make sure the state is consistent. This is just for convenient usage by
      // the rebalancing method itself.
      final possibleBuckets = _backingSet
          .where((bucket) => bucket.any((element) => identical(element, e)));
      if (possibleBuckets.isNotEmpty) {
        bucket = possibleBuckets.first;
      }
    }
    if (bucket == null) {
      return false;
    }
    final result = bucket.remove(e);
    if (result) {
      _length--;
      _backingSet.remove(<E>[]);
      _validReverseCache = false;
    }
    return result;
  }

  /// Removes all elements of this.
  void clear() {
    _validReverseCache = false;
    _backingSet.clear();
    _length = 0;
  }
}
