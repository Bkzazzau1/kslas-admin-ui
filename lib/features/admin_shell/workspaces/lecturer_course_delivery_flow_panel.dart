import 'package:flutter/material.dart';

class LecturerCourseDeliveryFlowPanel extends StatefulWidget {
  const LecturerCourseDeliveryFlowPanel({super.key, required this.section});

  final String section;

  @override
  State<LecturerCourseDeliveryFlowPanel> createState() =>
      _LecturerCourseDeliveryFlowPanelState();
}

class _LecturerCourseDeliveryFlowPanelState
    extends State<LecturerCourseDeliveryFlowPanel> {
  String _course = 'CSC 201';
  String _materialType = 'Lecture notes';
  String _videoStatus = 'Draft';
  String _examQuestionType = 'Mixed';
  bool _allowLateSubmission = true;
  bool _autoMarkObjective = true;
  bool _requiresModerator = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_upload_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.section,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save draft'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _FlowChip(
                  label: 'Assigned courses: 3',
                  icon: Icons.menu_book_outlined,
                ),
                _FlowChip(
                  label: 'Materials: 31/38',
                  icon: Icons.upload_file_outlined,
                ),
                _FlowChip(
                  label: 'Videos: 24/34',
                  icon: Icons.video_library_outlined,
                ),
                _FlowChip(
                  label: 'Live classes: 6',
                  icon: Icons.live_tv_outlined,
                ),
                _FlowChip(label: 'Exam drafts: 4', icon: Icons.quiz_outlined),
              ],
            ),
            const SizedBox(height: 16),
            _CourseSelector(
              course: _course,
              onCourseChanged: (value) => setState(() => _course = value),
            ),
            const SizedBox(height: 18),
            if (widget.section == 'Course Materials') _materialUploadFlow(),
            if (widget.section == 'Video Lectures') _videoUploadFlow(),
            if (widget.section == 'Live Classes') _liveSessionFlow(),
            if (widget.section == 'Assignments' ||
                widget.section == 'Quizzes & Tests')
              _assignmentFlow(),
            if (widget.section == 'Exam Questions') _examQuestionFlow(),
            if (widget.section == 'Profile') _settingsFlow(),
          ],
        ),
      ),
    );
  }

  Widget _materialUploadFlow() {
    return _FlowSection(
      title: 'Course material upload',
      icon: Icons.upload_file_outlined,
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.attach_file_outlined),
          label: const Text('Select file'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.cloud_upload_outlined),
          label: const Text('Submit for review'),
        ),
      ],
      children: [
        _ResponsiveFields(
          children: [
            _FieldShell(
              width: 260,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _materialType,
                items: const [
                  DropdownMenuItem(
                    value: 'Course outline',
                    child: Text('Course outline'),
                  ),
                  DropdownMenuItem(
                    value: 'Lecture notes',
                    child: Text('Lecture notes'),
                  ),
                  DropdownMenuItem(value: 'PDF file', child: Text('PDF file')),
                  DropdownMenuItem(
                    value: 'PowerPoint slides',
                    child: Text('PowerPoint slides'),
                  ),
                  DropdownMenuItem(
                    value: 'Reading materials',
                    child: Text('Reading materials'),
                  ),
                  DropdownMenuItem(
                    value: 'Practical guide',
                    child: Text('Practical guide'),
                  ),
                  DropdownMenuItem(
                    value: 'External link',
                    child: Text('External link'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _materialType = value ?? 'Lecture notes'),
                decoration: const InputDecoration(labelText: 'Material type'),
              ),
            ),
            const _FieldShell(
              width: 260,
              child: TextField(
                decoration: InputDecoration(labelText: 'Topic / title'),
              ),
            ),
            const _FieldShell(
              width: 180,
              child: TextField(decoration: InputDecoration(labelText: 'Week')),
            ),
            const _FieldShell(
              width: 260,
              child: TextField(
                decoration: InputDecoration(labelText: 'Version note'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const TextField(
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Material summary',
            prefixIcon: Icon(Icons.notes_outlined),
          ),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MiniPill(label: 'Draft'),
            _MiniPill(label: 'Submitted'),
            _MiniPill(label: 'Approved'),
            _MiniPill(label: 'Needs correction'),
            _MiniPill(label: 'Published'),
          ],
        ),
        const SizedBox(height: 14),
        const _ExistingItemList(
          title: 'Recent materials',
          items: [
            'Week 1 course outline - Published',
            'Week 2 lecture notes - Approved',
            'Database indexing slides - Needs correction',
          ],
        ),
      ],
    );
  }

  Widget _videoUploadFlow() {
    return _FlowSection(
      title: 'Video lecture upload',
      icon: Icons.video_library_outlined,
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.link_outlined),
          label: const Text('Add video link'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.cloud_upload_outlined),
          label: const Text('Upload video'),
        ),
      ],
      children: [
        _ResponsiveFields(
          children: [
            const _FieldShell(
              width: 300,
              child: TextField(
                decoration: InputDecoration(labelText: 'Video title'),
              ),
            ),
            const _FieldShell(
              width: 240,
              child: TextField(decoration: InputDecoration(labelText: 'Topic')),
            ),
            const _FieldShell(
              width: 160,
              child: TextField(decoration: InputDecoration(labelText: 'Week')),
            ),
            const _FieldShell(
              width: 180,
              child: TextField(
                decoration: InputDecoration(labelText: 'Duration'),
              ),
            ),
            _FieldShell(
              width: 220,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _videoStatus,
                items: const [
                  DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                  DropdownMenuItem(
                    value: 'Submitted',
                    child: Text('Submitted'),
                  ),
                  DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                  DropdownMenuItem(
                    value: 'Published',
                    child: Text('Published'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _videoStatus = value ?? 'Draft'),
                decoration: const InputDecoration(labelText: 'Upload status'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Video URL or storage path',
            prefixIcon: Icon(Icons.link_outlined),
          ),
        ),
        const SizedBox(height: 14),
        const _ExistingItemList(
          title: 'Video engagement samples',
          items: [
            'Week 1 Introduction - 780 views - 68% completion',
            'Week 2 Arrays and lists - 612 views - 71% completion',
            'Week 4 Trees practical - Draft',
          ],
        ),
      ],
    );
  }

  Widget _liveSessionFlow() {
    return _FlowSection(
      title: 'Live class session',
      icon: Icons.live_tv_outlined,
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.calendar_month_outlined),
          label: const Text('Schedule'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.play_circle_outline),
          label: const Text('Start class'),
        ),
      ],
      children: [
        const _ResponsiveFields(
          children: [
            _FieldShell(
              width: 300,
              child: TextField(
                decoration: InputDecoration(labelText: 'Live class topic'),
              ),
            ),
            _FieldShell(
              width: 220,
              child: TextField(decoration: InputDecoration(labelText: 'Date')),
            ),
            _FieldShell(
              width: 180,
              child: TextField(decoration: InputDecoration(labelText: 'Time')),
            ),
            _FieldShell(
              width: 260,
              child: TextField(
                decoration: InputDecoration(labelText: 'Attached material'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: _requiresModerator,
          onChanged: (value) => setState(() => _requiresModerator = value),
          title: const Text('Share recording after class'),
          contentPadding: EdgeInsets.zero,
        ),
        const _ExistingItemList(
          title: 'Upcoming live classes',
          items: [
            'Recursion clinic - Friday 10:00 AM - Attendance enabled',
            'Database normalisation Q&A - Monday 2:00 PM - Recording allowed',
          ],
        ),
      ],
    );
  }

  Widget _assignmentFlow() {
    final isQuiz = widget.section == 'Quizzes & Tests';
    return _FlowSection(
      title: isQuiz ? 'Quiz and test setup' : 'Assignment setup',
      icon: isQuiz ? Icons.quiz_outlined : Icons.assignment_ind_outlined,
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.rule_outlined),
          label: const Text('Rubric'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.publish_outlined),
          label: Text(isQuiz ? 'Publish quiz' : 'Publish assignment'),
        ),
      ],
      children: [
        _ResponsiveFields(
          children: [
            _FieldShell(
              width: 320,
              child: TextField(
                decoration: InputDecoration(
                  labelText: isQuiz ? 'Quiz title' : 'Assignment title',
                ),
              ),
            ),
            const _FieldShell(
              width: 180,
              child: TextField(decoration: InputDecoration(labelText: 'Marks')),
            ),
            const _FieldShell(
              width: 220,
              child: TextField(
                decoration: InputDecoration(labelText: 'Start date'),
              ),
            ),
            const _FieldShell(
              width: 220,
              child: TextField(
                decoration: InputDecoration(labelText: 'Deadline'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: isQuiz
                ? 'Question instructions'
                : 'Assignment instructions',
            prefixIcon: const Icon(Icons.notes_outlined),
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: _allowLateSubmission,
          onChanged: (value) =>
              setState(() => _allowLateSubmission = value ?? true),
          title: const Text('Allow late submission rule'),
          contentPadding: EdgeInsets.zero,
        ),
        if (isQuiz)
          CheckboxListTile(
            value: _autoMarkObjective,
            onChanged: (value) =>
                setState(() => _autoMarkObjective = value ?? true),
            title: const Text('Auto-mark objective questions'),
            contentPadding: EdgeInsets.zero,
          ),
        const _ExistingItemList(
          title: 'Assessment samples',
          items: [
            'Assignment 2 - Rubric complete - 100 marks',
            'Quiz 3 - Objective + short answer - Manual marking pending',
            'Practical guide task - Draft',
          ],
        ),
      ],
    );
  }

  Widget _examQuestionFlow() {
    return _FlowSection(
      title: 'Exam question submission',
      icon: Icons.rule_folder_outlined,
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_file_outlined),
          label: const Text('Upload marking guide'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.send_outlined),
          label: const Text('Submit for moderation'),
        ),
      ],
      children: [
        _ResponsiveFields(
          children: [
            _FieldShell(
              width: 260,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _examQuestionType,
                items: const [
                  DropdownMenuItem(
                    value: 'Objective',
                    child: Text('Objective'),
                  ),
                  DropdownMenuItem(value: 'Essay', child: Text('Essay')),
                  DropdownMenuItem(value: 'Mixed', child: Text('Mixed')),
                  DropdownMenuItem(
                    value: 'Practical',
                    child: Text('Practical'),
                  ),
                  DropdownMenuItem(
                    value: 'Oral/Live',
                    child: Text('Oral/Live'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _examQuestionType = value ?? 'Mixed'),
                decoration: const InputDecoration(labelText: 'Question type'),
              ),
            ),
            const _FieldShell(
              width: 220,
              child: TextField(
                decoration: InputDecoration(labelText: 'Exam window'),
              ),
            ),
            const _FieldShell(
              width: 180,
              child: TextField(
                decoration: InputDecoration(labelText: 'Total marks'),
              ),
            ),
            const _FieldShell(
              width: 260,
              child: TextField(
                decoration: InputDecoration(labelText: 'Moderator'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const TextField(
          minLines: 4,
          maxLines: 7,
          decoration: InputDecoration(
            labelText: 'Question draft / correction notes',
            prefixIcon: Icon(Icons.edit_note_outlined),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: _requiresModerator,
          onChanged: (value) => setState(() => _requiresModerator = value),
          title: const Text('Require moderator review before exam office'),
          contentPadding: EdgeInsets.zero,
        ),
        const _ExistingItemList(
          title: 'Question workflow',
          items: [
            'CSC 201 - Submitted to moderator',
            'CSC 305 - Returned for correction',
            'CSC 411 - Draft with marking guide pending',
          ],
        ),
      ],
    );
  }

  Widget _settingsFlow() {
    return _FlowSection(
      title: 'Lecturer course delivery settings',
      icon: Icons.settings_outlined,
      actions: [
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save settings'),
        ),
      ],
      children: [
        SwitchListTile(
          value: _allowLateSubmission,
          onChanged: (value) => setState(() => _allowLateSubmission = value),
          title: const Text('Default late submission rule'),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: _autoMarkObjective,
          onChanged: (value) => setState(() => _autoMarkObjective = value),
          title: const Text('Auto-mark objective questions by default'),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: _requiresModerator,
          onChanged: (value) => setState(() => _requiresModerator = value),
          title: const Text('Require moderation before final exam submission'),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _CourseSelector extends StatelessWidget {
  const _CourseSelector({required this.course, required this.onCourseChanged});

  final String course;
  final ValueChanged<String> onCourseChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: course,
        items: const [
          DropdownMenuItem(
            value: 'CSC 201',
            child: Text('CSC 201 - Data Structures'),
          ),
          DropdownMenuItem(
            value: 'CSC 305',
            child: Text('CSC 305 - Database Systems'),
          ),
          DropdownMenuItem(
            value: 'CSC 411',
            child: Text('CSC 411 - Artificial Intelligence'),
          ),
        ],
        onChanged: (value) => onCourseChanged(value ?? 'CSC 201'),
        decoration: const InputDecoration(labelText: 'Assigned course'),
      ),
    );
  }
}

class _FlowSection extends StatelessWidget {
  const _FlowSection({
    required this.title,
    required this.icon,
    required this.children,
    this.actions = const [],
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: scheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 10, runSpacing: 10, children: children);
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: child);
  }
}

class _ExistingItemList extends StatelessWidget {
  const _ExistingItemList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}

class _FlowChip extends StatelessWidget {
  const _FlowChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
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
