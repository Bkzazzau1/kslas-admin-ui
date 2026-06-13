import 'package:flutter/material.dart';

import '../../data/mock_admin_repository.dart';
import '../../models/admin_role.dart';
import '../../models/dashboard_models.dart';
import 'workspaces/course_registration_approval_panel.dart';
import 'workspaces/lecturer_assignments_marking_panel.dart';
import 'workspaces/notice_publishing_panel.dart';
import 'workspaces/records_department_panel.dart';
import 'workspaces/results_approval_release_panel.dart';

const _operationsPages = [
  _OpsPage('Dashboard', Icons.dashboard_outlined),
  _OpsPage('Notices', Icons.campaign_outlined),
  _OpsPage('Course Registration', Icons.app_registration_outlined),
  _OpsPage('Assignments', Icons.assignment_ind_outlined),
  _OpsPage('Exams', Icons.assignment_outlined),
  _OpsPage('Results', Icons.workspace_premium_outlined),
  _OpsPage('Records', Icons.badge_outlined),
  _OpsPage('Approvals', Icons.fact_check_outlined),
  _OpsPage('People', Icons.groups_outlined),
];

class AdminOperationsShell extends StatefulWidget {
  const AdminOperationsShell({super.key});

  @override
  State<AdminOperationsShell> createState() => _AdminOperationsShellState();
}

class _AdminOperationsShellState extends State<AdminOperationsShell> {
  final MockAdminRepository _repository = const MockAdminRepository();
  AdminRole _selectedRole = AdminRole.recordsDepartment;
  int _selectedPage = 2;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 800;
    return Scaffold(
      appBar: compact
          ? AppBar(
              title: const Text('KSLAS Admin'),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_outlined),
                ),
              ],
            )
          : null,
      drawer: compact ? _RoleDrawer(selectedRole: _selectedRole, onRoleChanged: _changeRole) : null,
      body: Row(
        children: [
          if (!compact)
            _AdminSideBar(
              selectedPage: _selectedPage,
              selectedRole: _selectedRole,
              onPageChanged: (value) => setState(() => _selectedPage = value),
              onRoleChanged: _changeRole,
            ),
          Expanded(
            child: _AdminOperationsWorkspace(
              pageLabel: _operationsPages[_selectedPage].label,
              selectedRole: _selectedRole,
              repository: _repository,
              compact: compact,
            ),
          ),
        ],
      ),
      bottomNavigationBar: compact
          ? NavigationBar(
              selectedIndex: _selectedPage > 4 ? 4 : _selectedPage,
              onDestinationSelected: (value) => setState(() => _selectedPage = value),
              destinations: [
                for (final page in _operationsPages.take(5))
                  NavigationDestination(icon: Icon(page.icon), label: page.label),
              ],
            )
          : null,
    );
  }

  void _changeRole(AdminRole role) => setState(() => _selectedRole = role);
}

class _AdminSideBar extends StatelessWidget {
  const _AdminSideBar({
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
      width: 310,
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                child: const Icon(Icons.account_balance_outlined),
              ),
              title: const Text('KSLAS Admin', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('Non-student operations'),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _operationsPages.length; i++)
              _NavTile(
                label: _operationsPages[i].label,
                icon: _operationsPages[i].icon,
                selected: selectedPage == i,
                onTap: () => onPageChanged(i),
              ),
            const Divider(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Role view', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            for (final role in AdminRole.values)
              _RoleTile(role: role, selected: role == selectedRole, onTap: () => onRoleChanged(role)),
          ],
        ),
      ),
    );
  }
}

class _RoleDrawer extends StatelessWidget {
  const _RoleDrawer({required this.selectedRole, required this.onRoleChanged});

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
              subtitle: Text('Non-student operations'),
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

class _AdminOperationsWorkspace extends StatelessWidget {
  const _AdminOperationsWorkspace({
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
    final workflows = repository.workflowsFor(pageLabel);
    final tasks = repository.tasksFor(selectedRole, pageLabel: pageLabel);
    final width = MediaQuery.sizeOf(context).width;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(compact ? 16 : 28, compact ? 8 : 24, compact ? 16 : 28, 16),
            sliver: SliverToBoxAdapter(child: _Header(role: selectedRole, pageLabel: pageLabel)),
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
                mainAxisExtent: 150,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) => _MetricCard(metric: metrics[index]),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 18, compact ? 16 : 28, 0),
            sliver: SliverToBoxAdapter(child: _WorkflowPanel(workflows: workflows)),
          ),
          SliverPadding(
            padding: EdgeInsets.all(compact ? 16 : 28),
            sliver: SliverToBoxAdapter(
              child: _PrimaryPanel(pageLabel: pageLabel, tasks: tasks),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryPanel extends StatelessWidget {
  const _PrimaryPanel({required this.pageLabel, required this.tasks});

  final String pageLabel;
  final List<AdminTask> tasks;

  @override
  Widget build(BuildContext context) {
    if (pageLabel == 'Notices') {
      return const NoticePublishingPanel();
    }
    if (pageLabel == 'Course Registration') {
      return const CourseRegistrationApprovalPanel();
    }
    if (pageLabel == 'Assignments') {
      return const LecturerAssignmentsMarkingPanel();
    }
    if (pageLabel == 'Results') {
      return const ResultsApprovalReleasePanel();
    }
    if (pageLabel == 'Records') {
      return const RecordsDepartmentPanel();
    }
    return _TaskPanel(tasks: tasks);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.role, required this.pageLabel});

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
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pageLabel, style: text.labelLarge),
              const SizedBox(height: 4),
              Text('${role.label} workspace', style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(role.scope, style: text.bodyLarge),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_task_outlined),
          label: Text(pageLabel == 'Notices' ? 'Publish notice' : 'New action'),
        ),
      ],
    );
  }
}

class _WorkflowPanel extends StatelessWidget {
  const _WorkflowPanel({required this.workflows});

  final List<String> workflows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Workspace coverage', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final workflow in workflows)
                Chip(avatar: const Icon(Icons.check_circle_outline, size: 18), label: Text(workflow)),
            ],
          ),
        ]),
      ),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.14),
            foregroundColor: statusColor,
            child: Icon(metric.icon),
          ),
          const Spacer(),
          Text(metric.value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(metric.label, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(metric.detail, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }
}

class _TaskPanel extends StatelessWidget {
  const _TaskPanel({required this.tasks});

  final List<AdminTask> tasks;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Priority work queue', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (final task in tasks) _TaskTile(task: task),
        ]),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});

  final AdminTask task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = task.status.color(scheme);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(task.ownerRole.icon, color: statusColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task.title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(task.description),
            const SizedBox(height: 4),
            Text('${task.ownerRole.label} • ${task.due}', style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
        _StatusPill(status: task.status),
      ]),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final WorkStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color(Theme.of(context).colorScheme);
    return DecoratedBox(
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(status.label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({required this.role, required this.selected, required this.onTap});

  final AdminRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(role.icon),
      title: Text(role.label),
      subtitle: Text(role.scope, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        selected: selected,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon),
        title: Text(label),
        onTap: onTap,
      ),
    );
  }
}

class _OpsPage {
  const _OpsPage(this.label, this.icon);

  final String label;
  final IconData icon;
}
