import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../lecturer_assessments/widgets/lecturer_assessment_live_panel.dart';
import '../live_dashboard/widgets/live_dashboard_panel.dart';
import '../live_dashboard/widgets/notification_bell.dart';
import '../role_dashboard/widgets/role_dashboard_panel.dart';
import '../role_dashboard/widgets/workflow_forms_panel.dart';
import '../staff_management/widgets/staff_management_panel.dart';
import '../workflow/widgets/workflow_live_panel.dart';
import 'admin_operations_shell.dart';

class RoleLockedAdminShell extends StatefulWidget {
  const RoleLockedAdminShell({super.key});

  @override
  State<RoleLockedAdminShell> createState() => _RoleLockedAdminShellState();
}

class _RoleLockedAdminShellState extends State<RoleLockedAdminShell> {
  int _selectedIndex = 0;

  StaffSession? get _session => AuthSession.instance.session;

  String get _role {
    final session = _session;
    if (session == null) return 'lecturer';
    if (session.primaryRole.isNotEmpty) return session.primaryRole.toLowerCase();
    if (session.roles.isNotEmpty) return session.roles.first.toLowerCase();
    return 'lecturer';
  }

  List<_LockedPage> get _pages => _pagesForRole(_role);

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 860;
    final pages = _pages;
    final safeIndex = _selectedIndex >= pages.length ? 0 : _selectedIndex;
    final page = pages[safeIndex];

    return Scaffold(
      appBar: compact
          ? AppBar(
              title: Text(_titleForRole(_role)),
              actions: const [NotificationBell(), SizedBox(width: 8)],
            )
          : null,
      drawer: compact ? _LockedDrawer(pages: pages, selectedIndex: safeIndex, onChanged: _selectPage) : null,
      body: Row(
        children: [
          if (!compact)
            _LockedSideBar(
              session: _session,
              role: _role,
              pages: pages,
              selectedIndex: safeIndex,
              onChanged: _selectPage,
            ),
          Expanded(child: page.builder(context)),
        ],
      ),
      bottomNavigationBar: compact
          ? NavigationBar(
              selectedIndex: safeIndex > 4 ? 4 : safeIndex,
              onDestinationSelected: _selectPage,
              destinations: [
                for (final item in pages.take(5)) NavigationDestination(icon: Icon(item.icon), label: item.label),
              ],
            )
          : null,
    );
  }

  void _selectPage(int value) {
    setState(() => _selectedIndex = value);
  }
}

List<_LockedPage> _pagesForRole(String role) {
  switch (role) {
    case 'admin':
    case 'super_admin':
    case 'superadmin':
    case 'dlc_director':
      return _adminPages;
    case 'hod':
      return _hodPages;
    case 'exam_officer':
      return _examOfficerPages;
    case 'moderator':
      return _moderatorPages;
    case 'lecturer':
      return _lecturerPages;
    case 'academic_records':
    case 'records_department':
      return _recordsPages;
    case 'level_adviser':
      return _levelAdviserPages;
    case 'invigilator':
      return _invigilatorPages;
    default:
      return _lecturerPages;
  }
}

final _adminPages = [
  _LockedPage('Full console', Icons.dashboard_customize_outlined, (_) => const AdminOperationsShell()),
  _LockedPage('Staff management', Icons.badge_outlined, (_) => const _PanelHost(child: StaffManagementPanel())),
  _LockedPage('My role', Icons.admin_panel_settings_outlined, (_) => const _PanelHost(child: RoleDashboardPanel())),
  _LockedPage('Smart forms', Icons.dynamic_form_outlined, (_) => const _PanelHost(child: WorkflowFormsPanel())),
  _LockedPage('Live dashboard', Icons.insights_outlined, (_) => const _PanelHost(child: LiveDashboardPanel())),
  _LockedPage('Live workflow', Icons.account_tree_outlined, (_) => const _PanelHost(child: WorkflowLivePanel())),
  _LockedPage('Live questions', Icons.cloud_done_outlined, (_) => const _PanelHost(child: LecturerAssessmentLivePanel())),
];

final _hodPages = [
  _LockedPage('Staff management', Icons.badge_outlined, (_) => const _PanelHost(child: StaffManagementPanel())),
  _LockedPage('My role', Icons.account_tree_outlined, (_) => const _PanelHost(child: RoleDashboardPanel())),
  _LockedPage('Live dashboard', Icons.insights_outlined, (_) => const _PanelHost(child: LiveDashboardPanel())),
  _LockedPage('Live workflow', Icons.account_tree_outlined, (_) => const _PanelHost(child: WorkflowLivePanel())),
  _LockedPage('Live questions', Icons.cloud_done_outlined, (_) => const _PanelHost(child: LecturerAssessmentLivePanel())),
];

final _lecturerPages = [
  _LockedPage('My role', Icons.school_outlined, (_) => const _PanelHost(child: RoleDashboardPanel())),
  _LockedPage('Smart forms', Icons.dynamic_form_outlined, (_) => const _PanelHost(child: WorkflowFormsPanel())),
  _LockedPage('Live workflow', Icons.account_tree_outlined, (_) => const _PanelHost(child: WorkflowLivePanel())),
  _LockedPage('Live questions', Icons.cloud_done_outlined, (_) => const _PanelHost(child: LecturerAssessmentLivePanel())),
  _LockedPage('Live dashboard', Icons.insights_outlined, (_) => const _PanelHost(child: LiveDashboardPanel())),
];

final _examOfficerPages = [
  _LockedPage('My role', Icons.assignment_turned_in_outlined, (_) => const _PanelHost(child: RoleDashboardPanel())),
  _LockedPage('Live workflow', Icons.account_tree_outlined, (_) => const _PanelHost(child: WorkflowLivePanel())),
  _LockedPage('Live dashboard', Icons.insights_outlined, (_) => const _PanelHost(child: LiveDashboardPanel())),
];

final _moderatorPages = [
  _LockedPage('My role', Icons.rule_folder_outlined, (_) => const _PanelHost(child: RoleDashboardPanel())),
  _LockedPage('Live dashboard', Icons.insights_outlined, (_) => const _PanelHost(child: LiveDashboardPanel())),
];

final _recordsPages = [
  _LockedPage('My role', Icons.badge_outlined, (_) => const _PanelHost(child: RoleDashboardPanel())),
  _LockedPage('Live dashboard', Icons.insights_outlined, (_) => const _PanelHost(child: LiveDashboardPanel())),
];

final _levelAdviserPages = [
  _LockedPage('My role', Icons.person_search_outlined, (_) => const _PanelHost(child: RoleDashboardPanel())),
  _LockedPage('Live dashboard', Icons.insights_outlined, (_) => const _PanelHost(child: LiveDashboardPanel())),
];

final _invigilatorPages = [
  _LockedPage('My role', Icons.verified_user_outlined, (_) => const _PanelHost(child: RoleDashboardPanel())),
  _LockedPage('Live dashboard', Icons.insights_outlined, (_) => const _PanelHost(child: LiveDashboardPanel())),
];

String _titleForRole(String role) {
  switch (role) {
    case 'admin':
    case 'super_admin':
    case 'superadmin':
      return 'K-SLAS Admin';
    case 'dlc_director':
      return 'DLC Director';
    case 'hod':
      return 'HoD Workspace';
    case 'exam_officer':
      return 'Exam Officer';
    case 'moderator':
      return 'Moderator';
    case 'lecturer':
      return 'Lecturer Workspace';
    case 'academic_records':
    case 'records_department':
      return 'Academic Records';
    case 'level_adviser':
      return 'Level Adviser';
    case 'invigilator':
      return 'Invigilator';
    default:
      return 'Staff Workspace';
  }
}

String _subtitleForRole(String role) {
  switch (role) {
    case 'admin':
    case 'super_admin':
    case 'superadmin':
    case 'dlc_director':
      return 'Institution-wide administration and monitoring';
    case 'hod':
      return 'Department academic supervision and approvals';
    case 'exam_officer':
      return 'Departmental examination workflow';
    case 'moderator':
      return 'Question review and quality checks';
    case 'lecturer':
      return 'Assigned course delivery and submissions';
    case 'academic_records':
    case 'records_department':
      return 'Official academic records workspace';
    case 'level_adviser':
      return 'Assigned level student monitoring';
    case 'invigilator':
      return 'Exam attendance and monitoring support';
    default:
      return 'Role-based staff workspace';
  }
}

class _LockedSideBar extends StatelessWidget {
  const _LockedSideBar({required this.session, required this.role, required this.pages, required this.selectedIndex, required this.onChanged});

  final StaffSession? session;
  final String role;
  final List<_LockedPage> pages;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

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
                child: Icon(pages.first.icon),
              ),
              title: Text(_titleForRole(role), style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(_subtitleForRole(role)),
            ),
            const SizedBox(height: 10),
            _SignedInCard(session: session),
            const SizedBox(height: 16),
            for (var index = 0; index < pages.length; index++)
              ListTile(
                selected: selectedIndex == index,
                selectedTileColor: scheme.primaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: Icon(pages[index].icon),
                title: Text(pages[index].label),
                onTap: () => onChanged(index),
              ),
          ],
        ),
      ),
    );
  }
}

class _SignedInCard extends StatelessWidget {
  const _SignedInCard({required this.session});

  final StaffSession? session;

  @override
  Widget build(BuildContext context) {
    final current = session;
    if (current == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          const NotificationBell(),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(current.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(current.primaryRole.isEmpty ? 'Staff' : current.primaryRole, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(tooltip: 'Sign out', onPressed: AuthSession.instance.signOut, icon: const Icon(Icons.logout_outlined)),
        ],
      ),
    );
  }
}

class _LockedDrawer extends StatelessWidget {
  const _LockedDrawer({required this.pages, required this.selectedIndex, required this.onChanged});

  final List<_LockedPage> pages;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('My workspace', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (var index = 0; index < pages.length; index++)
              ListTile(
                selected: selectedIndex == index,
                leading: Icon(pages[index].icon),
                title: Text(pages[index].label),
                onTap: () {
                  onChanged(index);
                  Navigator.of(context).maybePop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PanelHost extends StatelessWidget {
  const _PanelHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: child,
      ),
    );
  }
}

class _LockedPage {
  const _LockedPage(this.label, this.icon, this.builder);

  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}
