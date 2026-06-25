import 'package:flutter/material.dart';

class ReviewEvidencePanel extends StatelessWidget {
  const ReviewEvidencePanel({super.key});

  static final List<_ReviewCase> _cases = <_ReviewCase>[
    _ReviewCase(
      studentName: 'Aisha Musa',
      matricNumber: 'KASU/DLC/24/0192',
      course: 'GST 102 - Use of English II',
      attentionLevel: 'High attention required',
      status: 'Awaiting exam officer review',
      reviewSummary:
          'Camera and room sound records are available for review. The student remained connected and submitted normally.',
      evidenceFiles: const <_EvidenceFile>[
        _EvidenceFile(
          title: 'Camera review record',
          type: 'Camera evidence',
          source: 'local_camera_record',
          status: 'Available',
          detail: 'Recent frame saved around the review event.',
        ),
        _EvidenceFile(
          title: 'Room sound record',
          type: 'Sound evidence',
          source: 'local_audio_record',
          status: 'Available',
          detail: 'Short sound clip saved around the review event.',
        ),
      ],
      timeline: const <String>[
        'Another person may be visible in the camera view.',
        'Possible external voice noticed during the exam.',
        'Evidence records saved for review.',
      ],
    ),
    _ReviewCase(
      studentName: 'Ibrahim Sani',
      matricNumber: 'KASU/DLC/24/0237',
      course: 'CSC 204 - Data Structures',
      attentionLevel: 'Medium attention required',
      status: 'Invigilator note added',
      reviewSummary:
          'Screen activity and camera records need a quick human check before the case is cleared.',
      evidenceFiles: const <_EvidenceFile>[
        _EvidenceFile(
          title: 'Camera review record',
          type: 'Camera evidence',
          source: 'local_camera_record',
          status: 'Available',
          detail: 'Lighting and face visibility record saved.',
        ),
        _EvidenceFile(
          title: 'Attempt recovery record',
          type: 'Autosave recovery',
          source: 'recovered_from',
          status: 'Primary record used',
          detail: 'Checksum verified during attempt recovery.',
        ),
      ],
      timeline: const <String>[
        'Student left the exam screen briefly.',
        'Camera view required attention.',
        'Attempt autosave checksum verified.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Evidence',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Evidence files and activity records for sessions that may need human review.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _SummaryCard(
              title: 'Cases waiting',
              value: '12',
              icon: Icons.fact_check_outlined,
            ),
            _SummaryCard(
              title: 'Evidence files',
              value: '36',
              icon: Icons.folder_copy_outlined,
            ),
            _SummaryCard(
              title: 'Cleared today',
              value: '8',
              icon: Icons.verified_outlined,
            ),
            _SummaryCard(
              title: 'Sent to HoD',
              value: '3',
              icon: Icons.account_tree_outlined,
            ),
          ],
        ),
        const SizedBox(height: 18),
        for (final item in _cases) ...[
          _ReviewCaseCard(item: item),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(title),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCaseCard extends StatelessWidget {
  const _ReviewCaseCard({required this.item});

  final _ReviewCase item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  item.studentName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Chip(label: Text(item.attentionLevel)),
                Chip(
                  avatar: const Icon(Icons.hourglass_bottom_outlined, size: 18),
                  label: Text(item.status),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${item.matricNumber} • ${item.course}'),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(item.reviewSummary),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final evidence = _EvidenceList(files: item.evidenceFiles);
                final timeline = _TimelineList(items: item.timeline);
                if (compact) {
                  return Column(
                    children: [
                      evidence,
                      const SizedBox(height: 14),
                      timeline,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: evidence),
                    const SizedBox(width: 14),
                    Expanded(child: timeline),
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

class _EvidenceList extends StatelessWidget {
  const _EvidenceList({required this.files});

  final List<_EvidenceFile> files;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Evidence Files',
      icon: Icons.folder_copy_outlined,
      children: [
        for (final file in files)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.insert_drive_file_outlined),
            title: Text(file.title),
            subtitle: Text('${file.type} • ${file.detail}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  file.status,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  file.source,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Activity Timeline',
      icon: Icons.timeline_outlined,
      children: [
        for (var index = 0; index < items.length; index++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(items[index]),
          ),
      ],
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _ReviewCase {
  const _ReviewCase({
    required this.studentName,
    required this.matricNumber,
    required this.course,
    required this.attentionLevel,
    required this.status,
    required this.reviewSummary,
    required this.evidenceFiles,
    required this.timeline,
  });

  final String studentName;
  final String matricNumber;
  final String course;
  final String attentionLevel;
  final String status;
  final String reviewSummary;
  final List<_EvidenceFile> evidenceFiles;
  final List<String> timeline;
}

class _EvidenceFile {
  const _EvidenceFile({
    required this.title,
    required this.type,
    required this.source,
    required this.status,
    required this.detail,
  });

  final String title;
  final String type;
  final String source;
  final String status;
  final String detail;
}
