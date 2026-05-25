abstract class RetentionService {
  DateTime expirationForNormalSnapshot(DateTime createdAt);
}

class DefaultRetentionService implements RetentionService {
  @override
  DateTime expirationForNormalSnapshot(DateTime createdAt) {
    return createdAt.add(const Duration(hours: 72));
  }
}
