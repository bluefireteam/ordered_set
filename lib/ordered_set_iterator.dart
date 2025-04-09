import 'package:ordered_set/ordered_set.dart';

/// An iterator that flattens and iterates an [OrderedSet] without
/// any additional overhead.
class OrderedSetIterator<E> implements Iterator<E> {
  final Iterator<Set<E>> _iterator;
  Iterator<E>? _innerIterator;

  OrderedSetIterator.from(this._iterator);

  @override
  E get current => _innerIterator!.current;

  @pragma('vm:prefer-inline')
  @pragma('wasm:prefer-inline')
  @override
  bool moveNext() {
    if (_innerIterator?.moveNext() != true) {
      final result = _iterator.moveNext();

      if (!result) {
        return false;
      }

      _innerIterator = _iterator.current.iterator;
      _innerIterator!.moveNext();
      return true;
    }
    return true;
  }
}
