import 'package:flutter/material.dart';

class ModeratorQuestionReviewPanel extends StatefulWidget {
  const ModeratorQuestionReviewPanel({super.key});

  @override
  State<ModeratorQuestionReviewPanel> createState() =>
      _ModeratorQuestionReviewPanelState();
}

class _ModeratorQuestionReviewPanelState
    extends State<ModeratorQuestionReviewPanel> {
  String _selectedStatus = 'All';
  String _selectedFormat = 'All';

  static const _questionSets = [
    _QuestionSet(
      courseCode: 'CSC 305',
      title: 'Data Structures Final CBT',
      lecturer: 'Dr. A. Musa',
      format: 'Mixed CBT',
      questions: 60,
      marks: 70,
      status: 'Ready to Approve',
      issueCount: 0,
      note: 'Question spread and difficulty balance passed moderation checks.',
    ),
    _QuestionSet(
      courseCode: 'CSC 309',
      title: 'AI Search Strategy Assessment',
      lecturer: 'Dr. L. Ibrahim',
      format: 'Essay + Objective',
      questions: 35,
      marks: 100,
      status: 'Return to Lecturer',
      issueCount: 4,
      note:
          'Essay rubric is incomplete and two objective questions have ambiguous options.',
    ),
    _QuestionSet(
      courseCode: 'SEN 301',
      title: 'Requirements Engineering Practical',
      lecturer: 'Engr. H. Sani',
      format: 'Practical + Whiteboard',
      questions: 12,
      marks: 100,
      status: 'Needs Review',
      issueCount: 2,
      note: 'Whiteboard marking guide needs clearer scoring breakdown.',
    ),
    _QuestionSet(
      courseCode: 'GST 303',
      title: 'Communication in English',
      lecturer: 'Mrs. H. John',
      format: 'Objective',
      questions: 80,
      marks: 60,
      status: 'Approved',
      issueCount: 0,
      note: 'Approved and ready for exam officer packaging.',
    ),
  ];

  static const _comments = [
    _ModerationComment(
      courseCode: 'CSC 309',
      author: 'Moderator',
      message:
          'Question 14 has two defensible answers. Please revise option B or provide stronger key justification.',
      severity: 'High',
      time: 'Today, 11:22',
    ),
    _ModerationComment(
      courseCode: 'SEN 301',
      author: 'Moderator',
      message:
          'Practical rubric should separate requirement clarity, modelling accuracy, and feasibility analysis.',
      severity: 'Medium',
      time: 'Today, 09:18',
    ),
    _ModerationComment(
      courseCode: 'CSC 305',
      author: 'Moderator',
      message:
          'Coverage is balanced across stacks, queues, trees, graphs, and algorithm complexity.',
      severity: 'Low',
      time: 'Yesterday, 15:41',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _questionSets
        .where(
          (set) => _selectedStatus == 'All' || set.status == _selectedStatus,
        )
        .where(
          (set) => _selectedFormat == 'All' || set.format == _selectedFormat,
        )
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rule_folder_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Moderator / Question Review',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Approve selected'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _ReviewChip(
                  label: 'Submitted sets: 14',
                  icon: Icons.inventory_2_outlined,
                ),
                _ReviewChip(
                  label: 'Needs review: 5',
                  icon: Icons.manage_search_outlined,
                ),
                _ReviewChip(
                  label: 'Returned: 3',
                  icon: Icons.keyboard_return_outlined,
                ),
                _ReviewChip(
                  label: 'Approved: 28',
                  icon: Icons.verified_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedStatus,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All statuses'),
                      ),
                      DropdownMenuItem(
                        value: 'Needs Review',
                        child: Text('Needs Review'),
                      ),
                      DropdownMenuItem(
                        value: 'Return to Lecturer',
                        child: Text('Return to Lecturer'),
                      ),
                      DropdownMenuItem(
                        value: 'Ready to Approve',
                        child: Text('Ready to Approve'),
                      ),
                      DropdownMenuItem(
                        value: 'Approved',
                        child: Text('Approved'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value ?? 'All'),
                    decoration: const InputDecoration(
                      labelText: 'Review status',
                    ),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedFormat,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All formats'),
                      ),
                      DropdownMenuItem(
                        value: 'Objective',
                        child: Text('Objective'),
                      ),
                      DropdownMenuItem(
                        value: 'Essay + Objective',
                        child: Text('Essay + Objective'),
                      ),
                      DropdownMenuItem(
                        value: 'Mixed CBT',
                        child: Text('Mixed CBT'),
                      ),
                      DropdownMenuItem(
                        value: 'Practical + Whiteboard',
                        child: Text('Practical + Whiteboard'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedFormat = value ?? 'All'),
                    decoration: const InputDecoration(
                      labelText: 'Question format',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Question sets',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final set in filtered) _QuestionSetTile(set: set),
            const SizedBox(height: 18),
            Text(
              'Moderation comments',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final comment in _comments) _CommentTile(comment: comment),
          ],
        ),
      ),
    );
  }
}

class _QuestionSetTile extends StatelessWidget {
  const _QuestionSetTile({required this.set});

  final _QuestionSet set;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = set.status == 'Return to Lecturer'
        ? scheme.error
        : set.status == 'Approved' || set.status == 'Ready to Approve'
        ? scheme.primary
        : scheme.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: set.issueCount > 0
              ? scheme.error.withValues(alpha: 0.4)
              : scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${set.courseCode} • ${set.title}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${set.lecturer} • ${set.format}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: set.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: '${set.questions} questions'),
              _MiniPill(label: '${set.marks} marks'),
              _MiniPill(label: '${set.issueCount} issues'),
              _MiniPill(label: 'Rubric check'),
            ],
          ),
          const SizedBox(height: 10),
          Text(set.note, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Review questions'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.comment_outlined),
                label: const Text('Add comment'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.keyboard_return_outlined),
                label: const Text('Return'),
              ),
              FilledButton.icon(
                onPressed: set.status == 'Return to Lecturer' ? null : () {},
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Approve'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final _ModerationComment comment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final severityColor = comment.severity == 'High'
        ? scheme.error
        : comment.severity == 'Medium'
        ? scheme.secondary
        : scheme.primary;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: severityColor.withValues(alpha: 0.12),
        foregroundColor: severityColor,
        child: const Icon(Icons.rate_review_outlined),
      ),
      title: Text(
        '${comment.courseCode} • ${comment.message}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text('${comment.author} • ${comment.time}'),
      trailing: _StatusBadge(text: comment.severity, color: severityColor),
    );
  }
}

class _ReviewChip extends StatelessWidget {
  const _ReviewChip({required this.label, required this.icon});

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
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
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
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _QuestionSet {
  const _QuestionSet({
    required this.courseCode,
    required this.title,
    required this.lecturer,
    required this.format,
    required this.questions,
    required this.marks,
    required this.status,
    required this.issueCount,
    required this.note,
  });

  final String courseCode;
  final String title;
  final String lecturer;
  final String format;
  final int questions;
  final int marks;
  final String status;
  final int issueCount;
  final String note;
}

class _ModerationComment {
  const _ModerationComment({
    required this.courseCode,
    required this.author,
    required this.message,
    required this.severity,
    required this.time,
  });

  final String courseCode;
  final String author;
  final String message;
  final String severity;
  final String time;
}
