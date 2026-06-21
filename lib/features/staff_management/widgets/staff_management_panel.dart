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
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _api = StaffManagementApi();
    _future = _api.fetchStaff();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  void _reload() => setState(() => _future = _api.fetchStaff());

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
    final payload = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => const _CreateStaffDialog());
    if (payload == null) return;
    await _run(() => _api.createStaff(payload));
  }

  Future<void> _openAssignRole(StaffItem staff) async {
    final payload = await showDialog<Map<String, String>>(context: context, builder: (_) => _AssignRoleDialog(staff: staff));
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
            Text('Create staff accounts and assign additional roles. Passwords are sent to the backend and stored as hashes.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
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
                if (staff.isEmpty) {
                  return const _EmptyStaffState();
                }
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
  const _CreateStaffDialog();

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
  final _departmentId = TextEditingController();
  String _role = 'lecturer';

  @override
  void dispose() {
    _staffNumber.dispose();
    _title.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _departmentId.dispose();
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
              TextField(controller: _departmentId, decoration: const InputDecoration(labelText: 'Department ID optional')),
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
    if (_departmentId.text.trim().isNotEmpty) payload['department_id'] = _departmentId.text.trim();
    return payload;
  }
}

class _AssignRoleDialog extends StatefulWidget {
  const _AssignRoleDialog({required this.staff});

  final StaffItem staff;

  @override
  State<_AssignRoleDialog> createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends State<_AssignRoleDialog> {
  String _role = 'lecturer';
  final _departmentId = TextEditingController();
  final _courseId = TextEditingController();

  @override
  void dispose() {
    _departmentId.dispose();
    _courseId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign role to ${widget.staff.name}'),
      content: SizedBox(
        width: 520,
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
            TextField(controller: _departmentId, decoration: const InputDecoration(labelText: 'Department ID optional')),
            const SizedBox(height: 10),
            TextField(controller: _courseId, decoration: const InputDecoration(labelText: 'Course ID optional')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop({'role': _role, 'department_id': _departmentId.text.trim(), 'course_id': _courseId.text.trim()}), child: const Text('Assign')),
      ],
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
