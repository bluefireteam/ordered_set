import 'ordered_set.dart';

class _CacheEntry<C, T> {
  final List<C> data;

  _CacheEntry({required this.data});

  bool check(T t) {
    return t is C;
  }
}

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
class QueryableOrderedSet<T> extends OrderedSet<T> {
  /// Controls whether running an unregistered query throws an error or
  /// performs just-in-time filtering.
  final bool strictMode;
  final Map<Type, _CacheEntry<T, T>> _cache = {};

  QueryableOrderedSet({
    int Function(T e1, T e2)? comparator,
    this.strictMode = true,
  }) : super(comparator);

  /// Adds a new cache for a subtype [C] of [T], allowing you to call [query].
  /// If the cache already exists this operation is a no-op.
  ///
  /// If the set is not empty, the current elements will be re-sorted.
  ///
  /// It is recommended to [register] all desired types at the beginning of
  /// your application to avoid recomputing the existing elements upon
  /// registration.
  void register<C extends T>() {
    if (isRegistered<C>()) {
      return;
    }
    _cache[C] = _CacheEntry<C, T>(
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
  List<C> query<C extends T>() {
    final result = _cache[C];
    if (result == null) {
      if (strictMode) {
        throw 'Cannot query unregistered query $C';
      } else {
        register<C>();
        return query<C>();
      }
    }
    return result.data as List<C>;
  }

  /// Whether type [C] is registered as a cache
  bool isRegistered<C>() => _cache.containsKey(C);

  @override
  bool add(T t) {
    if (super.add(t)) {
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
  bool remove(T e) {
    _cache.values.forEach((v) => v.data.remove(e));
    return super.remove(e);
  }

  @override
  void clear() {
    _cache.values.forEach((v) => v.data.clear());
    super.clear();
  }

  List<C> _filter<C extends T>() => whereType<C>().toList();
}
