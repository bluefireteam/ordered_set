import 'package:ordered_set/ordered_set.dart';

main() {
  OrderedSet<int> items = new OrderedSet();
  items.add(2);
  items.add(1);
  print(items.toList()); // [1, 2]

  OrderedSet<Person> a = new OrderedSet((a, b) => a.age - b.age);
  a.add(new Person(12, 'Klaus'));
  a.add(new Person(1, 'Sunny'));
  a.add(new Person(14, 'Violet'));
  print(a.elementAt(0).name); // Sunny
  print(a.elementAt(2).name); // Violet

  a.add(new Person(13, 'Isadora'));
  a.add(new Person(13, 'Duncan'));
  a.add(new Person(13, 'Quigley'));
  print(a.toList().map((e) => e.name)); // Sunny, Klaus, Isadora, Duncan, Quigley, Violet
}

class Person {
  int age;
  String name;
  Person(this.age, this.name);
}
