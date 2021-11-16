/// Class with helper methods that allow for easier creation of Comparators.
class Comparing {
  Comparing._();

  /// Reverses a given comparator, that is, change it from ascending to
  /// descending or vice-versa.
  static Comparator<T> reverse<T>(Comparator<T> comparator) {
    return (a, b) => -comparator(a, b);
  }

  /// Returns a Comparator that compares objects of type T by mapping them to
  /// Comparables.
  static Comparator<T> on<T>(Comparable Function(T t) mapper) {
    return (a, b) => mapper(a).compareTo(mapper(b));
  }

  /// Use if you already have a custom comparator you wish to use but your list
  /// needs some mapping to get to the comparator's type.
  /// I.e., creates a Comparator<V> given a Comparator<T> and a mapper V -> T.
  static Comparator<V> mapping<T, V>(
    Comparator<T> comparator,
    T Function(V v) mapper,
  ) {
    return (a, b) => comparator(mapper(a), mapper(b));
  }

  /// Join several mappers and compare in order (first the first element, then
  /// the second, and so on).
  static Comparator<T> join<T>(List<Comparable Function(T t)> mappers) {
    return (a, b) {
      final r = on(mappers.first)(a, b);
      if (r == 0) {
        if (mappers.length == 1) {
          return 0;
        }
        return join(mappers.sublist(1))(a, b);
      } else {
        return r;
      }
    };
  }
}
