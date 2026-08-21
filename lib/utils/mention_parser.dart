/// Finds [mention] only when it is standalone, not a prefix of a longer word.
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
  if (index > 0 && !_isMentionBoundary(content[index - 1])) {
    return false;
  }
  final end = index + length;
  if (end < content.length && !_isMentionBoundary(content[end])) {
    return false;
  }
  return true;
}

bool _isMentionBoundary(String character) {
  if (character.trim().isEmpty) return true;
  return _mentionPunctuation.contains(character);
}

const _mentionPunctuation =
    r'''!"#$%&'()*+,-./:;<=>?@[\]^`{|}~，。！？；：（）【】《》、“”‘’…—''';
