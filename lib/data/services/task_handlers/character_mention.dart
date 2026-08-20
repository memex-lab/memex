/// Find `@token` only as a standalone mention, not as a prefix of a longer word.
///
/// `@Bob` matches in `hi @Bob` and `@Bob.`, but not in `@Bobby` or `mail@Bob`.
int indexOfStandaloneMention(String content, String mention) {
  if (mention.isEmpty) return -1;

  var start = 0;
  while (true) {
    final index = content.indexOf(mention, start);
    if (index < 0) return -1;
    if (_isStandaloneMentionAt(content, index, mention.length)) {
      return index;
    }
    start = index + 1;
  }
}

bool _isStandaloneMentionAt(String content, int index, int length) {
  if (index > 0 && _isAsciiWordChar(content.codeUnitAt(index - 1))) {
    return false;
  }
  final end = index + length;
  if (end < content.length && _isAsciiWordChar(content.codeUnitAt(end))) {
    return false;
  }
  return true;
}

bool _isAsciiWordChar(int codeUnit) {
  final isDigit = codeUnit >= 48 && codeUnit <= 57;
  final isUpper = codeUnit >= 65 && codeUnit <= 90;
  final isLower = codeUnit >= 97 && codeUnit <= 122;
  return isDigit || isUpper || isLower || codeUnit == 95;
}
