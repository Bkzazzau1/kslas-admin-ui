import 'package:flutter/material.dart';

enum AdminRole {
  lecturer,
  moderator,
  invigilator,
  examOfficer,
  recordsDepartment,
  departmentAdmin,
  facultyAdmin,
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
      case AdminRole.moderator:
        return 'Moderator';
      case AdminRole.invigilator:
        return 'Invigilator';
      case AdminRole.examOfficer:
        return 'Exam Officer';
      case AdminRole.recordsDepartment:
        return 'Records Department';
      case AdminRole.departmentAdmin:
        return 'Department Admin';
      case AdminRole.facultyAdmin:
        return 'Faculty Admin';
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
        return 'Course content, assignments, question preparation, marking, and result recommendations';
      case AdminRole.moderator:
        return 'Question moderation, assessment quality review, grading policy checks, and moderation comments';
      case AdminRole.invigilator:
        return 'Exam rooms, candidate check-in, attendance, device flags, and incident reporting';
      case AdminRole.examOfficer:
        return 'Exam timetables, question readiness, notices, course registration exceptions, and result release';
      case AdminRole.recordsDepartment:
        return 'Student records, course registration audit, CGPA, transcripts, cohorts, and academic history';
      case AdminRole.departmentAdmin:
        return 'Department courses, curriculum, lecturer allocation, student cohorts, and academic compliance';
      case AdminRole.facultyAdmin:
        return 'Faculty-wide academic operations, departments, programmes, approvals, and compliance reporting';
      case AdminRole.dlcDirector:
        return 'Distance learning centres, proctoring, live-class performance, approvals, and policy oversight';
      case AdminRole.hod:
        return 'Department courses, staff, results review, academic compliance, and escalation approval';
      case AdminRole.levelAdviser:
        return 'Student cohorts, course registration, carryover lists, progression, and advisement';
      case AdminRole.superAdmin:
        return 'Institution-wide administrative operations, configuration, audit, and role governance';
    }
  }

  IconData get icon {
    switch (this) {
      case AdminRole.lecturer:
        return Icons.school_outlined;
      case AdminRole.moderator:
        return Icons.rule_folder_outlined;
      case AdminRole.invigilator:
        return Icons.verified_user_outlined;
      case AdminRole.examOfficer:
        return Icons.assignment_turned_in_outlined;
      case AdminRole.recordsDepartment:
        return Icons.badge_outlined;
      case AdminRole.departmentAdmin:
        return Icons.account_tree_outlined;
      case AdminRole.facultyAdmin:
        return Icons.account_balance_outlined;
      case AdminRole.dlcDirector:
        return Icons.cast_for_education_outlined;
      case AdminRole.hod:
        return Icons.groups_2_outlined;
      case AdminRole.levelAdviser:
        return Icons.person_search_outlined;
      case AdminRole.superAdmin:
        return Icons.admin_panel_settings_outlined;
    }
  }
}
