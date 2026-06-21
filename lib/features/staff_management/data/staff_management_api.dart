import '../../../core/network/api_client.dart';

class StaffManagementApi {
  StaffManagementApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<StaffItem>> fetchStaff() async {
    final data = await _client.get('/api/admin/staff');
    if (data is! List) return const [];
    return data.whereType<Map>().map((raw) {
      final json = raw.map((key, value) => MapEntry(key.toString(), value));
      return StaffItem.fromJson(json);
    }).toList();
  }

  Future<void> createStaff(Map<String, dynamic> payload) async {
    await _client.post('/api/admin/staff', body: payload);
  }

  Future<void> assignRole({required String staffId, required String role, String? departmentId, String? courseId}) async {
    final payload = <String, dynamic>{
      'staff_id': staffId,
      'role': role,
      'scope': courseId != null && courseId.isNotEmpty ? 'course' : 'department',
    };
    if (departmentId != null && departmentId.isNotEmpty) payload['department_id'] = departmentId;
    if (courseId != null && courseId.isNotEmpty) payload['course_id'] = courseId;
    await _client.post('/api/admin/staff-roles', body: payload);
  }

  void close() => _client.close();
}

class StaffItem {
  const StaffItem({
    required this.id,
    required this.staffNumber,
    required this.name,
    required this.email,
    required this.phone,
    required this.primaryRole,
    required this.departmentId,
    required this.active,
  });

  final String id;
  final String staffNumber;
  final String name;
  final String email;
  final String phone;
  final String primaryRole;
  final String departmentId;
  final bool active;

  factory StaffItem.fromJson(Map<String, dynamic> json) {
    final name = [
      json['title']?.toString() ?? '',
      json['first_name']?.toString() ?? '',
      json['last_name']?.toString() ?? '',
    ].where((part) => part.trim().isNotEmpty).join(' ');
    return StaffItem(
      id: json['id']?.toString() ?? '',
      staffNumber: json['staff_number']?.toString() ?? '',
      name: name.isEmpty ? 'Unnamed staff' : name,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      primaryRole: json['primary_role']?.toString() ?? 'lecturer',
      departmentId: json['department_id']?.toString() ?? '',
      active: json['is_active'] != false,
    );
  }
}

const staffRoleOptions = [
  'lecturer',
  'exam_officer',
  'moderator',
  'hod',
  'dlc_director',
  'level_adviser',
  'invigilator',
  'academic_records',
  'admin',
];
