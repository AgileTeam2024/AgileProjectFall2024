extension ListExt<T> on List<T> {
  List<List<T>> fixedGrouped<T>({required int groupSize}) {
    if (isEmpty) return [];
    final lists = <List<T>>[[]];
    for (var value in this) {
      final lastList = lists.last;
      if (lastList.length == groupSize) {
        lists.add([value as T]);
      } else {
        lastList.add(value as T);
      }
    }
    return lists;
  }
}
