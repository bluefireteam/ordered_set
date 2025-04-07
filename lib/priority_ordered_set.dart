import 'dart:collection';

import 'package:ordered_set/comparing_ordered_set.dart';
import 'package:ordered_set/ordered_set.dart';

/// A simple implementation of [OrderedSet] that uses a [SplayTreeMap] as the
/// backing store.
///
/// This allows it to keep a cache of elements priorities, so they can be used
/// changed without rebalancing.
/// For an alternative implementation, use [ComparingOrderedSet].
class PriorityOrderedSet<K extends Comparable<K>, E> extends OrderedSet<E> {
  final K Function(E a) _priorityFunction;
  late SplayTreeMap<K, Set<E>> _backingSet;
  late int _length;

  bool _validReverseCache = true;
  Iterable<E> _reverseCache = const Iterable.empty();

  PriorityOrderedSet(this._priorityFunction) {
    _backingSet = SplayTreeMap((K k1, K k2) {
      return k1.compareTo(k2);
    });
    _length = 0;
  }

  @override
  int get length => _length;

  @override
  Iterator<E> get iterator {
    return _PriorityOrderedSetIterator<K, E>(this);
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
    final elementPriority = _priorityFunction(e);
    final innerSet = _backingSet.putIfAbsent(elementPriority, () => <E>{});
    final added = innerSet.add(e);
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
    K? key = _priorityFunction(e);
    var bucket = _backingSet[key];
    if (bucket == null || !bucket.contains(e)) {
      // We need a fallback in case [e] has changed and it's no longer found by
      // lookup. Note: changing priorities will leave the splay set on an
      // unknown state; other methods might not work. You must call rebalance to
      // make sure the state is consistent. This is just for convenient usage by
      // the rebalancing method itself.
      final possibleBuckets = _backingSet.entries.where((bucket) {
        return bucket.value.any((element) => identical(element, e));
      });
      final possibleBucket = possibleBuckets.firstOrNull;
      bucket = possibleBucket?.value;
      key = possibleBucket?.key;
    }
    if (bucket == null || key == null) {
      return false;
    }
    final result = bucket.remove(e);
    if (result) {
      _length--;
      // If the removal resulted in an empty bucket, remove the bucket as well.
      if (bucket.isEmpty) {
        _backingSet.remove(key);
      }
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

class _PriorityOrderedSetIterator<K extends Comparable<K>, E>
    implements Iterator<E> {
  final Iterator<Set<E>> _iterator;
  Iterator<E>? _innerIterator;

  _PriorityOrderedSetIterator(PriorityOrderedSet<K, E> orderedSet)
      : _iterator = orderedSet._backingSet.values.iterator;

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
      _innerIterator!.moveNext();
      return true;
    }
    return true;
  }
}
