import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

import 'benchmarks/comprehensive_benchmark.dart';
import 'benchmarks/insertion_and_removal_benchmark.dart';
import 'benchmarks/iteration_benchmark.dart';
import 'types.dart';

void main() {
  OrderedSet<K> comparing<K>(Mapper<K> mapper) {
    return OrderedSet.comparing<K>(compare: Comparing.on(mapper));
  }

  OrderedSet<K> priority<K>(Mapper<K> mapper) {
    return OrderedSet.mapping<num, K>(mapper);
  }

  final producers = {
    'Comparing': comparing,
    'Priority': priority,
  };

  for (final MapEntry(key: name, value: producer) in producers.entries) {
    IterationBenchmark(
      name: name,
      seed: 42690,
      producer: producer,
    ).report();
    InsertionAndRemovalBenchmark(
      name: name,
      seed: 42690,
      producer: producer,
    ).report();
    ComprehensiveBenchmark(
      name: name,
      seed: 42690,
      producer: producer,
    ).report();
  }
}
