import '../models/audit_event.dart';

abstract class AuditLogService {
  Future<void> record(AuditEvent event);
  Future<List<AuditEvent>> listEvents();
}

class InMemoryAuditLogService implements AuditLogService {
  final List<AuditEvent> _events = [];

  @override
  Future<void> record(AuditEvent event) async {
    _events.add(event);
  }

  @override
  Future<List<AuditEvent>> listEvents() async {
    return List.unmodifiable(_events.reversed);
  }
}
