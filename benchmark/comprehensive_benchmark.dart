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
      case _NoOp():
        return noop;
      case _AddOp():
        return (type, _randomElement());
      case _RemoveIdxOp():
        if (_set.isEmpty) {
          return noop;
        }
        return (type, r.nextInt(_set.length));
      case _RemoveElementOp():
        if (_set.isEmpty) {
          return noop;
        }
        return (type, _set.elementAt(r.nextInt(_set.length)));
      case _RemoveWhereOp():
        return (type, _randomElement());
      case _VisitOp():
        return (type, _randomElement());
      case _IterateThenAddOp():
        return (type, _randomElement());
      case _IterateThenRemoveOp():
        return (type, _randomElement());
    }
  }

  int _randomElement() => r.nextInt(_maxElement) + 1;
}

sealed class _OperationType {
  static const noop = _NoOp();
  static const add = _AddOp();
  static const removeIdx = _RemoveIdxOp();
  static const removeElement = _RemoveElementOp();
  static const removeWhere = _RemoveWhereOp();
  static const visit = _VisitOp();
  static const iterateThenAdd = _IterateThenAddOp();
  static const iterateThenRemove = _IterateThenRemoveOp();

  static const values = [
    noop,
    add,
    removeIdx,
    removeElement,
    removeWhere,
    visit,
    iterateThenAdd,
    iterateThenRemove,
  ];

  const _OperationType();

  List<_Operation> execute(
    _Operation operation,
    _Runtime runtime,
    OrderedSet<int> set,
  );
}

/// Just placeholder to return an operation when none is desired.
class _NoOp extends _OperationType {
  const _NoOp();

  @override
  List<_Operation> execute(
    _Operation operation,
    _Runtime runtime,
    OrderedSet<int> set,
  ) {
    return [];
  }
}

/// When queued, generates a random element; then adds using `add`.
class _AddOp extends _OperationType {
  const _AddOp();

  @override
  List<_Operation> execute(
    _Operation operation,
    _Runtime runtime,
    OrderedSet<int> set,
  ) {
    set.add(operation.$2);
    return [];
  }
}

/// When queued, selects a random index; then removes using `removeAt`.
class _RemoveIdxOp extends _OperationType {
  const _RemoveIdxOp();

  @override
  List<_Operation> execute(
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
}

/// When queued, selects a random element; then removes using `remove`.
class _RemoveElementOp extends _OperationType {
  const _RemoveElementOp();

  @override
  List<_Operation> execute(
    _Operation operation,
    _Runtime runtime,
    OrderedSet<int> set,
  ) {
    set.remove(operation.$2);
    return [];
  }
}

/// When queued, generates a random factor; then removes all elements with
/// that factor using `removeWhere`.
class _RemoveWhereOp extends _OperationType {
  const _RemoveWhereOp();

  @override
  List<_Operation> execute(
    _Operation operation,
    _Runtime runtime,
    OrderedSet<int> set,
  ) {
    set.removeWhere((e) => e % operation.$2 == 0);
    return [];
  }
}

/// When queued, generates a random factor; then finds the elements matching
/// that factor, using normal for iteration.
class _VisitOp extends _OperationType {
  const _VisitOp();

  @override
  List<_Operation> execute(
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
}

/// When queued, generates two random factors; iterates over the set,
/// finds elements that match the first factor, then multiplies them by
/// the second factor, queue adding the results with the `add` operation
class _IterateThenAddOp extends _OperationType {
  const _IterateThenAddOp();
  @override
  List<_Operation> execute(
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
}

/// When queued, generates a random factor; iterates over the set, finding
/// elements that match the factor, then queue their removal with
/// the `removeElement` operation.
class _IterateThenRemoveOp extends _OperationType {
  const _IterateThenRemoveOp();

  @override
  List<_Operation> execute(
    _Operation operation,
    _Runtime runtime,
    OrderedSet<int> set,
  ) {
    final output = <_Operation>[];
    for (final e in set) {
      if (e % operation.$2 == 0) {
        output.add((_OperationType.removeElement, e));
      }
    }
    return output;
  }
}

typedef _Operation = (_OperationType, int);

int _countFactors(int initialValue, int factor) {
  var count = 0;
  var value = initialValue;
  while (value % factor == 0) {
    count++;
    value ~/= factor;
  }
  return count;
}
