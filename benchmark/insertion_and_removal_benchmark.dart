import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:ordered_set/ordered_set.dart';

import '../test/comparable_object.dart';

const _iterationAmount = 1000;

class InsertionAndRemovalBenchmark extends BenchmarkBase {
  late final OrderedSet<ComparableObject> set;
  late final Map<int, ComparableObject> objects;

  InsertionAndRemovalBenchmark() : super('Insertion and Removal Benchmark');

  static void main() {
    InsertionAndRemovalBenchmark().report();
  }

  @override
  void setup() {
    set = OrderedSet<ComparableObject>();
    objects = {
      for (var i = 0; i < _iterationAmount; i++) i: ComparableObject(i, '$i'),
    };
  }

  @override
  void exercise() {
    for (var i = 0; i < _iterationAmount; i++) {
      set.add(objects[i]!);
    }

    for (var i = 0; i < _iterationAmount; i++) {
      set.remove(objects[i]!);
    }
  }
}
