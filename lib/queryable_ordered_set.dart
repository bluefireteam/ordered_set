import 'ordered_set.dart';

class _CacheEntry<C, T> {
  final List<C> data;

  _CacheEntry({required this.data});

  bool check(T t) {
    return t is C;
  }
}

class QueryableOrderedSet<T> extends OrderedSet<T> {
  final Map<Type, _CacheEntry<T, T>> _cache = {};

  QueryableOrderedSet([int Function(T e1, T e2)? compare]) : super(compare);

  void register<C extends T>() {
    _cache[C] = _CacheEntry<C, T>(
      data: _filter<C>(),
    );
  }

  List<C> query<C extends T>() {
    final result = _cache[C];
    if (result == null) {
      throw 'Cannot query unregistered query $C';
    }
    return result.data as List<C>;
  }

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
  Iterable<T> removeWhere(bool Function(T element) test) {
    _cache.values.forEach((v) => v.data.removeWhere(test));
    return super.removeWhere(test);
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
