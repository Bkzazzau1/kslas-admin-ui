import 'package:flutter/material.dart';

import '../core/auth/auth_session.dart';
import '../features/admin_shell/admin_operations_shell.dart';
import '../features/lecturer_assessments/widgets/lecturer_assessment_live_panel.dart';
import '../features/live_dashboard/widgets/live_dashboard_panel.dart';
import '../features/live_dashboard/widgets/notification_bell.dart';
import '../features/role_dashboard/widgets/role_dashboard_panel.dart';
import '../features/role_dashboard/widgets/workflow_forms_panel.dart';
import '../features/workflow/widgets/workflow_live_panel.dart';

class ConnectedAdminHome extends StatelessWidget {
  const ConnectedAdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AdminOperationsShell(),
        Positioned(
          right: 20,
          top: 20,
          child: _SessionCard(session: AuthSession.instance.session),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'backend-role-dashboard',
                onPressed: () => _openRoleDashboard(context),
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: const Text('My role'),
              ),
              const SizedBox(height: 10),
              FloatingActionButton.extended(
                heroTag: 'backend-smart-forms',
                onPressed: () => _openSmartForms(context),
                icon: const Icon(Icons.dynamic_form_outlined),
                label: const Text('Smart forms'),
              ),
              const SizedBox(height: 10),
              FloatingActionButton.extended(
                heroTag: 'backend-live-dashboard',
                onPressed: () => _openLiveDashboard(context),
                icon: const Icon(Icons.insights_outlined),
                label: const Text('Live dashboard'),
              ),
              const SizedBox(height: 10),
              FloatingActionButton.extended(
                heroTag: 'backend-workflow-connection',
                onPressed: () => _openWorkflowPanel(context),
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text('Live workflow'),
              ),
              const SizedBox(height: 10),
              FloatingActionButton.extended(
                heroTag: 'backend-assessment-connection',
                onPressed: () => _openLecturerAssessmentPanel(context),
                icon: const Icon(Icons.cloud_done_outlined),
                label: const Text('Live questions'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openRoleDashboard(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return const FractionallySizedBox(
          heightFactor: 0.9,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: RoleDashboardPanel(),
          ),
        );
      },
    );
  }

  void _openSmartForms(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return const FractionallySizedBox(
          heightFactor: 0.9,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: WorkflowFormsPanel(),
          ),
        );
      },
    );
  }

  void _openLiveDashboard(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return const FractionallySizedBox(
          heightFactor: 0.9,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: LiveDashboardPanel(),
          ),
        );
      },
    );
  }

  void _openWorkflowPanel(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return const FractionallySizedBox(
          heightFactor: 0.9,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: WorkflowLivePanel(),
          ),
        );
      },
    );
  }

  void _openLecturerAssessmentPanel(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return const FractionallySizedBox(
          heightFactor: 0.85,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: LecturerAssessmentLivePanel(),
          ),
        );
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final StaffSession? session;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final current = session;
    if (current == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const NotificationBell(),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: const Icon(Icons.person_outline, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(current.name, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
                Text(current.primaryRole.isEmpty ? 'Staff' : current.primaryRole, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Sign out',
              onPressed: AuthSession.instance.signOut,
              icon: const Icon(Icons.logout_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
