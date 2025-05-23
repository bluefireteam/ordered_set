// ignore_for_file: avoid_print

import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

void main() {
  final items = OrderedSet.comparing<int>();
  items.add(2);
  items.add(1);
  print(items.toList()); // [1, 2]

  final a = OrderedSet.comparing<Person>(compare: (a, b) => a.age - b.age);
  a.add(Person(12, 'Klaus'));
  a.add(Person(1, 'Sunny'));
  a.add(Person(14, 'Violet'));
  print(a.elementAt(0).name); // Sunny
  print(a.elementAt(2).name); // Violet

  a.add(Person(13, 'Isadora'));
  a.add(Person(13, 'Duncan'));
  a.add(Person(13, 'Quigley'));
  print(a.toList().map((e) => e.name));
  // Sunny, Klaus, Isadora, Duncan, Quigley, Violet

  // use Comparing for simpler creation:
  // sort by age desc and then name asc
  final b = OrderedSet.comparing<Person>(
    compare: Comparing.join([(p) => -p.age, (p) => p.name]),
  );
  b.addAll(a.toList());
  print(b.toList().map((e) => e.name));
  // Violet, Duncan, Isadora, Quigley, Klaus, Sunny

  // or use the PriorityOrderedSet for static priorities
  final c = OrderedSet.mapping<num, Person>((p) => p.age);
  c.addAll(a.toList());
  print(c.toList().map((e) => e.name));
  // Sunny, Klaus, Isadora, Duncan, Quigley, Violet
}

class Person {
  int age;
  String name;
  Person(this.age, this.name);
}
