import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:ordered_set/ordered_set.dart';

class OtherBenchmark extends BenchmarkBase {
  final OrderedSet<int> set = OrderedSet();

  OtherBenchmark() : super('Other Benchmark');

  static void main() {
    OtherBenchmark().report();
  }

  @override
  void setup() {
    for (var i = 0; i < 1000; i++) {
      for (var j = 0; j <= i; j++) {
        set.add(i);
      }
    }
  }

  @override
  void exercise() {
    for (final element in set) {
      _consume(element);
    }
  }

  void _consume(int obj) {
    // NO-OP
  }
}
