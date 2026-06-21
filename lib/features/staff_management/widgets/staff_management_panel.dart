import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../data/staff_management_api.dart';

class StaffManagementPanel extends StatefulWidget {
  const StaffManagementPanel({super.key});

  @override
  State<StaffManagementPanel> createState() => _StaffManagementPanelState();
}

class _StaffManagementPanelState extends State<StaffManagementPanel> {
  late final StaffManagementApi _api;
  late Future<List<StaffItem>> _future;
  late Future<StaffReferenceData> _referencesFuture;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _api = StaffManagementApi();
    _future = _api.fetchStaff();
    _referencesFuture = _api.fetchReferences();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _api.fetchStaff();
      _referencesFuture = _api.fetchReferences();
    });
  }

  Future<StaffReferenceData> _safeReferences() async {
    try {
      return await _referencesFuture;
    } catch (_) {
      return const StaffReferenceData(departments: [], courses: []);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved successfully')));
      _reload();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openCreateStaff() async {
    final refs = await _safeReferences();
    if (!mounted) return;
    final payload = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => _CreateStaffDialog(references: refs));
    if (payload == null) return;
    await _run(() => _api.createStaff(payload));
  }

  Future<void> _openAssignRole(StaffItem staff) async {
    final refs = await _safeReferences();
    if (!mounted) return;
    final payload = await showDialog<Map<String, String>>(context: context, builder: (_) => _AssignRoleDialog(staff: staff, references: refs));
    if (payload == null) return;
    await _run(() => _api.assignRole(staffId: staff.id, role: payload['role'] ?? 'lecturer', departmentId: payload['department_id'], courseId: payload['course_id']));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.badge_outlined, color: scheme.primary),
                    const SizedBox(width: 10),
                    Text('Staff management', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(onPressed: _busy ? null : _reload, icon: const Icon(Icons.refresh_outlined), label: const Text('Refresh')),
                    FilledButton.icon(onPressed: _busy ? null : _openCreateStaff, icon: const Icon(Icons.person_add_alt_outlined), label: const Text('Create staff')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<StaffReferenceData>(
              future: _referencesFuture,
              builder: (context, snapshot) {
                final refs = snapshot.data;
                final text = refs == null
                    ? 'Loading department and course options...'
                    : '${refs.departments.length} departments and ${refs.courses.length} courses loaded for role assignment.';
                return Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant));
              },
            ),
            const SizedBox(height: 18),
            FutureBuilder<List<StaffItem>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return _StaffError(message: snapshot.error.toString(), onRetry: _reload);
                }
                final staff = snapshot.data ?? const [];
                if (staff.isEmpty) return const _EmptyStaffState();
                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 720) {
                      return Column(children: [for (final item in staff) _StaffCard(item: item, onAssignRole: () => _openAssignRole(item))]);
                    }
                    return _StaffTable(staff: staff, onAssignRole: _openAssignRole);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffTable extends StatelessWidget {
  const _StaffTable({required this.staff, required this.onAssignRole});

  final List<StaffItem> staff;
  final ValueChanged<StaffItem> onAssignRole;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Staff')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Primary role')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Action')),
      ],
      rows: [
        for (final item in staff)
          DataRow(cells: [
            DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800)), Text(item.staffNumber)])),
            DataCell(Text(item.email)),
            DataCell(Chip(label: Text(item.primaryRole), visualDensity: VisualDensity.compact)),
            DataCell(Text(item.active ? 'Active' : 'Inactive')),
            DataCell(TextButton.icon(onPressed: () => onAssignRole(item), icon: const Icon(Icons.admin_panel_settings_outlined), label: const Text('Assign role'))),
          ]),
      ],
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.item, required this.onAssignRole});

  final StaffItem item;
  final VoidCallback onAssignRole;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('${item.email}\n${item.staffNumber}'),
        isThreeLine: true,
        trailing: TextButton(onPressed: onAssignRole, child: const Text('Role')),
      ),
    );
  }
}

class _CreateStaffDialog extends StatefulWidget {
  const _CreateStaffDialog({required this.references});

  final StaffReferenceData references;

  @override
  State<_CreateStaffDialog> createState() => _CreateStaffDialogState();
}

class _CreateStaffDialogState extends State<_CreateStaffDialog> {
  final _staffNumber = TextEditingController();
  final _title = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _fallbackDepartmentId = TextEditingController();
  String _role = 'lecturer';
  String? _departmentId;

  @override
  void dispose() {
    _staffNumber.dispose();
    _title.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _fallbackDepartmentId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create staff account'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _staffNumber, decoration: const InputDecoration(labelText: 'Staff number')),
              const SizedBox(height: 10),
              Row(children: [Expanded(child: TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title'))), const SizedBox(width: 10), Expanded(child: TextField(controller: _firstName, decoration: const InputDecoration(labelText: 'First name')))]),
              const SizedBox(height: 10),
              TextField(controller: _lastName, decoration: const InputDecoration(labelText: 'Last name')),
              const SizedBox(height: 10),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email address')),
              const SizedBox(height: 10),
              TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
              const SizedBox(height: 10),
              _ReferencePicker(
                label: 'Department',
                options: widget.references.departments,
                value: _departmentId,
                fallbackController: _fallbackDepartmentId,
                onChanged: (value) => setState(() => _departmentId = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Primary role'),
                items: [for (final role in staffRoleOptions) DropdownMenuItem(value: role, child: Text(role))],
                onChanged: (value) => setState(() => _role = value ?? 'lecturer'),
              ),
              const SizedBox(height: 10),
              TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Temporary password')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop(_payload()), child: const Text('Create')),
      ],
    );
  }

  Map<String, dynamic> _payload() {
    final payload = <String, dynamic>{
      'staff_number': _staffNumber.text.trim(),
      'title': _title.text.trim(),
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'primary_role': _role,
      'password': _password.text,
      'is_active': true,
    };
    final departmentId = _departmentId ?? _fallbackDepartmentId.text.trim();
    if (departmentId.isNotEmpty) payload['department_id'] = departmentId;
    return payload;
  }
}

class _AssignRoleDialog extends StatefulWidget {
  const _AssignRoleDialog({required this.staff, required this.references});

  final StaffItem staff;
  final StaffReferenceData references;

  @override
  State<_AssignRoleDialog> createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends State<_AssignRoleDialog> {
  String _role = 'lecturer';
  String? _departmentId;
  String? _courseId;
  final _fallbackDepartmentId = TextEditingController();
  final _fallbackCourseId = TextEditingController();

  @override
  void dispose() {
    _fallbackDepartmentId.dispose();
    _fallbackCourseId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign role to ${widget.staff.name}'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: [for (final role in staffRoleOptions) DropdownMenuItem(value: role, child: Text(role))],
                onChanged: (value) => setState(() => _role = value ?? 'lecturer'),
              ),
              const SizedBox(height: 10),
              _ReferencePicker(
                label: 'Department scope',
                options: widget.references.departments,
                value: _departmentId,
                fallbackController: _fallbackDepartmentId,
                onChanged: (value) => setState(() => _departmentId = value),
              ),
              const SizedBox(height: 10),
              _ReferencePicker(
                label: 'Course scope',
                options: widget.references.courses,
                value: _courseId,
                fallbackController: _fallbackCourseId,
                onChanged: (value) => setState(() => _courseId = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop({'role': _role, 'department_id': _departmentId ?? _fallbackDepartmentId.text.trim(), 'course_id': _courseId ?? _fallbackCourseId.text.trim()}), child: const Text('Assign')),
      ],
    );
  }
}

class _ReferencePicker extends StatelessWidget {
  const _ReferencePicker({required this.label, required this.options, required this.value, required this.fallbackController, required this.onChanged});

  final String label;
  final List<ReferenceOption> options;
  final String? value;
  final TextEditingController fallbackController;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return TextField(controller: fallbackController, decoration: InputDecoration(labelText: '$label ID'));
    }
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: [for (final option in options) DropdownMenuItem(value: option.id, child: Text(option.label, overflow: TextOverflow.ellipsis))],
      onChanged: onChanged,
    );
  }
}

class _EmptyStaffState extends StatelessWidget {
  const _EmptyStaffState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
      child: const Text('No staff records returned yet.'),
    );
  }
}

class _StaffError extends StatelessWidget {
  const _StaffError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Theme.of(context).colorScheme.errorContainer),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Staff management issue', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(message),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_outlined), label: const Text('Try again')),
      ]),
    );
  }
}
