import 'dart:collection';

abstract class ReadOnlyOrderedSet<E> extends IterableMixin<E> {
  /// The tree's elements in reversed order; should be cached when possible.
  Iterable<E> reversed();

  /// Controls whether running an unregistered query throws an error or
  /// performs just-in-time filtering.
  bool get strictMode;

  /// Whether type [C] is registered as a cache
  bool isRegistered<C extends E>();

  /// Adds a new cache for a subtype [C] of [E], allowing you to call [query].
  /// If the cache already exists this operation is a no-op.
  ///
  /// If the set is not empty, the current elements will be re-sorted.
  ///
  /// It is recommended to [register] all desired types at the beginning of
  /// your application to avoid recomputing the existing elements upon
  /// registration.
  void register<C extends E>();

  /// Allow you to find a subset of this set with all the elements `e` for
  /// which the condition `e is C` is true. This is equivalent to
  ///
  /// ```dart
  ///   orderedSet.whereType<C>()
  /// ```
  ///
  /// except that it is O(0).
  ///
  /// Note: you *must* call [register] for every type [C] you desire to use
  /// before calling this, or set [strictMode] to false.
  Iterable<C> query<C extends E>();
}
