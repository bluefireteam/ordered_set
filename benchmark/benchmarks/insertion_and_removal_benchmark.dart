import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:ordered_set/ordered_set.dart';

import '../../test/comparable_object.dart';
import '../types.dart';

const _iterationAmount = 1000;

class InsertionAndRemovalBenchmark extends BenchmarkBase {
  final Random r;
  final OrderedSet<ComparableObject> set;
  late final Map<int, ComparableObject> objects;

  InsertionAndRemovalBenchmark({
    required String name,
    required int seed,
    required Producer<ComparableObject> producer,
  })  : r = Random(seed),
        set = producer((e) => e.priority),
        objects = {},
        super('Insertion and Removal Benchmark - $name');

  @override
  void setup() {
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
