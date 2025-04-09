import 'package:ordered_set/ordered_set.dart';

typedef Mapper<K> = int Function(K);
typedef Producer<K> = OrderedSet<K> Function(Mapper<K>);
