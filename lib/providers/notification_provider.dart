import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';

final notificationInitProvider = FutureProvider<void>((ref) {
  return NotificationService.instance.init();
});
