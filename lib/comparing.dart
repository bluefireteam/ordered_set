class Comparing {
  static Comparator<T> reverse<T>(Comparator<T> comparator) {
    return (a, b) => -comparator(a, b);
  }

  static Comparator<T> on<T>(Comparable Function(T t) mapper) {
    return (a, b) => mapper(a).compareTo(mapper(b));
  }

  static Comparator<T> join<T>(List<Comparable Function(T t)> mappers) {
    return (a, b) {
      int r = on(mappers.first)(a, b);
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
