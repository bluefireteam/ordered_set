import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:ordered_set/ordered_set.dart';

import '../test/comparable_object.dart';

class IterationBenchmark extends BenchmarkBase {
  late final OrderedSet<ComparableObject> set;

  IterationBenchmark() : super('Iteration Benchmark');

  static void main() {
    IterationBenchmark().report();
  }

  @override
  void setup() {
    set = OrderedSet();
    for (var i = 0; i < 1000; i++) {
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
