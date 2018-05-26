class ComparableObject extends Comparable<ComparableObject> {
  int priority;
  String name;

  ComparableObject(this.priority, this.name);

  @override
  int compareTo(ComparableObject other) => priority - other.priority;

  @override
  String toString() => name;
}
