import 'package:ordered_set/ordered_set.dart';

/// This is an implementation of [OrderedSet] that allows you to more
/// efficiently [query] the list.
///
/// You can [register] a set of queries, i.e., predefined sub-types, whose
/// results, i.e., subsets of this set, are then cached. Since the queries
/// have to be type checks, and types are runtime constants, this can be
/// vastly optimized.
///
/// If you find yourself doing a lot of:
///
/// ```dart
///   orderedSet.whereType<Foo>()
/// ```
///
/// On your code, and are concerned you are iterating a very long O(n) list to
/// find a handful of elements, specially if this is done every tick, you
/// can use this class, that pays a small O(number of registers) cost on [add],
/// but lets you find (specific) subsets at O(0).
///
/// Note that you can change [strictMode] to allow for querying for unregistered
/// types; if you do so, the registration cost is payed on the first query.
class QueryableOrderedSet<E> extends OrderedSet<E> {
  /// Controls whether running an unregistered query throws an error or
  /// performs just-in-time filtering.
  final bool strictMode;
  final Map<Type, _CacheEntry<E, E>> _cache = {};
  final OrderedSet<E> _backingSet;

  QueryableOrderedSet(
    this._backingSet, {
    this.strictMode = true,
  });

  /// Adds a new cache for a subtype [C] of [E], allowing you to call [query].
  /// If the cache already exists this operation is a no-op.
  ///
  /// If the set is not empty, the current elements will be re-sorted.
  ///
  /// It is recommended to [register] all desired types at the beginning of
  /// your application to avoid recomputing the existing elements upon
  /// registration.
  void register<C extends E>() {
    if (isRegistered<C>()) {
      return;
    }
    _cache[C] = _CacheEntry<C, E>(
      data: _filter<C>(),
    );
  }

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
  Iterable<C> query<C extends E>() {
    final result = _cache[C];
    if (result == null) {
      if (strictMode) {
        throw 'Cannot query unregistered query $C';
      } else {
        register<C>();
        return query<C>();
      }
    }
    // We are returning the cached List itself but we cast it as an Iterable
    // to prevent users from accidentally modifying the cache from outside.
    // We are not using an UnmodifiableListView() or anything similar because
    // we want to avoid creating a new object for every query.
    return result.data as Iterable<C>;
  }

  /// Creates a new lazy [Iterable] with all elements that have type [C].
  ///
  /// When available, the cached result is used (as in [query])
  /// in constant time. Otherwise, this works exactly the same as
  /// [Iterable.whereType], in linear time.
  @override
  Iterable<C> whereType<C>() {
    final result = _cache[C];
    if (result != null) {
      return result.data as Iterable<C>;
    }
    return super.whereType<C>();
  }

  /// Whether type [C] is registered as a cache
  bool isRegistered<C>() => _cache.containsKey(C);

  @override
  int get length => _backingSet.length;

  @override
  Iterator<E> get iterator => _backingSet.iterator;

  @override
  Iterable<E> reversed() => _backingSet.reversed();

  @override
  void rebalanceAll() {
    _backingSet.rebalanceAll();
  }

  @override
  void rebalanceWhere(bool Function(E element) test) {
    _backingSet.rebalanceWhere(test);
  }

  @override
  bool add(E t) {
    if (_backingSet.add(t)) {
      _cache.forEach((key, value) {
        if (value.check(t)) {
          value.data.add(t);
        }
      });
      return true;
    }
    return false;
  }

  @override
  bool remove(E e) {
    _cache.values.forEach((v) => v.data.remove(e));
    return _backingSet.remove(e);
  }

  @override
  void clear() {
    _cache.values.forEach((v) => v.data.clear());
    _backingSet.clear();
  }

  List<C> _filter<C extends E>() => whereType<C>().toList();
}

class _CacheEntry<C, T> {
  final List<C> data;

  _CacheEntry({required this.data});

  bool check(T t) {
    return t is C;
  }
}
