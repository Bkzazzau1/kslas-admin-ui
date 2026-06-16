import 'package:flutter/material.dart';

class InvigilatorEvidenceReviewPanel extends StatefulWidget {
  const InvigilatorEvidenceReviewPanel({super.key, this.section = 'Review'});

  final String section;

  @override
  State<InvigilatorEvidenceReviewPanel> createState() =>
      _InvigilatorEvidenceReviewPanelState();
}

class _InvigilatorEvidenceReviewPanelState
    extends State<InvigilatorEvidenceReviewPanel> {
  String _selectedSeverity = 'All';
  String _selectedStatus = 'All';
  String _selectedEvidence = 'All';
  int _selectedIndex = 0;

  static const _cases = [
    _EvidenceCase(
      candidate: 'Aisha Musa',
      matric: 'KASU/CSC/021',
      course: 'CSC 309 Artificial Intelligence',
      session: 'DLC Online Proctoring Group A',
      eventType: 'Multiple faces detected',
      severity: 'High',
      status: 'Pending review',
      riskScore: 86,
      confidence: 0.94,
      evidenceTypes: ['Camera', 'Manifest'],
      evidenceStatus: 'Captured',
      evidencePath: 'evidence://KASU/CSC/021/session-309/case-001.json',
      time: 'Today, 10:38',
      recommendation:
          'Review camera frame evidence and escalate if second person remains visible.',
      decision: 'No decision yet',
    ),
    _EvidenceCase(
      candidate: 'Bello Adamu',
      matric: 'KASU/CSC/044',
      course: 'CSC 309 Artificial Intelligence',
      session: 'DLC Online Proctoring Group A',
      eventType: 'Human voice detected',
      severity: 'High',
      status: 'Escalated',
      riskScore: 74,
      confidence: 0.89,
      evidenceTypes: ['Audio', 'Manifest'],
      evidenceStatus: 'Captured',
      evidencePath: 'evidence://KASU/CSC/044/session-309/case-002.json',
      time: 'Today, 10:42',
      recommendation:
          'Listen to the short audio clip and compare with mouth movement timeline.',
      decision: 'Escalated to exam officer',
    ),
    _EvidenceCase(
      candidate: 'Maryam Sani',
      matric: 'KASU/CSC/078',
      course: 'GST 211 Communication Skills',
      session: 'Morning CBT Block',
      eventType: 'Tab switching detected',
      severity: 'Medium',
      status: 'Pending review',
      riskScore: 46,
      confidence: 0.78,
      evidenceTypes: ['Screenshot', 'Manifest'],
      evidenceStatus: 'Pending capture',
      evidencePath: 'evidence://KASU/CSC/078/session-gst/case-003.json',
      time: 'Today, 10:51',
      recommendation:
          'Confirm whether the system app lost focus or candidate attempted navigation.',
      decision: 'No decision yet',
    ),
    _EvidenceCase(
      candidate: 'Usman Ibrahim',
      matric: 'KASU/BUS/012',
      course: 'ACC 201 Financial Accounting',
      session: 'Hybrid Practical Session',
      eventType: 'Phone detected',
      severity: 'Critical',
      status: 'Malpractice draft',
      riskScore: 112,
      confidence: 0.97,
      evidenceTypes: ['Camera', 'Screenshot', 'Manifest'],
      evidenceStatus: 'Captured',
      evidencePath: 'evidence://KASU/BUS/012/session-acc/case-004.json',
      time: 'Today, 11:06',
      recommendation:
          'Prepare malpractice report if physical invigilator confirms device presence.',
      decision: 'Draft report opened',
    ),
  ];

  List<_EvidenceCase> get _filteredCases {
    return _cases.where((item) {
      final severityOk = _selectedSeverity == 'All' ||
          item.severity == _selectedSeverity;
      final statusOk = _selectedStatus == 'All' || item.status == _selectedStatus;
      final evidenceOk = _selectedEvidence == 'All' ||
          item.evidenceTypes.contains(_selectedEvidence);
      return severityOk && statusOk && evidenceOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cases = _filteredCases;
    final selected = cases.isEmpty
        ? null
        : cases[_selectedIndex.clamp(0, cases.length - 1)];
    final scheme = Theme.of(context).colorScheme;
    final isReportMode = widget.section == 'Malpractice Reports';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isReportMode
                      ? Icons.gpp_maybe_outlined
                      : Icons.verified_user_outlined,
                  color: scheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isReportMode
                        ? 'Malpractice Evidence Review'
                        : 'Invigilator Evidence Review Dashboard',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: selected == null ? null : () {},
                  icon: const Icon(Icons.assignment_turned_in_outlined),
                  label: Text(isReportMode ? 'Submit report' : 'Close review'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _EvidenceMetricChip(
                  label: 'Open evidence: 24',
                  icon: Icons.folder_open_outlined,
                ),
                _EvidenceMetricChip(
                  label: 'Captured: 18',
                  icon: Icons.check_circle_outline,
                ),
                _EvidenceMetricChip(
                  label: 'Pending capture: 4',
                  icon: Icons.pending_actions_outlined,
                ),
                _EvidenceMetricChip(
                  label: 'Critical: 3',
                  icon: Icons.priority_high_outlined,
                ),
                _EvidenceMetricChip(
                  label: 'Draft reports: 5',
                  icon: Icons.description_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FilterBar(
              selectedSeverity: _selectedSeverity,
              selectedStatus: _selectedStatus,
              selectedEvidence: _selectedEvidence,
              onSeverityChanged: (value) => setState(() {
                _selectedSeverity = value;
                _selectedIndex = 0;
              }),
              onStatusChanged: (value) => setState(() {
                _selectedStatus = value;
                _selectedIndex = 0;
              }),
              onEvidenceChanged: (value) => setState(() {
                _selectedEvidence = value;
                _selectedIndex = 0;
              }),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 900;
                if (compact) {
                  return Column(
                    children: [
                      _CaseList(
                        cases: cases,
                        selectedIndex: _selectedIndex,
                        onSelected: (index) => setState(() => _selectedIndex = index),
                      ),
                      const SizedBox(height: 14),
                      _EvidenceDetail(caseItem: selected),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 390,
                      child: _CaseList(
                        cases: cases,
                        selectedIndex: _selectedIndex,
                        onSelected: (index) => setState(() => _selectedIndex = index),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _EvidenceDetail(caseItem: selected)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selectedSeverity,
    required this.selectedStatus,
    required this.selectedEvidence,
    required this.onSeverityChanged,
    required this.onStatusChanged,
    required this.onEvidenceChanged,
  });

  final String selectedSeverity;
  final String selectedStatus;
  final String selectedEvidence;
  final ValueChanged<String> onSeverityChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onEvidenceChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _DropdownFilter(
          label: 'Severity',
          value: selectedSeverity,
          values: const ['All', 'Critical', 'High', 'Medium', 'Low'],
          onChanged: onSeverityChanged,
        ),
        _DropdownFilter(
          label: 'Status',
          value: selectedStatus,
          values: const [
            'All',
            'Pending review',
            'Escalated',
            'Malpractice draft',
          ],
          onChanged: onStatusChanged,
        ),
        _DropdownFilter(
          label: 'Evidence',
          value: selectedEvidence,
          values: const ['All', 'Camera', 'Audio', 'Screenshot', 'Manifest'],
          onChanged: onEvidenceChanged,
        ),
      ],
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        items: [
          for (final item in values)
            DropdownMenuItem(value: item, child: Text(item)),
        ],
        onChanged: (next) => onChanged(next ?? value),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _CaseList extends StatelessWidget {
  const _CaseList({
    required this.cases,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_EvidenceCase> cases;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    if (cases.isEmpty) {
      return const _EmptyState(
        icon: Icons.search_off_outlined,
        title: 'No evidence cases match this filter.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidence queue',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < cases.length; i++)
          _CaseTile(
            caseItem: cases[i],
            selected: selectedIndex == i,
            onTap: () => onSelected(i),
          ),
      ],
    );
  }
}

class _CaseTile extends StatelessWidget {
  const _CaseTile({
    required this.caseItem,
    required this.selected,
    required this.onTap,
  });

  final _EvidenceCase caseItem;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? scheme.primaryContainer.withValues(alpha: 0.22)
              : scheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    caseItem.eventType,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                _SeverityBadge(severity: caseItem.severity),
              ],
            ),
            const SizedBox(height: 6),
            Text('${caseItem.candidate} • ${caseItem.matric}'),
            const SizedBox(height: 4),
            Text(
              '${caseItem.course} • ${caseItem.time}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MiniEvidencePill(label: 'Risk ${caseItem.riskScore}'),
                _MiniEvidencePill(label: caseItem.evidenceStatus),
                _MiniEvidencePill(label: caseItem.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EvidenceDetail extends StatelessWidget {
  const _EvidenceDetail({required this.caseItem});

  final _EvidenceCase? caseItem;

  @override
  Widget build(BuildContext context) {
    final item = caseItem;
    final scheme = Theme.of(context).colorScheme;
    if (item == null) {
      return const _EmptyState(
        icon: Icons.folder_off_outlined,
        title: 'Select an evidence case to review.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
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
                      item.candidate,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text('${item.matric} • ${item.session}'),
                  ],
                ),
              ),
              _SeverityBadge(severity: item.severity),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniEvidencePill(label: 'Confidence ${(item.confidence * 100).round()}%'),
              _MiniEvidencePill(label: 'Risk score ${item.riskScore}'),
              _MiniEvidencePill(label: item.status),
              _MiniEvidencePill(label: item.evidenceStatus),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Evidence manifest',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          SelectableText(item.evidencePath),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final evidence in item.evidenceTypes)
                Chip(
                  avatar: Icon(_iconForEvidence(evidence), size: 18),
                  label: Text(evidence),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'AI recommendation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(item.recommendation),
          const SizedBox(height: 18),
          Text(
            'Decision trail',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          _TimelineLine(icon: Icons.sensors_outlined, text: item.eventType),
          _TimelineLine(icon: Icons.folder_outlined, text: item.evidenceStatus),
          _TimelineLine(icon: Icons.rule_outlined, text: item.decision),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Open evidence'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Clear candidate'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.warning_amber_outlined),
                label: const Text('Issue warning'),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.gpp_maybe_outlined),
                label: const Text('Escalate report'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForEvidence(String evidence) {
    switch (evidence) {
      case 'Camera':
        return Icons.photo_camera_outlined;
      case 'Audio':
        return Icons.graphic_eq_outlined;
      case 'Screenshot':
        return Icons.screenshot_monitor_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}

class _TimelineLine extends StatelessWidget {
  const _TimelineLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _EvidenceMetricChip extends StatelessWidget {
  const _EvidenceMetricChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon, size: 18, color: scheme.primary),
      label: Text(label),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final String severity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = severity == 'Critical'
        ? scheme.error
        : severity == 'High'
            ? scheme.error
            : severity == 'Medium'
                ? scheme.secondary
                : scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.42)),
      ),
      child: Text(
        severity,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _MiniEvidencePill extends StatelessWidget {
  const _MiniEvidencePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: scheme.surfaceContainerHighest,
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: scheme.primary),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _EvidenceCase {
  const _EvidenceCase({
    required this.candidate,
    required this.matric,
    required this.course,
    required this.session,
    required this.eventType,
    required this.severity,
    required this.status,
    required this.riskScore,
    required this.confidence,
    required this.evidenceTypes,
    required this.evidenceStatus,
    required this.evidencePath,
    required this.time,
    required this.recommendation,
    required this.decision,
  });

  final String candidate;
  final String matric;
  final String course;
  final String session;
  final String eventType;
  final String severity;
  final String status;
  final int riskScore;
  final double confidence;
  final List<String> evidenceTypes;
  final String evidenceStatus;
  final String evidencePath;
  final String time;
  final String recommendation;
  final String decision;
}
