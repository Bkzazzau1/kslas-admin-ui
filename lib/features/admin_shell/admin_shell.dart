import 'package:flutter/material.dart';

import '../../data/mock_admin_repository.dart';
import '../../models/admin_role.dart';
import '../../models/dashboard_models.dart';

const _adminPages = [
  _PageItem('Dashboard', Icons.dashboard_outlined),
  _PageItem('Exams', Icons.assignment_outlined),
  _PageItem('Approvals', Icons.fact_check_outlined),
  _PageItem('People', Icons.groups_outlined),
];

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final MockAdminRepository _repository = const MockAdminRepository();
  AdminRole _selectedRole = AdminRole.superAdmin;
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    return Scaffold(
      appBar: compact
          ? AppBar(
              title: const Text('KSLAS Admin'),
              actions: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_outlined),
                ),
              ],
            )
          : null,
      drawer: compact
          ? _AdminDrawer(
              selectedRole: _selectedRole,
              onRoleChanged: _changeRole,
            )
          : null,
      bottomNavigationBar: compact
          ? NavigationBar(
              selectedIndex: _selectedPage,
              onDestinationSelected: (value) {
                setState(() => _selectedPage = value);
              },
              destinations: [
                for (final page in _adminPages)
                  NavigationDestination(
                    icon: Icon(page.icon),
                    label: page.label,
                  ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (!compact)
            _SideRail(
              selectedPage: _selectedPage,
              selectedRole: _selectedRole,
              onPageChanged: (value) {
                setState(() => _selectedPage = value);
              },
              onRoleChanged: _changeRole,
            ),
          Expanded(
            child: _AdminWorkspace(
              pageLabel: _adminPages[_selectedPage].label,
              selectedRole: _selectedRole,
              repository: _repository,
              compact: compact,
            ),
          ),
        ],
      ),
    );
  }

  void _changeRole(AdminRole role) {
    setState(() => _selectedRole = role);
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.selectedPage,
    required this.selectedRole,
    required this.onPageChanged,
    required this.onRoleChanged,
  });

  final int selectedPage;
  final AdminRole selectedRole;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<AdminRole> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 292,
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    child: const Icon(Icons.account_balance_outlined),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'KSLAS Admin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (var index = 0; index < _adminPages.length; index++)
              _NavTile(
                label: _adminPages[index].label,
                icon: _adminPages[index].icon,
                selected: selectedPage == index,
                onTap: () => onPageChanged(index),
              ),
            const Divider(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Role view',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final role in AdminRole.values)
                    _RoleTile(
                      role: role,
                      selected: role == selectedRole,
                      onTap: () => onRoleChanged(role),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer({required this.selectedRole, required this.onRoleChanged});

  final AdminRole selectedRole;
  final ValueChanged<AdminRole> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const ListTile(
              leading: Icon(Icons.account_balance_outlined),
              title: Text('KSLAS Admin'),
              subtitle: Text('Operational console'),
            ),
            const Divider(),
            for (final role in AdminRole.values)
              _RoleTile(
                role: role,
                selected: role == selectedRole,
                onTap: () {
                  Navigator.pop(context);
                  onRoleChanged(role);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _AdminWorkspace extends StatelessWidget {
  const _AdminWorkspace({
    required this.pageLabel,
    required this.selectedRole,
    required this.repository,
    required this.compact,
  });

  final String pageLabel;
  final AdminRole selectedRole;
  final MockAdminRepository repository;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final metrics = repository.metricsFor(selectedRole);
    final tasks = repository.tasksFor(selectedRole);
    final rooms = repository.examRooms();
    final alerts = repository.alerts();
    final width = MediaQuery.sizeOf(context).width;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 28,
              compact ? 8 : 24,
              compact ? 16 : 28,
              16,
            ),
            sliver: SliverToBoxAdapter(
              child: _WorkspaceHeader(role: selectedRole, pageLabel: pageLabel),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 28),
            sliver: SliverGrid.builder(
              itemCount: metrics.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: compact
                    ? 1
                    : width > 1180
                    ? 4
                    : 2,
                mainAxisExtent: 156,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return _MetricCard(metric: metrics[index]);
              },
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(compact ? 16 : 28),
            sliver: SliverToBoxAdapter(
              child: compact
                  ? Column(
                      children: [
                        _TaskPanel(tasks: tasks),
                        const SizedBox(height: 16),
                        _ExamPanel(rooms: rooms),
                        const SizedBox(height: 16),
                        _AlertPanel(alerts: alerts),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _TaskPanel(tasks: tasks)),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              _ExamPanel(rooms: rooms),
                              const SizedBox(height: 16),
                              _AlertPanel(alerts: alerts),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({required this.role, required this.pageLabel});

  final AdminRole role;
  final String pageLabel;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pageLabel, style: text.labelLarge),
              const SizedBox(height: 4),
              Text(
                '${role.label} workspace',
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(role.scope, style: text.bodyLarge),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_task_outlined),
          label: const Text('New action'),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final AdminMetric metric;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = metric.status.color(scheme);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(metric.icon, color: statusColor),
                const Spacer(),
                _StatusBadge(status: metric.status),
              ],
            ),
            const Spacer(),
            Text(
              metric.value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(metric.label, style: Theme.of(context).textTheme.titleSmall),
            Text(metric.detail, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _TaskPanel extends StatelessWidget {
  const _TaskPanel({required this.tasks});

  final List<AdminTask> tasks;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Priority work',
      icon: Icons.checklist_outlined,
      child: Column(children: [for (final task in tasks) _TaskRow(task: task)]),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});

  final AdminTask task;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 18, child: Icon(task.ownerRole.icon, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    _StatusBadge(status: task.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(task.description),
                const SizedBox(height: 4),
                Text(
                  '${task.ownerRole.label} - ${task.due}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamPanel extends StatelessWidget {
  const _ExamPanel({required this.rooms});

  final List<ExamRoom> rooms;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Exam rooms',
      icon: Icons.meeting_room_outlined,
      child: Column(
        children: [
          for (final room in rooms)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Text(room.courseCode.substring(0, 3)),
              ),
              title: Text(room.courseCode),
              subtitle: Text(
                '${room.room} - ${room.time}\n'
                '${room.invigilator} - ${room.candidateCount} candidates',
              ),
              isThreeLine: true,
              trailing: _StatusDot(status: room.status),
            ),
        ],
      ),
    );
  }
}

class _AlertPanel extends StatelessWidget {
  const _AlertPanel({required this.alerts});

  final List<AdminAlert> alerts;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Live alerts',
      icon: Icons.notifications_active_outlined,
      child: Column(
        children: [
          for (final alert in alerts)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _StatusDot(status: alert.status),
              title: Text(alert.title),
              subtitle: Text(alert.message),
              trailing: Text(
                alert.time,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        selected: selected,
        selectedTileColor: scheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(icon),
        title: Text(label),
        onTap: onTap,
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final AdminRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: Icon(role.icon),
      title: Text(role.label),
      subtitle: Text(role.scope, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final WorkStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = status.color(scheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          status.label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final WorkStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color(Theme.of(context).colorScheme);

    return Tooltip(
      message: status.label,
      child: Icon(Icons.circle, color: color, size: 13),
    );
  }
}

class _PageItem {
  const _PageItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
