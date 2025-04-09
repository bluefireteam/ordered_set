import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:ordered_set/ordered_set.dart';

import '../../test/comparable_object.dart';
import '../types.dart';

const _iterationAmount = 1000;

class IterationBenchmark extends BenchmarkBase {
  final Random r;
  final OrderedSet<ComparableObject> set;

  IterationBenchmark({
    required String name,
    required int seed,
    required Producer<ComparableObject> producer,
  })  : r = Random(seed),
        set = producer((e) => e.priority),
        super('Iteration Benchmark - $name');

  @override
  void setup() {
    set.clear();
    for (var i = 0; i < _iterationAmount; i++) {
      final l = (10 + sqrt(i)).floor();
      for (var j = 0; j <= l; j++) {
        set.add(ComparableObject(i, '$i-$j'));
      }
    }
  }

  @override
  void exercise() {
    for (final element in set) {
      _consume(element);
    }
  }

  void _consume(ComparableObject obj) {
    // NO-OP
  }
}
