import 'package:ordered_set/ordered_set.dart';

/// This is a mixin to provide the query caching capabilities to both
/// [OrderedSet] implementations.
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
mixin QueryableOrderedSetImpl<E> on OrderedSet<E> {
  final Map<Type, _CacheEntry<E, E>> _cache = {};

  @override
  void register<C extends E>() {
    if (isRegistered<C>()) {
      return;
    }
    _cache[C] = _CacheEntry<C, E>(
      data: _filter<C>(),
    );
  }

  @override
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

  @override
  bool isRegistered<C extends E>() => _cache.containsKey(C);

  void onAdd(E t) {
    _cache.forEach((key, value) {
      if (value.check(t)) {
        value.data.add(t);
      }
    });
  }

  void onRemove(E e) {
    _cache.values.forEach((v) => v.data.remove(e));
  }

  void onClear() {
    _cache.values.forEach((v) => v.data.clear());
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
