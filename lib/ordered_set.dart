import 'dart:collection';

/// A simple implementation for an ordered set for Dart.
///
/// It accepts a compare function that compares items for their priority.
/// Unlike [SplayTreeSet], it allows for several different elements with the same priority to be added.
/// It also implements [Iterable], so you can iterate it in O(n).
class OrderedSet<E> extends IterableMixin<E> implements Iterable<E> {
  SplayTreeSet<List<E>> _backingSet;
  int _length;

  // gotten from SplayTreeSet, but those are private there
  static int _dynamicCompare(dynamic a, dynamic b) => Comparable.compare(a, b);
  static Comparator<K> _defaultCompare<K>() {
    Object compare = Comparable.compare;
    if (compare is Comparator<K>) {
      return compare;
    }
    return _dynamicCompare;
  }

  /// Creates a new [OrderedSet] with the given compare function.
  ///
  /// If the [compare] function is omitted, it defaults to [Comparable.compare], and the elements must be comparable.
  OrderedSet([int Function(E e1, E e2) compare]) {
    final comparator = compare ?? _defaultCompare<E>();
    _backingSet = SplayTreeSet<List<E>>((List<E> l1, List<E> l2) {
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

  /// Gets the current length of this
  ///
  /// Returns the cached length of this, in O(1).
  /// This is the full length, i.e., the sum of the lengths of each bucket.
  @override
  int get length => _length;

  @override
  Iterator<E> get iterator {
    return _backingSet.expand<E>((es) => es).iterator;
  }

  /// Adds each element of the provided [es] to this and returns the number of elements added.
  ///
  /// Since elements are always added, this should always return the length of [es].
  int addAll(Iterable<E> es) {
    return es.map((e) => add(e)).where((e) => e).length;
  }

  /// Adds the element [e] to this, and returns wether the element was succesfully added or not.
  ///
  /// You can always add elements, even duplicated elemneted are added, so this always return true.
  bool add(E e) {
    _length++;
    final added = _backingSet.add([e]);
    if (!added) {
      _backingSet.lookup([e]).add(e);
    }
    return true;
  }

  /// Remove all elements that match the [test] condition, returns the removed elements
  Iterable<E> removeWhere(bool Function(E element) test) {
    return this.where(test).toList()..forEach((e) => this.remove(e));
  }

  /// Remove a single element that is equal to [e].
  ///
  /// If there are multiple elements identical to [e], only the first will be removed.
  /// To remove all, use something like:
  ///
  ///     set.removeWhere((a) => a == e);
  ///
  bool remove(E e) {
    final bucket = _backingSet.lookup([e]);
    if (bucket == null) {
      return false;
    }
    final result = bucket.remove(e);
    if (result) {
      _length--;
      _backingSet.remove(<E>[]);
    }
    return result;
  }

  /// Removes all elements of this.
  void clear() {
    _backingSet.clear();
    _length = 0;
  }
}
