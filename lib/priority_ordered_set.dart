import 'dart:collection';

import 'package:ordered_set/comparing_ordered_set.dart';
import 'package:ordered_set/ordered_set.dart';

/// A simple implementation of [OrderedSet] that uses a [SplayTreeSet] as the
/// backing store.
///
/// This wraps the [ComparingOrderedSet] implementation, but uses a cache for
/// the priority so ordering only changes when rebalance is called.
/// However this means that you cannot remove elements by reference if their
/// priority has changed since last rebalance.
/// For an alternative implementation, use [PriorityOrderedSet].
class PriorityOrderedSet<K extends Comparable<K>, E> extends OrderedSet<E> {
  final K Function(E a) _priorityFunction;
  final OrderedSet<(K, E)> _backingSet = ComparingOrderedSet<(K, E)>(
    (a, b) => a.$1.compareTo(b.$1),
  );

  PriorityOrderedSet(this._priorityFunction);

  @override
  int get length => _backingSet.length;

  @override
  Iterator<E> get iterator => _backingSet.map((e) => e.$2).iterator;

  @override
  bool add(E e) {
    return _backingSet.add((_priorityFunction(e), e));
  }

  @override
  void clear() => _backingSet.clear();

  @override
  void rebalanceAll() {
    final elements = toList(growable: false);
    clear();
    addAll(elements); // addAll will re-prioritize the elements
  }

  @override
  void rebalanceWhere(bool Function(E element) test) {
    final elements =
        _backingSet.removeWhere((e) => test(e.$2)).map((e) => e.$2);
    addAll(elements); // addAll will re-prioritize the elements
  }

  @override
  bool remove(E e) => _backingSet.remove((_priorityFunction(e), e));

  @override
  Iterable<E> reversed() => _backingSet.reversed().map((e) => e.$2);
}
