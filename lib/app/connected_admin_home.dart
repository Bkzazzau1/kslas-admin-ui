import 'package:flutter/material.dart';

import '../features/admin_shell/admin_operations_shell.dart';
import '../features/lecturer_assessments/widgets/lecturer_assessment_live_panel.dart';

class ConnectedAdminHome extends StatelessWidget {
  const ConnectedAdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AdminOperationsShell(),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            heroTag: 'backend-assessment-connection',
            onPressed: () => _openLecturerAssessmentPanel(context),
            icon: const Icon(Icons.cloud_done_outlined),
            label: const Text('Live backend'),
          ),
        ),
      ],
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
