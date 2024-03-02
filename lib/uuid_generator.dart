
import 'package:uuid/uuid.dart';


/// UUID Generator used as unique id for bundle store policy.
/// Internal cache for unique id generator.
class UUIDGenerator {
  final Set<String> _cache = {};

  /// get unique uuid
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