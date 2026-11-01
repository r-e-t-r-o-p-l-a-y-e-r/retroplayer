/// Keyboard selection over a list of [length] rows.
///
/// Used by the library browse list and playlist detail so both share the
/// same clamp / move / first / last rules.
class SelectableListController {
  int? selectedIndex;
  int length = 0;

  void setLength(int newLength) {
    length = newLength;
    clamp();
  }

  void clear() => selectedIndex = null;

  void clamp() {
    if (length <= 0) {
      selectedIndex = null;
      return;
    }
    final index = selectedIndex;
    if (index == null) return;
    if (index >= length) selectedIndex = length - 1;
    if (selectedIndex! < 0) selectedIndex = 0;
  }

  void move(int delta) {
    if (length <= 0) return;
    if (selectedIndex == null) {
      selectedIndex = delta > 0 ? 0 : length - 1;
    } else {
      selectedIndex = (selectedIndex! + delta).clamp(0, length - 1);
    }
  }

  void selectFirst() {
    if (length <= 0) return;
    selectedIndex = 0;
  }

  void selectLast() {
    if (length <= 0) return;
    selectedIndex = length - 1;
  }

  bool selectAt(int index) {
    if (index < 0 || index >= length) return false;
    selectedIndex = index;
    return true;
  }
}
