import '../../../core/network/api_client.dart';

class RoleDashboardApi {
  RoleDashboardApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<RoleDashboardData> fetchForRole(String role) async {
    final normalized = role.toLowerCase().trim();
    if (normalized == 'exam_officer') {
      final results = await Future.wait<dynamic>([
        _client.get('/api/exam-officer/assessments'),
        _client.get('/api/exam-officer/ca-submissions'),
        _client.get('/api/exam-officer/marked-exam-scripts'),
      ]);
      return RoleDashboardData(
        title: 'Exam Officer live queue',
        sections: [
          RoleDashboardSection(title: 'Questions awaiting action', items: _items(results[0], 'title', 'status')),
          RoleDashboardSection(title: 'CA submissions', items: _items(results[1], 'summary', 'status')),
          RoleDashboardSection(title: 'Marked scripts', items: _items(results[2], 'summary', 'status')),
        ],
      );
    }
    if (normalized == 'moderator') {
      final data = await _client.get('/api/moderator/assessments');
      return RoleDashboardData(
        title: 'Moderator live queue',
        sections: [RoleDashboardSection(title: 'Questions to review', items: _items(data, 'title', 'moderation_status'))],
      );
    }
    if (normalized == 'hod' || normalized == 'dlc_director' || normalized == 'admin') {
      final results = await Future.wait<dynamic>([
        _client.get('/api/admin/staff'),
        _client.get('/api/lecturer/analytics/overview'),
        _client.get('/api/notifications'),
      ]);
      return RoleDashboardData(
        title: normalized == 'hod' ? 'HoD live command view' : 'DLC Director live command view',
        sections: [
          RoleDashboardSection(title: 'Staff records', items: _items(results[0], 'first_name', 'primary_role')),
          RoleDashboardSection(title: 'Lecturer analytics', items: [_analyticsItem(results[1])]),
          RoleDashboardSection(title: 'Recent alerts', items: _items(results[2], 'title', 'category')),
        ],
      );
    }

    final results = await Future.wait<dynamic>([
      _client.get('/api/lecturer/analytics/overview'),
      _client.get('/api/lecturer/assignments'),
      _client.get('/api/lecturer/ca-submissions'),
      _client.get('/api/lecturer/marked-exam-scripts'),
    ]);
    return RoleDashboardData(
      title: 'Lecturer live workspace',
      sections: [
        RoleDashboardSection(title: 'My analytics', items: [_analyticsItem(results[0])]),
        RoleDashboardSection(title: 'Assignments', items: _items(results[1], 'title', 'status')),
        RoleDashboardSection(title: 'CA submissions', items: _items(results[2], 'summary', 'status')),
        RoleDashboardSection(title: 'Marked scripts', items: _items(results[3], 'summary', 'status')),
      ],
    );
  }

  List<RoleDashboardItem> _items(dynamic data, String titleKey, String statusKey) {
    if (data is! List) return const [];
    return data.whereType<Map>().map((raw) {
      final json = raw.map((key, value) => MapEntry(key.toString(), value));
      final course = json['course'];
      final subtitle = course is Map
          ? [course['code']?.toString() ?? '', course['title']?.toString() ?? ''].where((part) => part.isNotEmpty).join(' • ')
          : json['email']?.toString() ?? json['message']?.toString() ?? json['academic_session']?.toString() ?? '';
      final fallbackTitle = [json['title'], json['first_name'], json['summary'], json['email']]
          .where((value) => value != null && value.toString().trim().isNotEmpty)
          .map((value) => value.toString())
          .firstOrNull;
      return RoleDashboardItem(
        title: json[titleKey]?.toString().trim().isNotEmpty == true ? json[titleKey].toString() : fallbackTitle ?? 'Record',
        subtitle: subtitle,
        status: json[statusKey]?.toString() ?? 'open',
      );
    }).toList();
  }

  RoleDashboardItem _analyticsItem(dynamic data) {
    if (data is Map) {
      final summary = data['summary'];
      if (summary is Map) {
        final courses = summary['assigned_courses']?.toString() ?? '0';
        final pending = summary['pending_marking']?.toString() ?? '0';
        final submissions = summary['submissions_received']?.toString() ?? '0';
        return RoleDashboardItem(
          title: '$courses courses • $submissions submissions',
          subtitle: 'Pending marking: $pending',
          status: 'live',
        );
      }
    }
    return const RoleDashboardItem(title: 'Analytics unavailable', subtitle: 'No live summary returned yet', status: 'pending');
  }

  void close() => _client.close();
}

class RoleDashboardData {
  const RoleDashboardData({required this.title, required this.sections});

  final String title;
  final List<RoleDashboardSection> sections;
}

class RoleDashboardSection {
  const RoleDashboardSection({required this.title, required this.items});

  final String title;
  final List<RoleDashboardItem> items;
}

class RoleDashboardItem {
  const RoleDashboardItem({required this.title, required this.subtitle, required this.status});

  final String title;
  final String subtitle;
  final String status;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
