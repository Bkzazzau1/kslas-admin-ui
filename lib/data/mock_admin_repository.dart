import 'package:flutter/material.dart';

import '../models/admin_role.dart';
import '../models/dashboard_models.dart';

class MockAdminRepository {
  const MockAdminRepository();

  List<AdminMetric> metricsFor(AdminRole role) {
    if (role == AdminRole.lecturer) {
      return const [
        AdminMetric(
          label: 'Assigned Courses',
          value: '6',
          detail: 'Assignments, notices, live classes, and result work',
          icon: Icons.menu_book_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Scripts to Mark',
          value: '142',
          detail: 'Theory, uploads, and practical submissions pending',
          icon: Icons.edit_note_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Question Drafts',
          value: '8',
          detail: '2 awaiting moderator review',
          icon: Icons.quiz_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Result Queries',
          value: '1',
          detail: 'Exam office needs lecturer response',
          icon: Icons.rule_folder_outlined,
          status: WorkStatus.urgent,
        ),
      ];
    }

    if (role == AdminRole.recordsDepartment) {
      return const [
        AdminMetric(
          label: 'Student Records',
          value: '18,420',
          detail: 'Profiles, programme, level, cohort and status records',
          icon: Icons.badge_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'CGPA Reviews',
          value: '74',
          detail: 'Transcript and result history checks pending',
          icon: Icons.workspace_premium_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Course Reg Exceptions',
          value: '31',
          detail: 'Carryover, repeat, overload and missing-result cases',
          icon: Icons.app_registration_outlined,
          status: WorkStatus.urgent,
        ),
        AdminMetric(
          label: 'Cohorts',
          value: '62',
          detail: 'Active programme, level, semester and mode groups',
          icon: Icons.groups_2_outlined,
          status: WorkStatus.complete,
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

    if (role == AdminRole.moderator) {
      return const [
        AdminMetric(
          label: 'Question Sets',
          value: '14',
          detail: 'Awaiting moderation comments',
          icon: Icons.rule_folder_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Rubrics',
          value: '9',
          detail: 'Essay and practical marking rubrics to verify',
          icon: Icons.fact_check_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Returned to Lecturer',
          value: '3',
          detail: 'Needs correction before exam officer approval',
          icon: Icons.undo_outlined,
          status: WorkStatus.urgent,
        ),
        AdminMetric(
          label: 'Approved',
          value: '28',
          detail: 'Ready for exam office packaging',
          icon: Icons.verified_outlined,
          status: WorkStatus.complete,
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
        detail: 'Notices, registration, results and exam actions',
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

  List<AdminTask> tasksFor(AdminRole role, {required String pageLabel}) {
    if (pageLabel == 'Notices') {
      return const [
        AdminTask(
          title: 'Publish exam office notice for 300 Level CSC cohort',
          ownerRole: AdminRole.examOfficer,
          due: 'Today, 1:00 PM',
          status: WorkStatus.warning,
          description: 'Notice must target programme, level, semester and cohort only.',
        ),
        AdminTask(
          title: 'Review lecturer course notice before publishing',
          ownerRole: AdminRole.lecturer,
          due: 'Today, 3:00 PM',
          status: WorkStatus.normal,
          description: 'Course notices must not appear to unrelated students.',
        ),
      ];
    }

    if (pageLabel == 'Course Registration') {
      return const [
        AdminTask(
          title: 'Approve carryover/repeat registration batch',
          ownerRole: AdminRole.recordsDepartment,
          due: 'Today, 2:30 PM',
          status: WorkStatus.urgent,
          description: 'Confirm failed, absent and missing-result courses before final approval.',
        ),
        AdminTask(
          title: 'Review overload waiver requests',
          ownerRole: AdminRole.levelAdviser,
          due: 'Tomorrow',
          status: WorkStatus.warning,
          description: 'Students above credit limit require adviser and records confirmation.',
        ),
      ];
    }

    if (pageLabel == 'Records') {
      return const [
        AdminTask(
          title: 'Verify CGPA recalculation queue',
          ownerRole: AdminRole.recordsDepartment,
          due: 'Today, 4:00 PM',
          status: WorkStatus.warning,
          description: 'Reconcile released results, repeated courses and transcript preview records.',
        ),
        AdminTask(
          title: 'Update cohort mappings for new intake',
          ownerRole: AdminRole.departmentAdmin,
          due: 'Friday',
          status: WorkStatus.normal,
          description: 'Programme, level, semester, mode and department cohorts must be current.',
        ),
      ];
    }

    return [
      AdminTask(
        title: role == AdminRole.lecturer
            ? 'Upload CSC 204 answer guide'
            : 'Approve CSC 204 question paper',
        ownerRole: role == AdminRole.superAdmin ? AdminRole.examOfficer : role,
        due: 'Today, 2:00 PM',
        status: WorkStatus.warning,
        description: 'Final moderation is waiting for an administrative sign-off.',
      ),
      const AdminTask(
        title: 'Resolve biometric mismatch list',
        ownerRole: AdminRole.invigilator,
        due: 'Today, 4:30 PM',
        status: WorkStatus.urgent,
        description: 'Three candidates need identity notes attached to their exam record.',
      ),
      const AdminTask(
        title: 'Publish level adviser clearance report',
        ownerRole: AdminRole.levelAdviser,
        due: 'Tomorrow',
        status: WorkStatus.normal,
        description: 'Registration exceptions and course carry-over lists are ready.',
      ),
      const AdminTask(
        title: 'Review departmental result summary',
        ownerRole: AdminRole.hod,
        due: 'Friday',
        status: WorkStatus.normal,
        description: 'Pass rate trends and missing CA scores have been generated.',
      ),
    ];
  }

  List<String> workflowsFor(String pageLabel) {
    switch (pageLabel) {
      case 'Notices':
        return const [
          'Lecturer notice publishing',
          'Exam office official notices',
          'Department/programme/level/cohort targeting',
          'Acknowledgement tracking',
          'Archive and audit logs',
        ];
      case 'Course Registration':
        return const [
          'Core course validation',
          'Elective selection review',
          'Carryover/repeat approval',
          'Overload waiver',
          'Registration lock/release',
        ];
      case 'Assignments':
        return const [
          'Lecturer grading',
          'Rubric review',
          'Late submission exceptions',
          'Peer review monitoring',
          'Academic integrity flags',
        ];
      case 'Exams':
        return const [
          'Question workflow',
          'Moderator review',
          'Exam officer approval',
          'Invigilation setup',
          'Incident escalation',
        ];
      case 'Results':
        return const [
          'Lecturer mark entry',
          'HoD review',
          'Exam office release',
          'Records reconciliation',
          'Student result publication',
        ];
      case 'Records':
        return const [
          'Student profile records',
          'Cohort management',
          'CGPA and transcript preview',
          'Completed courses',
          'Programme curriculum mapping',
        ];
      case 'Approvals':
        return const [
          'Question approval',
          'Notice approval',
          'Carryover approval',
          'Result approval',
          'Special registration approval',
        ];
      case 'People':
        return const [
          'Staff roles',
          'Lecturer allocation',
          'Invigilator assignment',
          'Department/faculty admins',
          'Access control',
        ];
      default:
        return const [
          'Operational metrics',
          'Role-based work queues',
          'Live alerts',
          'Audit-ready actions',
          'Cross-portal supervision',
        ];
    }
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
