import 'package:flutter/material.dart';

import '../models/admin_role.dart';
import '../models/dashboard_models.dart';

class MockAdminRepository {
  const MockAdminRepository();

  List<AdminMetric> metricsFor(AdminRole role) {
    if (role == AdminRole.lecturer) {
      return const [
        AdminMetric(
          label: 'Courses',
          value: '6',
          detail: '4 have active assessments',
          icon: Icons.menu_book_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Scripts to Mark',
          value: '142',
          detail: 'Theory and uploads pending',
          icon: Icons.edit_note_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Question Drafts',
          value: '8',
          detail: '2 awaiting moderation',
          icon: Icons.quiz_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Result Issues',
          value: '1',
          detail: 'Needs lecturer response',
          icon: Icons.rule_folder_outlined,
          status: WorkStatus.urgent,
        ),
      ];
    }

    if (role == AdminRole.invigilator) {
      return const [
        AdminMetric(
          label: 'Assigned Rooms',
          value: '5',
          detail: '2 currently in progress',
          icon: Icons.meeting_room_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Check-ins',
          value: '487',
          detail: '96% verified',
          icon: Icons.how_to_reg_outlined,
          status: WorkStatus.complete,
        ),
        AdminMetric(
          label: 'Open Incidents',
          value: '3',
          detail: 'Needs closing notes',
          icon: Icons.gpp_maybe_outlined,
          status: WorkStatus.urgent,
        ),
        AdminMetric(
          label: 'Device Flags',
          value: '12',
          detail: 'Review before submission',
          icon: Icons.devices_other_outlined,
          status: WorkStatus.warning,
        ),
      ];
    }

    return const [
      AdminMetric(
        label: 'Active Exams',
        value: '18',
        detail: '4 running now',
        icon: Icons.event_available_outlined,
        status: WorkStatus.normal,
      ),
      AdminMetric(
        label: 'Pending Approvals',
        value: '27',
        detail: '9 require action today',
        icon: Icons.fact_check_outlined,
        status: WorkStatus.warning,
      ),
      AdminMetric(
        label: 'Incident Reports',
        value: '3',
        detail: '1 escalated',
        icon: Icons.report_problem_outlined,
        status: WorkStatus.urgent,
      ),
      AdminMetric(
        label: 'Released Results',
        value: '64%',
        detail: '12 courses published',
        icon: Icons.workspace_premium_outlined,
        status: WorkStatus.complete,
      ),
    ];
  }

  List<AdminTask> tasksFor(AdminRole role) {
    return [
      AdminTask(
        title: role == AdminRole.lecturer
            ? 'Upload CSC 204 answer guide'
            : 'Approve CSC 204 question paper',
        ownerRole: role == AdminRole.superAdmin ? AdminRole.examOfficer : role,
        due: 'Today, 2:00 PM',
        status: WorkStatus.warning,
        description:
            'Final moderation is waiting for an administrative sign-off.',
      ),
      const AdminTask(
        title: 'Resolve biometric mismatch list',
        ownerRole: AdminRole.invigilator,
        due: 'Today, 4:30 PM',
        status: WorkStatus.urgent,
        description:
            'Three candidates need identity notes attached to their exam record.',
      ),
      const AdminTask(
        title: 'Publish level adviser clearance report',
        ownerRole: AdminRole.levelAdviser,
        due: 'Tomorrow',
        status: WorkStatus.normal,
        description:
            'Registration exceptions and course carry-over lists are ready.',
      ),
      const AdminTask(
        title: 'Review departmental result summary',
        ownerRole: AdminRole.hod,
        due: 'Friday',
        status: WorkStatus.normal,
        description:
            'Pass rate trends and missing CA scores have been generated.',
      ),
    ];
  }

  List<ExamRoom> examRooms() {
    return const [
      ExamRoom(
        courseCode: 'CSC 204',
        room: 'ICT Lab A',
        time: '09:00 - 11:00',
        invigilator: 'Dr. A. Musa',
        candidateCount: 126,
        status: WorkStatus.normal,
      ),
      ExamRoom(
        courseCode: 'GST 102',
        room: 'Hall 2',
        time: '11:30 - 13:00',
        invigilator: 'Mrs. E. John',
        candidateCount: 214,
        status: WorkStatus.warning,
      ),
      ExamRoom(
        courseCode: 'MTH 112',
        room: 'CBT Centre 1',
        time: '14:00 - 16:00',
        invigilator: 'Mr. O. Bala',
        candidateCount: 188,
        status: WorkStatus.complete,
      ),
    ];
  }

  List<AdminAlert> alerts() {
    return const [
      AdminAlert(
        title: 'Candidate verification delay',
        message: 'Hall 2 has 14 candidates waiting for manual confirmation.',
        status: WorkStatus.warning,
        time: '8 min ago',
      ),
      AdminAlert(
        title: 'Remote proctoring escalation',
        message: 'Two sessions crossed the suspicious activity threshold.',
        status: WorkStatus.urgent,
        time: '19 min ago',
      ),
      AdminAlert(
        title: 'Results batch completed',
        message: 'CSC 312 scores are ready for HoD review.',
        status: WorkStatus.complete,
        time: '42 min ago',
      ),
    ];
  }
}
