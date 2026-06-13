import 'package:flutter/material.dart';

class LecturerAssignmentsMarkingPanel extends StatefulWidget {
  const LecturerAssignmentsMarkingPanel({super.key});

  @override
  State<LecturerAssignmentsMarkingPanel> createState() => _LecturerAssignmentsMarkingPanelState();
}

class _LecturerAssignmentsMarkingPanelState extends State<LecturerAssignmentsMarkingPanel> {
  String _selectedCourse = 'CSC 305';
  String _selectedStatus = 'Pending Marking';

  static const _assignments = [
    _AssignmentQueueItem(
      title: 'Graph Algorithms Practical',
      courseCode: 'CSC 305',
      submissions: 248,
      marked: 182,
      late: 14,
      flagged: 3,
      dueDate: '2026-06-18 17:00',
      status: 'Pending Marking',
    ),
    _AssignmentQueueItem(
      title: 'AI Search Strategy Report',
      courseCode: 'CSC 309',
      submissions: 197,
      marked: 88,
      late: 8,
      flagged: 11,
      dueDate: '2026-06-20 17:00',
      status: 'Integrity Review',
    ),
    _AssignmentQueueItem(
      title: 'Requirements Specification Draft',
      courseCode: 'SEN 301',
      submissions: 132,
      marked: 120,
      late: 4,
      flagged: 0,
      dueDate: '2026-06-15 12:00',
      status: 'Ready to Release',
    ),
  ];

  static const _submissions = [
    _SubmissionReviewItem(
      student: 'Ibrahim Yahaya',
      matricNo: '2023/C/SENG/0400',
      courseCode: 'CSC 305',
      submittedAt: '2026-06-17 21:42',
      score: 72,
      maxScore: 100,
      rubricStatus: 'Rubric partial',
      integrityStatus: 'Clean',
      feedback: 'Good explanation of traversal logic. Improve complexity analysis.',
    ),
    _SubmissionReviewItem(
      student: 'Aisha Musa',
      matricNo: '2023/C/SENG/0188',
      courseCode: 'CSC 305',
      submittedAt: '2026-06-17 18:04',
      score: 86,
      maxScore: 100,
      rubricStatus: 'Rubric complete',
      integrityStatus: 'Clean',
      feedback: 'Excellent diagrams and implementation notes.',
    ),
    _SubmissionReviewItem(
      student: 'Blessing John',
      matricNo: '2022/C/CSC/0112',
      courseCode: 'CSC 309',
      submittedAt: '2026-06-20 19:10',
      score: 0,
      maxScore: 100,
      rubricStatus: 'Needs review',
      integrityStatus: 'Similarity flag',
      feedback: 'Possible shared content. Requires lecturer review.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filteredAssignments = _assignments
        .where((item) => _selectedCourse == 'All' || item.courseCode == _selectedCourse)
        .where((item) => _selectedStatus == 'All' || item.status == _selectedStatus)
        .toList();
    final filteredSubmissions = _submissions
        .where((item) => _selectedCourse == 'All' || item.courseCode == _selectedCourse)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_ind_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lecturer Assignments & Marking',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_task_outlined),
                  label: const Text('Create assignment'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _AssignmentChip(label: 'Open assignments: 12', icon: Icons.assignment_outlined),
                _AssignmentChip(label: 'Pending marking: 302', icon: Icons.edit_note_outlined),
                _AssignmentChip(label: 'Late submissions: 26', icon: Icons.schedule_outlined),
                _AssignmentChip(label: 'Integrity flags: 14', icon: Icons.gpp_maybe_outlined),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCourse,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All courses')),
                      DropdownMenuItem(value: 'CSC 305', child: Text('CSC 305')),
                      DropdownMenuItem(value: 'CSC 309', child: Text('CSC 309')),
                      DropdownMenuItem(value: 'SEN 301', child: Text('SEN 301')),
                    ],
                    onChanged: (value) => setState(() => _selectedCourse = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Course'),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All statuses')),
                      DropdownMenuItem(value: 'Pending Marking', child: Text('Pending Marking')),
                      DropdownMenuItem(value: 'Integrity Review', child: Text('Integrity Review')),
                      DropdownMenuItem(value: 'Ready to Release', child: Text('Ready to Release')),
                    ],
                    onChanged: (value) => setState(() => _selectedStatus = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Assignment queue',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final assignment in filteredAssignments) _AssignmentQueueTile(item: assignment),
            const SizedBox(height: 18),
            Text(
              'Submission review',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final submission in filteredSubmissions) _SubmissionReviewTile(item: submission),
          ],
        ),
      ),
    );
  }
}

class _AssignmentQueueTile extends StatelessWidget {
  const _AssignmentQueueTile({required this.item});

  final _AssignmentQueueItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = item.status == 'Integrity Review'
        ? scheme.error
        : item.status == 'Ready to Release'
            ? scheme.primary
            : scheme.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${item.courseCode} • ${item.title}', style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('Due: ${item.dueDate}', style: TextStyle(color: scheme.onSurfaceVariant)),
              ]),
            ),
            _StatusBadge(text: item.status, color: statusColor),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _MiniPill(label: '${item.submissions} submissions'),
          _MiniPill(label: '${item.marked} marked'),
          _MiniPill(label: '${item.late} late'),
          _MiniPill(label: '${item.flagged} flags'),
        ]),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: item.submissions == 0 ? 0 : item.marked / item.submissions,
          minHeight: 6,
          borderRadius: BorderRadius.circular(999),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Review submissions'),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.rule_outlined),
            label: const Text('Rubric'),
          ),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.publish_outlined),
            label: const Text('Release marks'),
          ),
        ]),
      ]),
    );
  }
}

class _SubmissionReviewTile extends StatelessWidget {
  const _SubmissionReviewTile({required this.item});

  final _SubmissionReviewItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final flagged = item.integrityStatus != 'Clean';
    final statusColor = flagged ? scheme.error : scheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: flagged ? scheme.error.withValues(alpha: 0.4) : scheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${item.student} • ${item.matricNo}', style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('${item.courseCode} • Submitted ${item.submittedAt}', style: TextStyle(color: scheme.onSurfaceVariant)),
              ]),
            ),
            _StatusBadge(text: item.integrityStatus, color: statusColor),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _MiniPill(label: 'Score ${item.score}/${item.maxScore}'),
          _MiniPill(label: item.rubricStatus),
          _MiniPill(label: item.integrityStatus),
        ]),
        const SizedBox(height: 10),
        Text(item.feedback, style: TextStyle(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.file_open_outlined),
            label: const Text('Open submission'),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_note_outlined),
            label: const Text('Grade'),
          ),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.feedback_outlined),
            label: const Text('Send feedback'),
          ),
        ]),
      ]),
    );
  }
}

class _AssignmentChip extends StatelessWidget {
  const _AssignmentChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _AssignmentQueueItem {
  const _AssignmentQueueItem({
    required this.title,
    required this.courseCode,
    required this.submissions,
    required this.marked,
    required this.late,
    required this.flagged,
    required this.dueDate,
    required this.status,
  });

  final String title;
  final String courseCode;
  final int submissions;
  final int marked;
  final int late;
  final int flagged;
  final String dueDate;
  final String status;
}

class _SubmissionReviewItem {
  const _SubmissionReviewItem({
    required this.student,
    required this.matricNo,
    required this.courseCode,
    required this.submittedAt,
    required this.score,
    required this.maxScore,
    required this.rubricStatus,
    required this.integrityStatus,
    required this.feedback,
  });

  final String student;
  final String matricNo;
  final String courseCode;
  final String submittedAt;
  final int score;
  final int maxScore;
  final String rubricStatus;
  final String integrityStatus;
  final String feedback;
}
