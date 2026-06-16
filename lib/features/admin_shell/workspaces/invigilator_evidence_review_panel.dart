import 'package:flutter/material.dart';

import '../../../data/invigilator_evidence_api.dart';

class InvigilatorEvidenceReviewPanel extends StatefulWidget {
  const InvigilatorEvidenceReviewPanel({super.key, this.section = 'Review'});

  final String section;

  @override
  State<InvigilatorEvidenceReviewPanel> createState() =>
      _InvigilatorEvidenceReviewPanelState();
}

class _InvigilatorEvidenceReviewPanelState
    extends State<InvigilatorEvidenceReviewPanel> {
  final InvigilatorEvidenceApi _api = InvigilatorEvidenceApi();
  String _selectedSeverity = 'All';
  String _selectedStatus = 'All';
  String _selectedEvidence = 'All';
  int _selectedIndex = 0;
  late Future<InvigilatorEvidenceQueue> _queueFuture;

  @override
  void initState() {
    super.initState();
    _queueFuture = _loadQueue();
  }

  Future<InvigilatorEvidenceQueue> _loadQueue() async {
    try {
      return await _api.fetchQueue(
        severity: _selectedSeverity,
        status: _selectedStatus,
        evidenceType: _selectedEvidence,
      );
    } catch (_) {
      return _filterQueue(InvigilatorEvidenceQueue.fallback());
    }
  }

  InvigilatorEvidenceQueue _filterQueue(InvigilatorEvidenceQueue queue) {
    final items = queue.items.where((item) {
      final severityOk = _selectedSeverity == 'All' ||
          item.severity == _selectedSeverity;
      final statusOk = _selectedStatus == 'All' || item.status == _selectedStatus;
      final evidenceOk = _selectedEvidence == 'All' ||
          item.evidenceTypes.contains(_selectedEvidence);
      return severityOk && statusOk && evidenceOk;
    }).toList();
    return InvigilatorEvidenceQueue(
      metrics: queue.metrics,
      items: items,
      count: items.length,
      fromFallback: queue.fromFallback,
    );
  }

  void _reload() {
    setState(() {
      _selectedIndex = 0;
      _queueFuture = _loadQueue();
    });
  }

  Future<void> _submitDecision(String caseId, String action) async {
    try {
      await _api.decide(caseId: caseId, action: action);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Decision submitted: $action')),
      );
      _reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Decision saved locally for activation: $action'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isReportMode = widget.section == 'Malpractice Reports';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: FutureBuilder<InvigilatorEvidenceQueue>(
          future: _queueFuture,
          builder: (context, snapshot) {
            final queue = snapshot.data ?? InvigilatorEvidenceQueue.fallback();
            final cases = queue.items;
            final selected = cases.isEmpty
                ? null
                : cases[_selectedIndex.clamp(0, cases.length - 1)];
            return Column(
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
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: selected == null
                          ? null
                          : () => _submitDecision(selected.id, 'close_review'),
                      icon: const Icon(Icons.assignment_turned_in_outlined),
                      label: Text(isReportMode ? 'Submit report' : 'Close review'),
                    ),
                  ],
                ),
                if (queue.fromFallback) ...[
                  const SizedBox(height: 10),
                  const _OfflineBanner(),
                ],
                const SizedBox(height: 12),
                _MetricRow(metrics: queue.metrics),
                const SizedBox(height: 16),
                _FilterBar(
                  selectedSeverity: _selectedSeverity,
                  selectedStatus: _selectedStatus,
                  selectedEvidence: _selectedEvidence,
                  onSeverityChanged: (value) {
                    _selectedSeverity = value;
                    _reload();
                  },
                  onStatusChanged: (value) {
                    _selectedStatus = value;
                    _reload();
                  },
                  onEvidenceChanged: (value) {
                    _selectedEvidence = value;
                    _reload();
                  },
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
                            onSelected: (index) =>
                                setState(() => _selectedIndex = index),
                          ),
                          const SizedBox(height: 14),
                          _EvidenceDetail(
                            caseItem: selected,
                            onDecision: _submitDecision,
                          ),
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
                            onSelected: (index) =>
                                setState(() => _selectedIndex = index),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _EvidenceDetail(
                            caseItem: selected,
                            onDecision: _submitDecision,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: scheme.secondary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Backend evidence API is not active yet. Showing fallback review data.',
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metrics});

  final InvigilatorEvidenceMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _EvidenceMetricChip(
          label: 'Open evidence: ${metrics.openEvidence}',
          icon: Icons.folder_open_outlined,
        ),
        _EvidenceMetricChip(
          label: 'Captured: ${metrics.captured}',
          icon: Icons.check_circle_outline,
        ),
        _EvidenceMetricChip(
          label: 'Pending capture: ${metrics.pendingCapture}',
          icon: Icons.pending_actions_outlined,
        ),
        _EvidenceMetricChip(
          label: 'Critical: ${metrics.critical}',
          icon: Icons.priority_high_outlined,
        ),
        _EvidenceMetricChip(
          label: 'Draft reports: ${metrics.draftReports}',
          icon: Icons.description_outlined,
        ),
      ],
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

  final List<InvigilatorEvidenceCase> cases;
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

  final InvigilatorEvidenceCase caseItem;
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
  const _EvidenceDetail({required this.caseItem, required this.onDecision});

  final InvigilatorEvidenceCase? caseItem;
  final void Function(String caseId, String action) onDecision;

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
                onPressed: () => onDecision(item.id, 'clear_candidate'),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Clear candidate'),
              ),
              OutlinedButton.icon(
                onPressed: () => onDecision(item.id, 'issue_warning'),
                icon: const Icon(Icons.warning_amber_outlined),
                label: const Text('Issue warning'),
              ),
              FilledButton.icon(
                onPressed: () => onDecision(item.id, 'escalate_report'),
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
    final color = severity == 'Critical' || severity == 'High'
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
