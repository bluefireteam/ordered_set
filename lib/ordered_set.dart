import 'dart:collection';

import 'package:ordered_set/comparing_ordered_set.dart';
import 'package:ordered_set/mapping_ordered_set.dart';
import 'package:ordered_set/queryable_ordered_set.dart';

/// A simple interface of an ordered set for Dart.
///
/// It accepts some way of comparing items for their priority. Unlike
/// [SplayTreeSet], it allows for several different elements with the same
/// priority to be added. It also implements [Iterable], so you can iterate it
/// in O(n).
abstract class OrderedSet<E> extends IterableMixin<E> {
  /// The tree's elements in reversed order; should be cached when possible.
  Iterable<E> reversed();

  /// Adds the element [e] to this, and returns whether the element was
  /// added or not. If the element already exists in the collection, it isn't
  /// added.
  bool add(E e);

  /// Adds each element of the provided [elements] to this and returns the
  /// number of elements added.
  int addAll(Iterable<E> elements) {
    final lengthBefore = length;
    for (final element in elements) {
      add(element);
    }
    return length - lengthBefore;
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
  /// Note: this is a potentially expensive operation, and should be used
  /// sparingly.
  void rebalanceAll();

  /// Allows you to rebalance only a portion of the tree. If you are dealing
  /// with non-deterministic compare functions, you probably need to consider
  /// rebalancing.
  /// If the priority function changed for certain known elements but not all,
  /// you can use this instead of [rebalanceAll].
  /// In general be careful with using comparing functions that can change.
  /// Note: rebalancing is **not** stable.
  /// Note: this is a potentially expensive operation, and should be used
  /// sparingly.
  void rebalanceWhere(bool Function(E element) test);

  /// Remove a single element that is equal to [e].
  ///
  /// If there are multiple elements identical to [e], only the first will be
  /// removed. To remove all, use something like:
  ///
  ///     set.removeWhere((a) => a == e);
  ///
  /// Note: when using the [MappingOrderedSet] implementation, this will only
  /// work if the element's priority hasn't changed since last rebalance.
  bool remove(E e);

  /// Remove all elements that match the [test] condition; returns the removed
  /// elements.
  Iterable<E> removeWhere(bool Function(E element) test) {
    return where(test).toList(growable: false)..forEach(remove);
  }

  /// Remove all [elements] and returns the removed elements.
  Iterable<E> removeAll(Iterable<E> elements) {
    return elements.where(remove).toList(growable: false);
  }

  /// Removes the element at [index].
  bool removeAt(int index) => remove(elementAt(index));

  /// Removes all elements of this.
  void clear();

  /// Creates an instance of [OrderedSet] using the [ComparingOrderedSet]
  /// implementation and the provided [compare] function.
  ///
  /// This implementation will not store component priorities, so it is
  /// susceptible to race conditions if priorities are changed while iterating.
  static ComparingOrderedSet<E> comparing<E>([
    int Function(E a, E b)? compare,
  ]) {
    return ComparingOrderedSet<E>(compare);
  }

  /// Creates an instance of [OrderedSet] using the [MappingOrderedSet]
  /// implementation and the provided [mappingFunction].
  static MappingOrderedSet<K, E> mapping<K extends Comparable<K>, E>(
    K Function(E a) mappingFunction,
  ) {
    return MappingOrderedSet(mappingFunction);
  }

  /// Creates an instance of [OrderedSet] for items that are already
  /// [Comparable] using the [MappingOrderedSet] implementation.
  /// Use this for classes that implement [Comparable] of a different class.
  /// Equivalent to `mapping<K, E>((a) => a)`.
  static MappingOrderedSet<K, E>
      comparable<K extends Comparable<K>, E extends K>() {
    return mapping<K, E>((a) => a);
  }

  /// Creates an instance of [OrderedSet] for items that are already
  /// [Comparable] of themselves, using the [MappingOrderedSet] implementation.
  /// Use this for classes that implement [Comparable] of themselves.
  /// Equivalent to `mapping<K, K>((a) => a)`.
  static MappingOrderedSet<E, E> simple<E extends Comparable<E>>() {
    return comparable<E, E>();
  }

  /// Creates an instance of [OrderedSet] using the [QueryableOrderedSet]
  /// by wrapping the provided [backingSet].
  static QueryableOrderedSet<E> queryable<E>(
    OrderedSet<E> backingSet, {
    bool strictMode = true,
  }) {
    return QueryableOrderedSet<E>(backingSet, strictMode: strictMode);
  }
}
