import 'dart:collection';

import 'package:ordered_set/ordered_set.dart';
import 'package:ordered_set/priority_ordered_set.dart';

/// A simple implementation of [OrderedSet] that uses a [SplayTreeSet] as the
/// backing store.
///
/// This does not store the elements priorities, so it is susceptible to race
/// conditions if priorities are changed while iterating.
/// For a safer implementation, use [PriorityOrderedSet].
class ComparingOrderedSet<E> extends OrderedSet<E> {
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
  ComparingOrderedSet([int Function(E e1, E e2)? compare]) {
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

  @override
  int get length => _length;

  @override
  Iterator<E> get iterator {
    return _OrderedSetIterator<E>(this);
  }

  @override
  Iterable<E> reversed() {
    if (!_validReverseCache) {
      _reverseCache = toList(growable: false).reversed;
    }
    return _reverseCache;
  }

  @override
  bool add(E e) {
    final elementSet = {e};
    var added = _backingSet.add(elementSet);
    final isRootSet = added;
    if (!isRootSet) {
      added = _backingSet.lookup(elementSet)!.add(e);
    }
    if (added) {
      _length++;
      _validReverseCache = false;
    }
    return added;
  }

  @override
  void rebalanceAll() {
    final elements = toList(growable: false);
    clear();
    addAll(elements);
  }

  @override
  void rebalanceWhere(bool Function(E element) test) {
    final elements = removeWhere(test);
    addAll(elements);
  }

  @override
  bool remove(E e) {
    var bucket = _backingSet.lookup({e});
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
      // If the removal resulted in an empty bucket, remove the bucket as well.
      _backingSet.remove(<E>{});
      _validReverseCache = false;
    }
    return result;
  }

  @override
  void clear() {
    _validReverseCache = false;
    _backingSet.clear();
    _length = 0;
  }
}

class _OrderedSetIterator<E> implements Iterator<E> {
  final Iterator<Set<E>> _iterator;
  Iterator<E>? _innerIterator;

  _OrderedSetIterator(ComparingOrderedSet<E> orderedSet)
      : _iterator = orderedSet._backingSet.iterator;

  @override
  E get current => _innerIterator!.current;

  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  @override
  bool moveNext() {
    if (_innerIterator?.moveNext() != true) {
      final result = _iterator.moveNext();

      if (!result) {
        return false;
      }

      _innerIterator = _iterator.current.iterator;
      return _innerIterator!.moveNext();
    }
    return true;
  }
}
