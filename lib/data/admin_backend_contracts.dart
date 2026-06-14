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

class AdminAssignmentBackendPath {
  static const listAssignments = '/api/v1/admin/assignments';
  static const createAssignment = '/api/v1/admin/assignments';
  static const updateAssignment = '/api/v1/admin/assignments/{assignmentId}';
  static const publishAssignment = '/api/v1/admin/assignments/{assignmentId}/publish';
  static const listSubmissions = '/api/v1/admin/assignments/{assignmentId}/submissions';
  static const gradeSubmission = '/api/v1/admin/assignments/{assignmentId}/submissions/{submissionId}/grade';
  static const releaseMarks = '/api/v1/admin/assignments/{assignmentId}/release-marks';
  static const integrityFlags = '/api/v1/admin/assignments/{assignmentId}/integrity-flags';
  static const lateSubmissionDecisions = '/api/v1/admin/assignments/{assignmentId}/late-submissions';
}

class AdminQuestionReviewBackendPath {
  static const questionSets = '/api/v1/admin/question-sets';
  static const questionSetDetail = '/api/v1/admin/question-sets/{questionSetId}';
  static const addComment = '/api/v1/admin/question-sets/{questionSetId}/comments';
  static const approveQuestionSet = '/api/v1/admin/question-sets/{questionSetId}/approve';
  static const returnToLecturer = '/api/v1/admin/question-sets/{questionSetId}/return-to-lecturer';
  static const rubricReview = '/api/v1/admin/question-sets/{questionSetId}/rubric-review';
  static const difficultyReview = '/api/v1/admin/question-sets/{questionSetId}/difficulty-review';
  static const handoverToExamOffice = '/api/v1/admin/question-sets/{questionSetId}/handover-to-exam-office';
}

class AdminExamBackendPath {
  static const examPlans = '/api/v1/admin/exams';
  static const createExam = '/api/v1/admin/exams';
  static const updateExam = '/api/v1/admin/exams/{examId}';
  static const approveQuestions = '/api/v1/admin/exams/{examId}/questions/approve';
  static const packageQuestions = '/api/v1/admin/exams/{examId}/questions/package';
  static const hallSetup = '/api/v1/admin/exams/{examId}/hall-setup';
  static const assignInvigilators = '/api/v1/admin/exams/{examId}/invigilators';
  static const readinessChecklist = '/api/v1/admin/exams/{examId}/readiness';
  static const openExam = '/api/v1/admin/exams/{examId}/open';
  static const closeExam = '/api/v1/admin/exams/{examId}/close';
  static const incidents = '/api/v1/admin/exams/{examId}/incidents';
  static const escalateIncident = '/api/v1/admin/exams/{examId}/incidents/{incidentId}/escalate';
}

class AdminPeopleBackendPath {
  static const staffAccounts = '/api/v1/admin/staff';
  static const createStaff = '/api/v1/admin/staff';
  static const updateStaff = '/api/v1/admin/staff/{staffId}';
  static const deactivateStaff = '/api/v1/admin/staff/{staffId}/deactivate';
  static const reactivateStaff = '/api/v1/admin/staff/{staffId}/reactivate';
  static const roleAssignments = '/api/v1/admin/staff/{staffId}/roles';
  static const permissionOverrides = '/api/v1/admin/staff/{staffId}/permissions';
  static const lecturerAllocations = '/api/v1/admin/staff/{staffId}/lecturer-allocations';
  static const moderatorAllocations = '/api/v1/admin/staff/{staffId}/moderator-allocations';
  static const invigilatorAllocations = '/api/v1/admin/staff/{staffId}/invigilator-allocations';
  static const accessAuditLogs = '/api/v1/admin/staff/{staffId}/access-audit-logs';
}

class AdminCohortBackendPath {
  static const listCohorts = '/api/v1/admin/cohorts';
  static const createCohort = '/api/v1/admin/cohorts';
  static const updateCohort = '/api/v1/admin/cohorts/{cohortId}';
  static const archiveCohort = '/api/v1/admin/cohorts/{cohortId}/archive';
  static const assignStudents = '/api/v1/admin/cohorts/{cohortId}/students';
}

class AdminResultBackendPath {
  static const resultBatches = '/api/v1/admin/results/batches';
  static const lecturerSubmissions = '/api/v1/admin/results/lecturer-submissions';
  static const submitBatch = '/api/v1/admin/results/{batchId}/submit';
  static const moderatorQuery = '/api/v1/admin/results/{batchId}/moderator-query';
  static const hodReview = '/api/v1/admin/results/{batchId}/hod-review';
  static const recordsReconcile = '/api/v1/admin/results/{batchId}/records-reconcile';
  static const examOfficeRelease = '/api/v1/admin/results/{batchId}/release';
  static const studentPublication = '/api/v1/admin/results/{batchId}/publish-to-students';
  static const auditTrail = '/api/v1/admin/results/{batchId}/audit-trail';
}

class AdminWorkflowContract {
  const AdminWorkflowContract._();

  static const ownershipRules = [
    'Lecturer, moderator, invigilator, exam officer, records, department, faculty, HoD, level adviser and super admin workflows belong in kslas-admin-ui.',
    'The student app must only read student-visible data and submit student actions such as course registration, assignment submissions, exam attempts, acknowledgements and live-class participation.',
    'Admin APIs must derive staff role and permission from the authenticated token before exposing admin data.',
    'Notice publishing, assignment creation, grading, question moderation, exam scheduling, question approval, invigilator assignment, staff role assignment, cohort creation, carryover confirmation, result release, and registration approval must never be performed by the student app.',
  ];

  static const courseRegistrationApprovalRules = [
    'Core courses are validated from programme curriculum.',
    'Electives must match programme, level, semester and cohort rules.',
    'Carryover/repeat courses must be confirmed against released records before approval.',
    'Overload or late registration must require authorized override with audit log.',
  ];

  static const assignmentMarkingRules = [
    'Lecturers may create and publish assignments only for assigned courses.',
    'Students submit assignments in the student app, while staff review and grade submissions in kslas-admin-ui.',
    'Rubric scores, feedback, late decisions, integrity flags, and released marks must be audit logged.',
    'Assignment marks should move to result workflow only after lecturer release or department policy approval.',
  ];

  static const questionReviewRules = [
    'Lecturers submit question sets for assigned courses only.',
    'Moderators review question clarity, coverage, difficulty balance, marking guide, answer key, and rubric completeness.',
    'Moderators may approve, return to lecturer, or add issue comments before exam office packaging.',
    'Approved question sets may be handed over to the exam office for secure packaging and scheduling.',
    'Every moderation comment, approval, return, rubric change, and handover must be audit logged.',
  ];

  static const examManagementRules = [
    'Exam officers create and schedule exams only after the lecturer and moderator question workflow is complete.',
    'Question approval, packaging, hall setup, proctoring mode, exam window and security rules are admin-only operations.',
    'Invigilator assignment must be tracked per hall, session, mode and candidate population.',
    'An exam should open only when readiness checks pass: questions approved, venue configured, candidates mapped, invigilators assigned and security settings confirmed.',
    'Incidents from invigilators, proctoring alerts or candidate verification must be reviewable and escalatable inside the admin UI.',
    'Every schedule change, approval, open/close action and incident escalation must be audit logged.',
  ];

  static const peopleAccessRules = [
    'Staff role assignment must be performed only by authorized department, faculty or super admin users.',
    'Lecturer permissions must be restricted to assigned courses unless an explicit override is approved.',
    'Moderator permissions must be restricted to assigned moderation batches or departments.',
    'Invigilator permissions must be restricted to assigned halls, exam sessions and incidents.',
    'Records department permissions are high-risk and must be audit logged for CGPA, transcript, cohort and student-record changes.',
    'Every role grant, permission override, deactivation, reactivation and work allocation must be audit logged.',
  ];

  static const resultApprovalRules = [
    'Lecturers submit result batches only for assigned courses.',
    'Moderator or HoD review must happen before exam office release where institution policy requires it.',
    'Records department must reconcile repeated courses, missing scores, carryovers and student academic history before final publication.',
    'Exam office controls final release and student publication.',
    'Every score edit, query, review, reconciliation and release action must be audit logged.',
  ];

  static const recordsDepartmentRules = [
    'Maintain student profile, programme, department, level, semester and cohort records.',
    'Reconcile completed courses, repeated courses, missing results, CGPA and transcript preview.',
    'Lock approved academic records according to institution policy.',
  ];
}
