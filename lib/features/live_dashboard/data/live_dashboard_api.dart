import '../../../core/network/api_client.dart';
import '../models/live_dashboard_models.dart';

class LiveDashboardApi {
  LiveDashboardApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<LiveDashboardData> fetchDashboard({String? lecturerId}) async {
    final results = await Future.wait<dynamic>([
      fetchUnreadCount(),
      fetchNotifications(),
      fetchLecturerAnalytics(lecturerId: lecturerId),
    ]);

    return LiveDashboardData(
      unreadNotifications: results[0] as int,
      notifications: results[1] as List<NotificationItem>,
      analytics: results[2] as LecturerAnalyticsOverview?,
    );
  }

  Future<int> fetchUnreadCount() async {
    final data = await _client.get('/api/notifications/unread-count');
    if (data is Map) {
      return int.tryParse(data['unread']?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    final data = await _client.get('/api/notifications');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => NotificationItem.fromJson(item.map((key, value) => MapEntry(key.toString(), value))))
          .toList();
    }
    return const [];
  }

  Future<LecturerAnalyticsOverview?> fetchLecturerAnalytics({String? lecturerId}) async {
    final query = lecturerId == null || lecturerId.isEmpty ? null : {'lecturer_id': lecturerId};
    final data = await _client.get('/api/lecturer/analytics/overview', query: query);
    if (data is Map) {
      return LecturerAnalyticsOverview.fromJson(data.map((key, value) => MapEntry(key.toString(), value)));
    }
    return null;
  }

  Future<void> markAllNotificationsRead() async {
    await _client.post('/api/notifications/mark-all-read');
  }

  void close() => _client.close();
}
