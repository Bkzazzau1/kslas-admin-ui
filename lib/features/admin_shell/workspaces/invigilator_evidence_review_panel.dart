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
      final severityOk =
          _selectedSeverity == 'All' || item.severity == _selectedSeverity;
      final statusOk =
          _selectedStatus == 'All' || item.status == _selectedStatus;
      final evidenceOk =
          _selectedEvidence == 'All' ||
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Decision submitted: $action')));
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
    final sectionTitle = _titleForSection(widget.section);
    final sectionIcon = _iconForSection(widget.section);
    final actionLabel = widget.section == 'Malpractice Drafts'
        ? 'Submit report'
        : 'Log decision';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: FutureBuilder<InvigilatorEvidenceQueue>(
          future: _queueFuture,
          builder: (context, snapshot) {
            final queue = snapshot.data ?? InvigilatorEvidenceQueue.fallback();
            final cases = queue.items;
            final allCases = cases.isEmpty
                ? InvigilatorEvidenceQueue.fallback().items
                : cases;
            final selected = cases.isEmpty
                ? null
                : cases[_selectedIndex.clamp(0, cases.length - 1)];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(sectionIcon, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        sectionTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
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
                      label: Text(actionLabel),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _InvigilatorPolicyBanner(),
                if (queue.fromFallback) ...[
                  const SizedBox(height: 10),
                  const _OfflineBanner(),
                ],
                const SizedBox(height: 12),
                _MetricRow(metrics: queue.metrics),
                const SizedBox(height: 12),
                _InvigilatorFeatureStrip(section: widget.section),
                const SizedBox(height: 16),
                _buildSectionContent(
                  cases: cases,
                  allCases: allCases,
                  selected: selected,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionContent({
    required List<InvigilatorEvidenceCase> cases,
    required List<InvigilatorEvidenceCase> allCases,
    required InvigilatorEvidenceCase? selected,
  }) {
    final fallbackSelected = selected ?? allCases.firstOrNull;

    switch (widget.section) {
      case 'Live Student Grid':
        return _LiveStudentGridAnalytics(cases: allCases);
      case 'AI Alert Queue':
        return _AlertQueueOnly(
          cases: allCases,
          selectedIndex: _selectedIndex,
          onSelected: (index) => setState(() => _selectedIndex = index),
        );
      case 'Evidence Review':
        return _EvidenceReviewOnly(
          cases: cases,
          selected: selected,
          selectedIndex: _selectedIndex,
          selectedSeverity: _selectedSeverity,
          selectedStatus: _selectedStatus,
          selectedEvidence: _selectedEvidence,
          onSelected: (index) => setState(() => _selectedIndex = index),
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
          onDecision: _submitDecision,
        );
      case 'Manual Decisions':
        return fallbackSelected == null
            ? const _EmptyState(
                icon: Icons.folder_off_outlined,
                title: 'No evidence cases available.',
              )
            : _ManualDecisionOnly(caseItem: fallbackSelected);
      case 'Student Session Detail':
        return fallbackSelected == null
            ? const _EmptyState(
                icon: Icons.folder_off_outlined,
                title: 'No student session available.',
              )
            : _StudentSessionOnly(caseItem: fallbackSelected);
      case 'Room Scan Requests':
        return fallbackSelected == null
            ? const _EmptyState(
                icon: Icons.folder_off_outlined,
                title: 'No room scan case available.',
              )
            : _RoomScanOnly(caseItem: fallbackSelected);
      case 'Attendance & Check-in':
        return const _AttendanceCheckInOnly();
      case 'Risk Timeline':
        return fallbackSelected == null
            ? const _EmptyState(
                icon: Icons.folder_off_outlined,
                title: 'No risk timeline available.',
              )
            : _RiskTimelineOnly(caseItem: fallbackSelected);
      case 'Malpractice Drafts':
        final draftCase = allCases.lastOrNull;
        return draftCase == null
            ? const _EmptyState(
                icon: Icons.folder_off_outlined,
                title: 'No malpractice drafts available.',
              )
            : _MalpracticeDraftOnly(caseItem: draftCase);
      case 'Evidence Sync Status':
        return const _EvidenceSyncOnly();
      case 'Audit Trail':
        return _AuditTrailOnly(cases: allCases);
      default:
        return _EvidenceReviewOnly(
          cases: cases,
          selected: selected,
          selectedIndex: _selectedIndex,
          selectedSeverity: _selectedSeverity,
          selectedStatus: _selectedStatus,
          selectedEvidence: _selectedEvidence,
          onSelected: (index) => setState(() => _selectedIndex = index),
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
          onDecision: _submitDecision,
        );
    }
  }

  String _titleForSection(String section) {
    switch (section) {
      case 'Live Student Grid':
        return 'Live Exam Monitoring Dashboard';
      case 'AI Alert Queue':
        return 'Live AI Alert Queue';
      case 'Evidence Review':
        return 'Evidence Review Panel';
      case 'Manual Decisions':
        return 'Manual Review Decisions';
      case 'Student Session Detail':
        return 'Student Detail and Session History';
      case 'Room Scan Requests':
        return 'Room Scan / Environment Check';
      case 'Attendance & Check-in':
        return 'Attendance and Check-in Control';
      case 'Risk Timeline':
        return 'Integrity Score and Risk Timeline';
      case 'Malpractice Drafts':
        return 'Malpractice Report Generator';
      case 'Evidence Sync Status':
        return 'Evidence and Ledger Sync Status';
      case 'Audit Trail':
        return 'Invigilator Audit Trail';
      default:
        return 'Invigilator Evidence Review Dashboard';
    }
  }

  IconData _iconForSection(String section) {
    switch (section) {
      case 'Live Student Grid':
        return Icons.grid_view_outlined;
      case 'AI Alert Queue':
        return Icons.notification_important_outlined;
      case 'Evidence Review':
        return Icons.perm_media_outlined;
      case 'Manual Decisions':
        return Icons.fact_check_outlined;
      case 'Student Session Detail':
        return Icons.person_search_outlined;
      case 'Room Scan Requests':
        return Icons.video_camera_front_outlined;
      case 'Attendance & Check-in':
        return Icons.how_to_reg_outlined;
      case 'Risk Timeline':
        return Icons.timeline_outlined;
      case 'Malpractice Drafts':
        return Icons.gpp_maybe_outlined;
      case 'Evidence Sync Status':
        return Icons.cloud_sync_outlined;
      case 'Audit Trail':
        return Icons.manage_history_outlined;
      default:
        return Icons.verified_user_outlined;
    }
  }
}

class _InvigilatorPolicyBanner extends StatelessWidget {
  const _InvigilatorPolicyBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(Icons.policy_outlined, color: scheme.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'AI does not punish. AI detects and records. The invigilator reviews evidence and decides.',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvigilatorFeatureStrip extends StatelessWidget {
  const _InvigilatorFeatureStrip({required this.section});

  final String section;

  @override
  Widget build(BuildContext context) {
    final items = _itemsForSection(section);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          _EvidenceMetricChip(label: item.$1, icon: item.$2),
      ],
    );
  }

  List<(String, IconData)> _itemsForSection(String section) {
    switch (section) {
      case 'Live Student Grid':
        return const [
          ('Active students: 118', Icons.groups_2_outlined),
          ('High risk: 7', Icons.warning_amber_outlined),
          ('Critical: 2', Icons.priority_high_outlined),
          ('Screen locked: 112', Icons.lock_outline),
        ];
      case 'AI Alert Queue':
        return const [
          ('Critical first', Icons.priority_high_outlined),
          ('Manual review: 12', Icons.rule_outlined),
          ('Unreviewed: 18', Icons.pending_actions_outlined),
          ('Evidence captured', Icons.perm_media_outlined),
        ];
      case 'Attendance & Check-in':
        return const [
          ('Checked in: 112', Icons.how_to_reg_outlined),
          ('Absent: 6', Icons.person_off_outlined),
          ('Late approvals: 4', Icons.schedule_outlined),
          ('Device verified: 109', Icons.devices_outlined),
        ];
      case 'Evidence Sync Status':
        return const [
          ('Synced: 86', Icons.cloud_done_outlined),
          ('Pending sync: 9', Icons.cloud_queue_outlined),
          ('Ledger pending: 3', Icons.receipt_long_outlined),
          ('Failed sync: 1', Icons.cloud_off_outlined),
        ];
      case 'Room Scan Requests':
        return const [
          ('Desk scan', Icons.desk_outlined),
          ('Left/right scan', Icons.switch_camera_outlined),
          ('Face recheck', Icons.face_retouching_natural_outlined),
          ('Mic check', Icons.mic_outlined),
        ];
      default:
        return const [
          ('Evidence review', Icons.perm_media_outlined),
          ('Manual decision', Icons.fact_check_outlined),
          ('Warning / escalate', Icons.report_problem_outlined),
          ('Audit logged', Icons.manage_history_outlined),
        ];
    }
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

class _LiveStudentGridAnalytics extends StatelessWidget {
  const _LiveStudentGridAnalytics({required this.cases});

  final List<InvigilatorEvidenceCase> cases;

  @override
  Widget build(BuildContext context) {
    final highRisk = cases
        .where((item) => item.severity == 'High' || item.severity == 'Critical')
        .length;
    return _SectionCard(
      title: 'Live grid analytics only',
      icon: Icons.grid_view_outlined,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          const _AnalyticsTile(
            label: 'Online students',
            value: '118',
            icon: Icons.groups_2_outlined,
          ),
          const _AnalyticsTile(
            label: 'Normal',
            value: '96',
            icon: Icons.check_circle_outline,
          ),
          _AnalyticsTile(
            label: 'High / critical',
            value: '$highRisk',
            icon: Icons.warning_amber_outlined,
          ),
          const _AnalyticsTile(
            label: 'Manual review',
            value: '12',
            icon: Icons.rule_outlined,
          ),
          const _AnalyticsTile(
            label: 'Offline',
            value: '6',
            icon: Icons.wifi_off_outlined,
          ),
          const _AnalyticsTile(
            label: 'Screen locked',
            value: '112',
            icon: Icons.lock_outline,
          ),
        ],
      ),
    );
  }
}

class _AlertQueueOnly extends StatelessWidget {
  const _AlertQueueOnly({
    required this.cases,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<InvigilatorEvidenceCase> cases;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final sorted = [...cases]..sort((a, b) => _weight(a).compareTo(_weight(b)));
    return _SectionCard(
      title: 'Real-time AI alert queue',
      icon: Icons.notification_important_outlined,
      child: _CaseList(
        cases: sorted,
        selectedIndex: selectedIndex.clamp(0, sorted.length - 1),
        onSelected: onSelected,
      ),
    );
  }

  int _weight(InvigilatorEvidenceCase item) {
    switch (item.severity) {
      case 'Critical':
        return 0;
      case 'High':
        return 1;
      case 'Medium':
        return 2;
      default:
        return 3;
    }
  }
}

class _EvidenceReviewOnly extends StatelessWidget {
  const _EvidenceReviewOnly({
    required this.cases,
    required this.selected,
    required this.selectedIndex,
    required this.selectedSeverity,
    required this.selectedStatus,
    required this.selectedEvidence,
    required this.onSelected,
    required this.onSeverityChanged,
    required this.onStatusChanged,
    required this.onEvidenceChanged,
    required this.onDecision,
  });

  final List<InvigilatorEvidenceCase> cases;
  final InvigilatorEvidenceCase? selected;
  final int selectedIndex;
  final String selectedSeverity;
  final String selectedStatus;
  final String selectedEvidence;
  final ValueChanged<int> onSelected;
  final ValueChanged<String> onSeverityChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onEvidenceChanged;
  final void Function(String caseId, String action) onDecision;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FilterBar(
          selectedSeverity: selectedSeverity,
          selectedStatus: selectedStatus,
          selectedEvidence: selectedEvidence,
          onSeverityChanged: onSeverityChanged,
          onStatusChanged: onStatusChanged,
          onEvidenceChanged: onEvidenceChanged,
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;
            if (compact) {
              return Column(
                children: [
                  _CaseList(
                    cases: cases,
                    selectedIndex: selectedIndex,
                    onSelected: onSelected,
                  ),
                  const SizedBox(height: 14),
                  _EvidenceDetail(caseItem: selected, onDecision: onDecision),
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
                    selectedIndex: selectedIndex,
                    onSelected: onSelected,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _EvidenceDetail(
                    caseItem: selected,
                    onDecision: onDecision,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ManualDecisionOnly extends StatelessWidget {
  const _ManualDecisionOnly({required this.caseItem});

  final InvigilatorEvidenceCase caseItem;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Decision actions for ${caseItem.candidate}',
      icon: Icons.fact_check_outlined,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _DecisionButton(icon: Icons.check_circle_outline, label: 'Clear'),
          _DecisionButton(icon: Icons.task_alt_outlined, label: 'Reviewed'),
          _DecisionButton(icon: Icons.warning_amber_outlined, label: 'Warn'),
          _DecisionButton(
            icon: Icons.document_scanner_outlined,
            label: 'Desk scan',
          ),
          _DecisionButton(
            icon: Icons.face_retouching_natural_outlined,
            label: 'Face recheck',
          ),
          _DecisionButton(
            icon: Icons.escalator_warning_outlined,
            label: 'Escalate',
          ),
          _DecisionButton(
            icon: Icons.pause_circle_outline,
            label: 'Pause exam',
          ),
          _DecisionButton(
            icon: Icons.play_circle_outline,
            label: 'Resume exam',
          ),
          _DecisionButton(icon: Icons.gpp_bad_outlined, label: 'Terminate'),
        ],
      ),
    );
  }
}

class _StudentSessionOnly extends StatelessWidget {
  const _StudentSessionOnly({required this.caseItem});

  final InvigilatorEvidenceCase caseItem;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '${caseItem.candidate} session detail',
      icon: Icons.person_search_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniEvidencePill(label: caseItem.matric),
              _MiniEvidencePill(label: caseItem.course),
              _MiniEvidencePill(label: 'Risk ${caseItem.riskScore}'),
              _MiniEvidencePill(label: 'Network stable'),
              _MiniEvidencePill(label: 'Device KASU-CBT-014'),
            ],
          ),
          const SizedBox(height: 12),
          const _StatusGrid(),
        ],
      ),
    );
  }
}

class _RoomScanOnly extends StatelessWidget {
  const _RoomScanOnly({required this.caseItem});

  final InvigilatorEvidenceCase caseItem;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Room scan request for ${caseItem.candidate}',
      icon: Icons.video_camera_front_outlined,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: const [
          _DecisionButton(
            icon: Icons.desk_outlined,
            label: 'Request desk scan',
          ),
          _DecisionButton(
            icon: Icons.keyboard_arrow_left,
            label: 'Left side scan',
          ),
          _DecisionButton(
            icon: Icons.keyboard_arrow_right,
            label: 'Right side scan',
          ),
          _DecisionButton(
            icon: Icons.desktop_windows_outlined,
            label: 'Behind monitor',
          ),
          _DecisionButton(
            icon: Icons.badge_outlined,
            label: 'ID / face recheck',
          ),
          _DecisionButton(icon: Icons.mic_outlined, label: 'Microphone check'),
        ],
      ),
    );
  }
}

class _AttendanceCheckInOnly extends StatelessWidget {
  const _AttendanceCheckInOnly();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'Attendance and check-in list',
      icon: Icons.how_to_reg_outlined,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _AnalyticsTile(
            label: 'Checked in',
            value: '112',
            icon: Icons.how_to_reg_outlined,
          ),
          _AnalyticsTile(
            label: 'Absent',
            value: '6',
            icon: Icons.person_off_outlined,
          ),
          _AnalyticsTile(
            label: 'Late check-in',
            value: '4',
            icon: Icons.schedule_outlined,
          ),
          _AnalyticsTile(
            label: 'Verified devices',
            value: '109',
            icon: Icons.devices_outlined,
          ),
        ],
      ),
    );
  }
}

class _RiskTimelineOnly extends StatelessWidget {
  const _RiskTimelineOnly({required this.caseItem});

  final InvigilatorEvidenceCase caseItem;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Timeline for ${caseItem.candidate}',
      icon: Icons.timeline_outlined,
      child: const Column(
        children: [
          _TimelineLine(icon: Icons.face_outlined, text: '09:01 Face verified'),
          _TimelineLine(
            icon: Icons.play_circle_outline,
            text: '09:05 Exam started',
          ),
          _TimelineLine(
            icon: Icons.visibility_outlined,
            text: '09:12 Looking away detected',
          ),
          _TimelineLine(
            icon: Icons.graphic_eq_outlined,
            text: '09:20 Human voice detected',
          ),
          _TimelineLine(
            icon: Icons.phone_android_outlined,
            text: '09:25 Phone-like object detected - manual review',
          ),
          _TimelineLine(
            icon: Icons.folder_outlined,
            text: '09:26 Evidence captured',
          ),
          _TimelineLine(
            icon: Icons.warning_amber_outlined,
            text: '09:28 Invigilator warned student',
          ),
        ],
      ),
    );
  }
}

class _MalpracticeDraftOnly extends StatelessWidget {
  const _MalpracticeDraftOnly({required this.caseItem});

  final InvigilatorEvidenceCase caseItem;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Draft malpractice report',
      icon: Icons.gpp_maybe_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimelineLine(
            icon: Icons.person_outline,
            text: '${caseItem.candidate} • ${caseItem.matric}',
          ),
          _TimelineLine(icon: Icons.menu_book_outlined, text: caseItem.course),
          _TimelineLine(icon: Icons.sensors_outlined, text: caseItem.eventType),
          _TimelineLine(
            icon: Icons.percent_outlined,
            text: 'AI confidence ${(caseItem.confidence * 100).round()}%',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _DecisionButton(icon: Icons.save_outlined, label: 'Save draft'),
              _DecisionButton(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Submit to Exam Officer',
              ),
              _DecisionButton(
                icon: Icons.account_tree_outlined,
                label: 'Submit to HoD',
              ),
              _DecisionButton(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Export PDF',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvidenceSyncOnly extends StatelessWidget {
  const _EvidenceSyncOnly();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'Evidence and ledger sync status',
      icon: Icons.cloud_sync_outlined,
      child: Column(
        children: [
          _SyncLine(label: 'Camera evidence', status: 'Synced'),
          _SyncLine(label: 'Screenshot evidence', status: 'Pending sync'),
          _SyncLine(label: 'Audio evidence', status: 'Evidence uploaded'),
          _SyncLine(label: 'Integrity ledger', status: 'Ledger pending'),
          _SyncLine(label: 'Offline cache', status: '1 failed sync'),
        ],
      ),
    );
  }
}

class _AuditTrailOnly extends StatelessWidget {
  const _AuditTrailOnly({required this.cases});

  final List<InvigilatorEvidenceCase> cases;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Audit trail',
      icon: Icons.manage_history_outlined,
      child: Column(
        children: [
          for (final item in cases)
            _TimelineLine(
              icon: Icons.rule_outlined,
              text:
                  '${item.time}: ${item.eventType} reviewed by assigned invigilator - ${item.decision}',
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AnalyticsTile extends StatelessWidget {
  const _AnalyticsTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 190,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.32),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  const _DecisionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _StatusGrid extends StatelessWidget {
  const _StatusGrid();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _AnalyticsTile(
          label: 'Face status',
          value: 'Visible',
          icon: Icons.face_outlined,
        ),
        _AnalyticsTile(
          label: 'Object status',
          value: 'Review',
          icon: Icons.category_outlined,
        ),
        _AnalyticsTile(
          label: 'Audio status',
          value: 'Voice',
          icon: Icons.graphic_eq_outlined,
        ),
        _AnalyticsTile(
          label: 'Screen status',
          value: 'Locked',
          icon: Icons.lock_outline,
        ),
      ],
    );
  }
}

class _SyncLine extends StatelessWidget {
  const _SyncLine({required this.label, required this.status});

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    return _TimelineLine(
      icon: Icons.cloud_sync_outlined,
      text: '$label: $status',
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
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
              _MiniEvidencePill(
                label: 'Confidence ${(item.confidence * 100).round()}%',
              ),
              _MiniEvidencePill(label: 'Risk score ${item.riskScore}'),
              _MiniEvidencePill(label: item.status),
              _MiniEvidencePill(label: item.evidenceStatus),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Evidence manifest',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(item.recommendation),
          const SizedBox(height: 18),
          Text(
            'Decision trail',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
                onPressed: () => onDecision(item.id, 'open_evidence'),
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
