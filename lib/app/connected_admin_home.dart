import 'package:flutter/material.dart';

import '../core/auth/auth_session.dart';
import '../features/admin_shell/admin_operations_shell.dart';
import '../features/lecturer_assessments/widgets/lecturer_assessment_live_panel.dart';
import '../features/live_dashboard/widgets/live_dashboard_panel.dart';

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
                heroTag: 'backend-live-dashboard',
                onPressed: () => _openLiveDashboard(context),
                icon: const Icon(Icons.insights_outlined),
                label: const Text('Live dashboard'),
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
