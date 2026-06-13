import 'package:flutter/material.dart';

enum AdminRole {
  lecturer,
  invigilator,
  examOfficer,
  dlcDirector,
  hod,
  levelAdviser,
  superAdmin,
}

extension AdminRoleX on AdminRole {
  String get label {
    switch (this) {
      case AdminRole.lecturer:
        return 'Lecturer';
      case AdminRole.invigilator:
        return 'Invigilator';
      case AdminRole.examOfficer:
        return 'Exam Officer';
      case AdminRole.dlcDirector:
        return 'DLC Director';
      case AdminRole.hod:
        return 'HoD';
      case AdminRole.levelAdviser:
        return 'Level Adviser';
      case AdminRole.superAdmin:
        return 'All Admins';
    }
  }

  String get scope {
    switch (this) {
      case AdminRole.lecturer:
        return 'Course content, assessments, results review';
      case AdminRole.invigilator:
        return 'Exam rooms, attendance, incident reporting';
      case AdminRole.examOfficer:
        return 'Timetables, question readiness, result release';
      case AdminRole.dlcDirector:
        return 'Centre performance, approvals, policy oversight';
      case AdminRole.hod:
        return 'Department courses, staff, academic compliance';
      case AdminRole.levelAdviser:
        return 'Student cohorts, registration, progression';
      case AdminRole.superAdmin:
        return 'Institution-wide administrative operations';
    }
  }

  IconData get icon {
    switch (this) {
      case AdminRole.lecturer:
        return Icons.school_outlined;
      case AdminRole.invigilator:
        return Icons.verified_user_outlined;
      case AdminRole.examOfficer:
        return Icons.assignment_turned_in_outlined;
      case AdminRole.dlcDirector:
        return Icons.account_balance_outlined;
      case AdminRole.hod:
        return Icons.groups_2_outlined;
      case AdminRole.levelAdviser:
        return Icons.person_search_outlined;
      case AdminRole.superAdmin:
        return Icons.admin_panel_settings_outlined;
    }
  }
}
