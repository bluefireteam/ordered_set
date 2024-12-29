import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

const _maxOperations = 2500;
const _maxElement = 10000;
const _startingSetSize = 500;

class ComprehensiveBenchmark extends BenchmarkBase {
  final Random r;
  final _runtimes = <_Runtime>[];

  ComprehensiveBenchmark({
    required int seed,
  })  : r = Random(seed),
        super('Comprehensive Benchmark');

  static void main() {
    ComprehensiveBenchmark(seed: 69420).report();
  }

  @override
  void setup() {
    final primes = [2, 3, 5, 7, 11];
    _runtimes.clear();
    _runtimes.addAll(
      [
        // all elements have the same compare factor
        Comparing.on<int>((e) => 0),
        // all elements are only equal to themselves
        Comparing.on<int>((e) => e),
        // equal by certain prime factor count
        ...primes.map(
          (p) => Comparing.on<int>((e) => _countFactors(e, p)),
        ),
      ].map((e) => _Runtime(r: r, compare: e)),
    );
  }

  @override
  void exercise() {
    for (final runtime in _runtimes) {
      runtime.clear();
      runtime.iterate();
    }
  }
}

class _Runtime {
  final Random r;

  var _totalOperations = 0;
  final List<_Operation> _queue;
  final OrderedSet<int> _set;

  _Runtime({
    required this.r,
    required Comparator<int> compare,
  })  : _set = OrderedSet<int>(compare),
        _queue = [];

  void clear() {
    _totalOperations = 0;
    _queue.clear();
    _set.clear();
  }

  void iterate() {
    _populateSet();

    while (_totalOperations < _maxOperations) {
      final operation = _randomOperation();
      _queueOp(operation);
    }

    while (_queue.isNotEmpty) {
      final op = _queue.removeAt(0);
      op.execute(this, _set).forEach(_queueOp);
    }
  }

  void _populateSet() {
    for (var i = 0; i < _startingSetSize; i++) {
      _queueOp(_AddOperation(_randomElement()));
    }
  }

  void _queueOp(_Operation op) {
    _totalOperations++;
    _queue.insert(r.nextInt(_queue.length + 1), op);
  }

  _Operation _randomOperation() {
    final type = _OperationType.values[r.nextInt(_OperationType.values.length)];
    switch (type) {
      case _OperationType.add:
        return _AddOperation(_randomElement());
      case _OperationType.removeIdx:
        if (_set.isEmpty) {
          return _AddOperation(_randomElement());
        }
        return _RemoveIdxOperation(r.nextInt(_set.length));
      case _OperationType.removeElement:
        if (_set.isEmpty) {
          return _AddOperation(_randomElement());
        }
        return _RemoveElementOperation(_set.elementAt(r.nextInt(_set.length)));
      case _OperationType.removeWhere:
        return _RemoveWhereOperation(_randomElement());
      case _OperationType.visit:
        return _VisitOperation(_randomElement());
      case _OperationType.iterateThenAdd:
        return _IterateThenAddOperation(_randomElement());
      case _OperationType.iterateThenRemove:
        return _IterateThenRemoveOperation(_randomElement());
    }
  }

  int _randomElement() => r.nextInt(_maxElement) + 1;
}

enum _OperationType {
  // when queued, generates a random element; then adds using `add`
  add,
  // when queued, selects a random index; then removes using `removeAt`
  removeIdx,
  // when queued, selects a random element; then removes using `remove`
  removeElement,
  // when queued, generates a random factor; then removes all elements with
  // that factor using `removeWhere`
  removeWhere,
  // when queued, generates a random factor; then finds the elements matching
  // that factor, using normal for iteration
  visit,
  // when queued, generates two random factors; iterates over the set,
  //finds elements that match the first factor, then multiplies them by
  //the second factor, queue adding the results with the `add` operation
  iterateThenAdd,
  // when queued, generates a random factor; iterates over the set, finding
  // elements that match the factor, then queue their removal with
  // the `removeElement` operation
  iterateThenRemove,
}

abstract class _Operation {
  final _OperationType type;

  const _Operation(this.type);

  List<_Operation> execute(_Runtime runtime, OrderedSet<int> set);
}

class _AddOperation extends _Operation {
  final int element;

  _AddOperation(this.element) : super(_OperationType.add);

  @override
  List<_Operation> execute(_Runtime runtime, OrderedSet<int> set) {
    set.add(element);
    return [];
  }
}

class _RemoveIdxOperation extends _Operation {
  final int index;

  _RemoveIdxOperation(this.index) : super(_OperationType.removeIdx);

  @override
  List<_Operation> execute(_Runtime runtime, OrderedSet<int> set) {
    if (index < set.length) {
      set.removeAt(index);
    }
    return [];
  }
}

class _RemoveElementOperation extends _Operation {
  final int element;

  _RemoveElementOperation(this.element) : super(_OperationType.removeElement);

  @override
  List<_Operation> execute(_Runtime runtime, OrderedSet<int> set) {
    set.remove(element);
    return [];
  }
}

class _RemoveWhereOperation extends _Operation {
  final int factor;

  _RemoveWhereOperation(this.factor) : super(_OperationType.removeWhere);

  @override
  List<_Operation> execute(_Runtime runtime, OrderedSet<int> set) {
    set.removeWhere((e) => e % factor == 0);
    return [];
  }
}

class _VisitOperation extends _Operation {
  final int factor;

  _VisitOperation(this.factor) : super(_OperationType.visit);

  @override
  List<_Operation> execute(_Runtime runtime, OrderedSet<int> set) {
    final output = <_Operation>[];
    for (final e in set) {
      if (e % factor == 0) {
        output.add(_AddOperation(e * factor));
      }
    }
    return output;
  }
}

class _IterateThenAddOperation extends _Operation {
  final int factor;

  _IterateThenAddOperation(this.factor) : super(_OperationType.iterateThenAdd);

  @override
  List<_Operation> execute(_Runtime runtime, OrderedSet<int> set) {
    final toAdd = <int>[];
    for (final e in set) {
      if (e % factor == 0) {
        toAdd.add(e);
      }
    }

    return toAdd.map(_AddOperation.new).toList();
  }
}

class _IterateThenRemoveOperation extends _Operation {
  final int factor;

  _IterateThenRemoveOperation(this.factor)
      : super(_OperationType.iterateThenRemove);

  @override
  List<_Operation> execute(_Runtime runtime, OrderedSet<int> set) {
    final toRemove = <int>[];
    for (final e in set) {
      if (e % factor == 0) {
        toRemove.add(e);
      }
    }
    return toRemove.map(_RemoveElementOperation.new).toList();
  }
}

int _countFactors(int initialValue, int factor) {
  var count = 0;
  var value = initialValue;
  while (value % factor == 0) {
    count++;
    value ~/= factor;
  }
  return count;
}
