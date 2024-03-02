
import 'package:uuid/uuid.dart';

class UUIDGenerator {
  final Set<String> _cache = {};

  String getUUID() {
    var uuid = const Uuid();
    bool finish = false;

    String toReturn = uuid.v4();
    while (!finish) {
      toReturn = uuid.v4();
      if (!_cache.contains(toReturn)) {
        _cache.add(toReturn);
        finish = true;
      }
    }

    return toReturn;
  }
}