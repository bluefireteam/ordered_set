import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

const _maxOperations = 1000;
const _maxElement = 10000;
const _startingSetSize = 250;

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
      op.$1.execute(op, this, _set).forEach(_queueOp);
    }
  }

  void _populateSet() {
    for (var i = 0; i < _startingSetSize; i++) {
      _queueOp((_OperationType.add, _randomElement()));
    }
  }

  void _queueOp(_Operation op) {
    _totalOperations++;
    _queue.insert(r.nextInt(_queue.length + 1), op);
  }

  _Operation _randomOperation() {
    final type = _OperationType.values[r.nextInt(_OperationType.values.length)];
    const noop = (_OperationType.noop, 0);
    switch (type) {
      case _OperationType.noop:
        return noop;
      case _OperationType.add:
        return (type, _randomElement());
      case _OperationType.removeIdx:
        if (_set.isEmpty) {
          return noop;
        }
        return (type, r.nextInt(_set.length));
      case _OperationType.removeElement:
        if (_set.isEmpty) {
          return noop;
        }
        return (type, _set.elementAt(r.nextInt(_set.length)));
      case _OperationType.removeWhere:
        return (type, _randomElement());
      case _OperationType.visit:
        return (type, _randomElement());
      case _OperationType.iterateThenAdd:
        return (type, _randomElement());
      case _OperationType.iterateThenRemove:
        return (type, _randomElement());
    }
  }

  int _randomElement() => r.nextInt(_maxElement) + 1;
}

enum _OperationType {
  noop(_noopOperation),
  // when queued, generates a random element; then adds using `add`
  add(_addOperation),
  // when queued, selects a random index; then removes using `removeAt`
  removeIdx(_removeIdxOperation),
  // when queued, selects a random element; then removes using `remove`
  removeElement(_removeOperation),
  // when queued, generates a random factor; then removes all elements with
  // that factor using `removeWhere`
  removeWhere(_removeWhereOperation),
  // when queued, generates a random factor; then finds the elements matching
  // that factor, using normal for iteration
  visit(_visitOperation),
  // when queued, generates two random factors; iterates over the set,
  //finds elements that match the first factor, then multiplies them by
  //the second factor, queue adding the results with the `add` operation
  iterateThenAdd(_iterateThenAddOperation),
  // when queued, generates a random factor; iterates over the set, finding
  // elements that match the factor, then queue their removal with
  // the `removeElement` operation
  iterateThenRemove(_iterateThenRemoveOperation),
  ;

  final List<_Operation> Function(_Operation, _Runtime, OrderedSet<int>)
      execute;

  const _OperationType(this.execute);
}

typedef _Operation = (_OperationType, int);

List<_Operation> _noopOperation(
  _Operation operation,
  _Runtime runtime,
  OrderedSet<int> set,
) {
  return [];
}

List<_Operation> _addOperation(
  _Operation operation,
  _Runtime runtime,
  OrderedSet<int> set,
) {
  set.add(operation.$2);
  return [];
}

List<_Operation> _removeOperation(
  _Operation operation,
  _Runtime runtime,
  OrderedSet<int> set,
) {
  set.remove(operation.$2);
  return [];
}

List<_Operation> _removeIdxOperation(
  _Operation operation,
  _Runtime runtime,
  OrderedSet<int> set,
) {
  if (set.isEmpty) {
    return [];
  }
  set.removeAt(operation.$2);
  return [];
}

List<_Operation> _removeWhereOperation(
  _Operation operation,
  _Runtime runtime,
  OrderedSet<int> set,
) {
  set.removeWhere((e) => e % operation.$2 == 0);
  return [];
}

List<_Operation> _visitOperation(
  _Operation operation,
  _Runtime runtime,
  OrderedSet<int> set,
) {
  final output = <_Operation>[];
  for (final e in set) {
    if (e % operation.$2 == 0) {
      output.add((_OperationType.add, e * operation.$2));
    }
  }
  return output;
}

List<_Operation> _iterateThenAddOperation(
  _Operation operation,
  _Runtime runtime,
  OrderedSet<int> set,
) {
  final toAdd = <int>[];
  for (final e in set) {
    if (e % operation.$2 == 0) {
      toAdd.add(e);
    }
  }

  return toAdd.map((e) => (_OperationType.add, e)).toList();
}

List<_Operation> _iterateThenRemoveOperation(
  _Operation operation,
  _Runtime runtime,
  OrderedSet<int> set,
) {
  final toRemove = <int>[];
  for (final e in set) {
    if (e % operation.$2 == 0) {
      toRemove.add(e);
    }
  }
  return toRemove.map((e) => (_OperationType.removeElement, e)).toList();
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
