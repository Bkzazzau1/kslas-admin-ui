class AdminNoticeBackendPath {
  static const listNotices = '/api/v1/admin/notices';
  static const createNotice = '/api/v1/admin/notices';
  static const publishNotice = '/api/v1/admin/notices/{noticeId}/publish';
  static const archiveNotice = '/api/v1/admin/notices/{noticeId}/archive';
  static const acknowledgements = '/api/v1/admin/notices/{noticeId}/acknowledgements';
  static const auditLogs = '/api/v1/admin/notices/{noticeId}/audit-logs';
}

class AdminCourseRegistrationBackendPath {
  static const pendingRegistrations = '/api/v1/admin/course-registrations/pending';
  static const approveRegistration = '/api/v1/admin/course-registrations/{registrationId}/approve';
  static const rejectRegistration = '/api/v1/admin/course-registrations/{registrationId}/reject';
  static const confirmCarryover = '/api/v1/admin/course-registrations/{registrationId}/carryovers/confirm';
  static const lockRegistration = '/api/v1/admin/course-registrations/{registrationId}/lock';
}

class AdminCohortBackendPath {
  static const listCohorts = '/api/v1/admin/cohorts';
  static const createCohort = '/api/v1/admin/cohorts';
  static const updateCohort = '/api/v1/admin/cohorts/{cohortId}';
  static const archiveCohort = '/api/v1/admin/cohorts/{cohortId}/archive';
  static const assignStudents = '/api/v1/admin/cohorts/{cohortId}/students';
}

class AdminResultBackendPath {
  static const lecturerSubmissions = '/api/v1/admin/results/lecturer-submissions';
  static const hodReview = '/api/v1/admin/results/{batchId}/hod-review';
  static const examOfficeRelease = '/api/v1/admin/results/{batchId}/release';
  static const recordsReconcile = '/api/v1/admin/results/{batchId}/records-reconcile';
}

class AdminWorkflowContract {
  const AdminWorkflowContract._();

  static const ownershipRules = [
    'Lecturer, moderator, invigilator, exam officer, records, department, faculty, HoD, level adviser and super admin workflows belong in kslas-admin-ui.',
    'The student app must only read student-visible data and submit student actions such as course registration, assignment submissions, exam attempts, acknowledgements and live-class participation.',
    'Admin APIs must derive staff role and permission from the authenticated token before exposing admin data.',
    'Notice publishing, cohort creation, carryover confirmation, result release, and registration approval must never be performed by the student app.',
  ];

  static const courseRegistrationApprovalRules = [
    'Core courses are validated from programme curriculum.',
    'Electives must match programme, level, semester and cohort rules.',
    'Carryover/repeat courses must be confirmed against released records before approval.',
    'Overload or late registration must require authorized override with audit log.',
  ];

  static const recordsDepartmentRules = [
    'Maintain student profile, programme, department, level, semester and cohort records.',
    'Reconcile completed courses, repeated courses, missing results, CGPA and transcript preview.',
    'Lock approved academic records according to institution policy.',
  ];
}
