import 'package:flutter/material.dart';

class ExamManagementPanel extends StatefulWidget {
  const ExamManagementPanel({super.key});

  @override
  State<ExamManagementPanel> createState() => _ExamManagementPanelState();
}

class _ExamManagementPanelState extends State<ExamManagementPanel> {
  String _selectedStatus = 'All';
  String _selectedMode = 'All';

  static const _exams = [
    _ExamPlan(
      courseCode: 'CSC 305',
      title: 'Data Structures CBT',
      mode: 'CBT Centre',
      dateTime: '2026-06-18 09:00',
      venue: 'ICT Lab A',
      candidates: 248,
      invigilators: 4,
      questionStatus: 'Approved',
      readiness: 'Ready',
      incidentCount: 0,
    ),
    _ExamPlan(
      courseCode: 'CSC 309',
      title: 'Artificial Intelligence Assessment',
      mode: 'Distance Learning',
      dateTime: '2026-06-20 14:00',
      venue: 'Online Proctored',
      candidates: 197,
      invigilators: 6,
      questionStatus: 'Moderator Query',
      readiness: 'Needs Attention',
      incidentCount: 2,
    ),
    _ExamPlan(
      courseCode: 'GST 303',
      title: 'Communication in English',
      mode: 'CBT Centre',
      dateTime: '2026-06-22 11:00',
      venue: 'CBT Centre 1',
      candidates: 620,
      invigilators: 10,
      questionStatus: 'Awaiting Exam Officer',
      readiness: 'Pending',
      incidentCount: 0,
    ),
    _ExamPlan(
      courseCode: 'SEN 301',
      title: 'Requirements Engineering Practical',
      mode: 'Hybrid',
      dateTime: '2026-06-25 10:00',
      venue: 'Lab B + Online',
      candidates: 132,
      invigilators: 3,
      questionStatus: 'Approved',
      readiness: 'Ready',
      incidentCount: 1,
    ),
  ];

  static const _incidents = [
    _ExamIncident(
      exam: 'CSC 309',
      report: 'Two candidates triggered repeated face-away alerts.',
      severity: 'High',
      owner: 'Chief Invigilator',
      time: 'Today, 09:34',
    ),
    _ExamIncident(
      exam: 'SEN 301',
      report: 'One workstation reported unstable network during upload.',
      severity: 'Medium',
      owner: 'Invigilator',
      time: 'Yesterday, 15:10',
    ),
    _ExamIncident(
      exam: 'GST 303',
      report: 'Question paper still awaiting final exam office packaging.',
      severity: 'Low',
      owner: 'Exam Officer',
      time: 'Yesterday, 10:45',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _exams
        .where(
          (exam) =>
              _selectedStatus == 'All' || exam.readiness == _selectedStatus,
        )
        .where((exam) => _selectedMode == 'All' || exam.mode == _selectedMode)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Exam Officer / Exam Management',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Schedule exam'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _ExamChip(
                  label: 'Scheduled exams: 42',
                  icon: Icons.event_available_outlined,
                ),
                _ExamChip(
                  label: 'Question approval: 9',
                  icon: Icons.rule_folder_outlined,
                ),
                _ExamChip(
                  label: 'Invigilator gaps: 4',
                  icon: Icons.person_add_alt_1_outlined,
                ),
                _ExamChip(
                  label: 'Open incidents: 3',
                  icon: Icons.report_problem_outlined,
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
                        child: Text('All readiness'),
                      ),
                      DropdownMenuItem(value: 'Ready', child: Text('Ready')),
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'Needs Attention',
                        child: Text('Needs Attention'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Readiness'),
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedMode,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All modes')),
                      DropdownMenuItem(
                        value: 'CBT Centre',
                        child: Text('CBT Centre'),
                      ),
                      DropdownMenuItem(
                        value: 'Distance Learning',
                        child: Text('Distance Learning'),
                      ),
                      DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedMode = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Exam mode'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Exam readiness queue',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final exam in filtered) _ExamPlanTile(exam: exam),
            const SizedBox(height: 18),
            Text(
              'Incident escalation',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final incident in _incidents)
              _IncidentTile(incident: incident),
          ],
        ),
      ),
    );
  }
}

class _ExamPlanTile extends StatelessWidget {
  const _ExamPlanTile({required this.exam});

  final _ExamPlan exam;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = exam.readiness == 'Ready'
        ? scheme.primary
        : exam.readiness == 'Needs Attention'
        ? scheme.error
        : scheme.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: exam.readiness == 'Needs Attention'
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
                      '${exam.courseCode} • ${exam.title}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exam.mode} • ${exam.dateTime} • ${exam.venue}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: exam.readiness, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: '${exam.candidates} candidates'),
              _MiniPill(label: '${exam.invigilators} invigilators'),
              _MiniPill(label: exam.questionStatus),
              _MiniPill(label: '${exam.incidentCount} incidents'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.rule_folder_outlined),
                label: const Text('Questions'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.meeting_room_outlined),
                label: const Text('Hall setup'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Invigilators'),
              ),
              FilledButton.icon(
                onPressed: exam.readiness == 'Ready' ? () {} : null,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Open exam'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IncidentTile extends StatelessWidget {
  const _IncidentTile({required this.incident});

  final _ExamIncident incident;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final severityColor = incident.severity == 'High'
        ? scheme.error
        : incident.severity == 'Medium'
        ? scheme.secondary
        : scheme.primary;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: severityColor.withValues(alpha: 0.12),
        foregroundColor: severityColor,
        child: const Icon(Icons.report_problem_outlined),
      ),
      title: Text(
        '${incident.exam} • ${incident.report}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text('${incident.owner} • ${incident.time}'),
      trailing: _StatusBadge(text: incident.severity, color: severityColor),
    );
  }
}

class _ExamChip extends StatelessWidget {
  const _ExamChip({required this.label, required this.icon});

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

class _ExamPlan {
  const _ExamPlan({
    required this.courseCode,
    required this.title,
    required this.mode,
    required this.dateTime,
    required this.venue,
    required this.candidates,
    required this.invigilators,
    required this.questionStatus,
    required this.readiness,
    required this.incidentCount,
  });

  final String courseCode;
  final String title;
  final String mode;
  final String dateTime;
  final String venue;
  final int candidates;
  final int invigilators;
  final String questionStatus;
  final String readiness;
  final int incidentCount;
}

class _ExamIncident {
  const _ExamIncident({
    required this.exam,
    required this.report,
    required this.severity,
    required this.owner,
    required this.time,
  });

  final String exam;
  final String report;
  final String severity;
  final String owner;
  final String time;
}
