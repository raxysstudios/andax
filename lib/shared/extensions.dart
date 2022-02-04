extension TitleCase on String? {
  String get titleCase {
    final text = this;
    if (text == null) return '';
    return text
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ')
        .split('-')
        .where((s) => s.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join('-');
  }
}
