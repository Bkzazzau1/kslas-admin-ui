import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../data/lecturer_question_api.dart';

class LecturerQuestionLivePanel extends StatefulWidget {
  const LecturerQuestionLivePanel({super.key});

  @override
  State<LecturerQuestionLivePanel> createState() => _LecturerQuestionLivePanelState();
}

class _LecturerQuestionLivePanelState extends State<LecturerQuestionLivePanel> {
  final LecturerQuestionApi _api = LecturerQuestionApi();
  final _title = TextEditingController(text: 'Full Question Paper');
  final _description = TextEditingController(text: 'Lecturer submitted question paper for review.');
  final _instructions = TextEditingController(text: 'Answer all questions.');
  final _duration = TextEditingController(text: '120');
  final _examOfficer = TextEditingController(text: '4');
  final _batchCount = TextEditingController(text: '20');
  final _batchMarks = TextEditingController(text: '1');

  bool _loading = true;
  bool _saving = false;
  bool _reviewMode = false;
  bool _autoMark = true;
  bool _uploadingQuestions = false;
  bool _uploadingAnswerScript = false;
  String? _error;
  String? _notice;
  String _selectedFormat = 'single_choice';
  String _questionFileName = '';
  String _questionFileUrl = '';
  String _answerScriptName = '';
  String _answerScriptUrl = '';
  int? _selectedCourseId;
  List<QuestionCourseOption> _courses = const [];
  List<QuestionPaperItem> _papers = const [];
  final List<_QuestionDraft> _questions = [
    _QuestionDraft.single(
      id: 'q1',
      topic: 'Stacks and queues',
      marks: '2',
      prompt: 'Which data structure follows last-in-first-out order?',
      options: [
        _OptionDraft('A', 'Queue'),
        _OptionDraft('B', 'Stack', true),
        _OptionDraft('C', 'Array'),
        _OptionDraft('D', 'Tree'),
      ],
    ),
    _QuestionDraft.essay(
      id: 'q2',
      topic: 'Binary search trees',
      marks: '20',
      prompt: 'Explain insertion and search operations in a binary search tree.',
      answer: 'Award marks for search path, insertion point, and time complexity explanation.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _api.close();
    _title.dispose();
    _description.dispose();
    _instructions.dispose();
    _duration.dispose();
    _examOfficer.dispose();
    _batchCount.dispose();
    _batchMarks.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final courses = await _api.fetchCourses();
      final papers = await _api.fetchQuestionPapers();
      if (!mounted) return;
      setState(() {
        _courses = courses;
        _papers = papers;
        _selectedCourseId ??= courses.isNotEmpty ? courses.first.id : null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  int get _totalMarks => _questions.fold(0, (sum, q) => sum + (int.tryParse(q.marks.trim()) ?? 0));

  List<String> _validate() {
    final issues = <String>[];
    if (_selectedCourseId == null || _selectedCourseId == 0) issues.add('Select a course.');
    if (_title.text.trim().isEmpty) issues.add('Enter the exam title.');
    if ((int.tryParse(_duration.text.trim()) ?? 0) <= 0) issues.add('Enter a valid duration.');
    if (_questions.isEmpty) issues.add('Add at least one question.');
    for (var i = 0; i < _questions.length; i++) {
      issues.addAll(_questions[i].requiredIssues(i + 1));
    }
    return issues;
  }

  void _openReview() {
    final issues = _validate();
    if (issues.isNotEmpty) {
      _showError(issues.first);
      return;
    }
    setState(() => _reviewMode = true);
  }

  Future<void> _submit() async {
    final issues = _validate();
    if (issues.isNotEmpty) {
      _showError(issues.first);
      return;
    }
    final lecturerId = int.tryParse(AuthSession.instance.session?.staffId ?? '') ?? 0;
    final examOfficerId = int.tryParse(_examOfficer.text.trim()) ?? 0;
    if (lecturerId == 0) {
      _showError('Lecturer profile was not found. Please login again.');
      return;
    }
    if (examOfficerId == 0) {
      _showError('Enter the reviewer or Exam Officer ID.');
      return;
    }

    setState(() {
      _saving = true;
      _notice = null;
    });
    try {
      final created = await _api.submitQuestionPaper(
        courseId: _selectedCourseId!,
        lecturerId: lecturerId,
        examOfficerId: examOfficerId,
        title: _title.text.trim().isEmpty ? 'Untitled question paper' : _title.text.trim(),
        description: _description.text.trim(),
        instructions: _instructions.text.trim(),
        durationMinutes: int.tryParse(_duration.text.trim()) ?? 0,
        questionPayload: _payload(),
      );
      if (!mounted) return;
      setState(() {
        _papers = [created, ..._papers];
        _saving = false;
        _reviewMode = false;
        _notice = 'Question paper submitted for review.';
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Question paper submitted for review.')));
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError(error.toString());
    }
  }

  Map<String, dynamic> _payload() {
    return {
      'version': 2,
      'source': 'folded_lecturer_question_builder',
      'auto_mark_objective': _autoMark,
      'allowed_question_types': const [
        'single_choice',
        'multiple_choice',
        'fill_blank',
        'essay',
        'drag_drop',
        'image_question',
        'file_upload',
      ],
      'total_marks': _totalMarks,
      'question_upload': {
        if (_questionFileName.isNotEmpty) 'file_name': _questionFileName,
        if (_questionFileUrl.isNotEmpty) 'file_url': _questionFileUrl,
      },
      'answer_script': {
        if (_answerScriptName.isNotEmpty) 'file_name': _answerScriptName,
        if (_answerScriptUrl.isNotEmpty) 'file_url': _answerScriptUrl,
      },
      'questions': [for (var i = 0; i < _questions.length; i++) _questions[i].toPayload(i + 1)],
    };
  }

  void _addQuestion(String type, {int count = 1}) {
    setState(() {
      _selectedFormat = type;
      for (var i = 0; i < count; i++) {
        _questions.add(_QuestionDraft.forType('q${_questions.length + 1}', type, _batchMarks.text.trim().isEmpty ? '1' : _batchMarks.text.trim()));
      }
    });
  }

  void _addSet() {
    final count = int.tryParse(_batchCount.text.trim()) ?? 0;
    final marks = int.tryParse(_batchMarks.text.trim()) ?? 0;
    if (count <= 0) {
      _showError('Enter the number of questions to create.');
      return;
    }
    if (marks <= 0) {
      _showError('Enter marks for each question.');
      return;
    }
    _addQuestion(_selectedFormat, count: count);
  }

  void _duplicate(_QuestionDraft item) {
    setState(() => _questions.add(item.copy('q${_questions.length + 1}')));
  }

  void _remove(_QuestionDraft item) {
    setState(() => _questions.remove(item));
  }

  Future<void> _uploadQuestions() async {
    await _pickAndUpload(
      category: 'question_paper_source',
      setBusy: (v) => _uploadingQuestions = v,
      onDone: (name, url) {
        _questionFileName = name;
        _questionFileUrl = url;
      },
    );
  }

  Future<void> _uploadAnswerScript() async {
    await _pickAndUpload(
      category: 'answer_script',
      setBusy: (v) => _uploadingAnswerScript = v,
      onDone: (name, url) {
        _answerScriptName = name;
        _answerScriptUrl = url;
      },
    );
  }

  Future<void> _pickAndUpload({
    required String category,
    required ValueChanged<bool> setBusy,
    required void Function(String name, String url) onDone,
  }) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'xlsx', 'docx', 'pdf'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      _showError('Could not read selected file.');
      return;
    }
    setState(() => setBusy(true));
    try {
      final url = await _api.uploadFile(bytes: bytes, fileName: file.name, category: category);
      if (!mounted) return;
      setState(() {
        setBusy(false);
        onDone(file.name, url);
        _notice = '${file.name} uploaded.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => setBusy(false));
      _showError(error.toString());
    }
  }

  void _showError(String message) {
    setState(() => _notice = null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: _loading
            ? const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    reviewMode: _reviewMode,
                    saving: _saving,
                    onBack: () => setState(() => _reviewMode = false),
                    onReview: _openReview,
                    onSubmit: _submit,
                  ),
                  if (_notice != null) ...[const SizedBox(height: 12), _NoticeBox(message: _notice!)],
                  if (_error != null) ...[const SizedBox(height: 12), _ErrorBox(message: _error!, onRetry: _load)],
                  const SizedBox(height: 16),
                  if (_reviewMode)
                    _ReviewPage(
                      title: _title.text,
                      course: _selectedCourseLabel,
                      instructions: _instructions.text,
                      duration: _duration.text,
                      totalMarks: _totalMarks,
                      questions: _questions,
                      saving: _saving,
                      onBack: () => setState(() => _reviewMode = false),
                      onSubmit: _submit,
                    )
                  else ...[
                    _PaperDetails(
                      courses: _courses,
                      selectedCourseId: _selectedCourseId,
                      title: _title,
                      description: _description,
                      instructions: _instructions,
                      duration: _duration,
                      examOfficer: _examOfficer,
                      autoMark: _autoMark,
                      onCourseChanged: (v) => setState(() => _selectedCourseId = v),
                      onAutoMarkChanged: (v) => setState(() => _autoMark = v),
                    ),
                    const SizedBox(height: 14),
                    _SummaryBar(totalMarks: _totalMarks, questions: _questions),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 1050;
                        final formats = _FormatAccordion(
                          selected: _selectedFormat,
                          batchCount: _batchCount,
                          batchMarks: _batchMarks,
                          questionFileName: _questionFileName,
                          answerScriptName: _answerScriptName,
                          uploadingQuestions: _uploadingQuestions,
                          uploadingAnswerScript: _uploadingAnswerScript,
                          onSelect: (v) => setState(() => _selectedFormat = v),
                          onAddOne: _addQuestion,
                          onAddSet: _addSet,
                          onUploadQuestions: _uploadQuestions,
                          onUploadAnswerScript: _uploadAnswerScript,
                        );
                        final list = _QuestionList(
                          questions: _questions,
                          onChanged: () => setState(() {}),
                          onDuplicate: _duplicate,
                          onRemove: _remove,
                        );
                        if (!wide) return Column(children: [formats, const SizedBox(height: 14), list]);
                        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 390, child: formats), const SizedBox(width: 14), Expanded(child: list)]);
                      },
                    ),
                    const SizedBox(height: 14),
                    _ReviewCallout(issues: _validate(), onReview: _openReview),
                    const SizedBox(height: 14),
                    _SubmittedPapersPanel(items: _papers),
                  ],
                ],
              ),
      ),
    );
  }

  String get _selectedCourseLabel {
    final found = _courses.where((c) => c.id == _selectedCourseId);
    return found.isEmpty ? 'Course not selected' : found.first.label;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.reviewMode, required this.saving, required this.onBack, required this.onReview, required this.onSubmit});
  final bool reviewMode;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onReview;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(reviewMode ? Icons.preview_outlined : Icons.rule_folder_outlined, color: scheme.primary), const SizedBox(width: 10), Expanded(child: Text(reviewMode ? 'Review Question Paper' : 'Exam Question Paper', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)))]),
            const SizedBox(height: 8),
            Text(reviewMode ? 'Review the paper before sending it forward.' : 'Open one question format at a time. Only the selected format fields will appear.', style: TextStyle(color: scheme.onSurfaceVariant)),
          ]),
        ),
        Wrap(spacing: 8, runSpacing: 8, children: [
          if (reviewMode) OutlinedButton.icon(onPressed: saving ? null : onBack, icon: const Icon(Icons.arrow_back_outlined), label: const Text('Back to edit')),
          if (!reviewMode) FilledButton.icon(onPressed: saving ? null : onReview, icon: const Icon(Icons.preview_outlined), label: const Text('Review paper')),
          if (reviewMode) FilledButton.icon(onPressed: saving ? null : onSubmit, icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_outlined), label: const Text('Submit for review')),
        ]),
      ],
    );
  }
}

class _PaperDetails extends StatelessWidget {
  const _PaperDetails({required this.courses, required this.selectedCourseId, required this.title, required this.description, required this.instructions, required this.duration, required this.examOfficer, required this.autoMark, required this.onCourseChanged, required this.onAutoMarkChanged});
  final List<QuestionCourseOption> courses;
  final int? selectedCourseId;
  final TextEditingController title;
  final TextEditingController description;
  final TextEditingController instructions;
  final TextEditingController duration;
  final TextEditingController examOfficer;
  final bool autoMark;
  final ValueChanged<int?> onCourseChanged;
  final ValueChanged<bool> onAutoMarkChanged;

  @override
  Widget build(BuildContext context) {
    return _Panel(title: 'Paper setup', icon: Icons.description_outlined, child: Column(children: [
      Wrap(spacing: 10, runSpacing: 10, children: [
        SizedBox(width: 330, child: DropdownButtonFormField<int>(isExpanded: true, initialValue: selectedCourseId, items: [for (final course in courses) DropdownMenuItem(value: course.id, child: Text(course.label))], onChanged: onCourseChanged, decoration: const InputDecoration(labelText: 'Course'))),
        SizedBox(width: 340, child: TextField(controller: title, decoration: const InputDecoration(labelText: 'Exam title'))),
        SizedBox(width: 160, child: TextField(controller: duration, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration mins'))),
        SizedBox(width: 210, child: TextField(controller: examOfficer, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reviewer / Exam Officer ID'))),
      ]),
      const SizedBox(height: 10),
      TextField(controller: description, minLines: 2, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.notes_outlined))),
      const SizedBox(height: 10),
      TextField(controller: instructions, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Student instructions', prefixIcon: Icon(Icons.rule_outlined))),
      const SizedBox(height: 6),
      SwitchListTile(value: autoMark, onChanged: onAutoMarkChanged, contentPadding: EdgeInsets.zero, title: const Text('Auto-mark single answer, multiple answer, and fill-in-the-blank questions')),
    ]));
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.totalMarks, required this.questions});
  final int totalMarks;
  final List<_QuestionDraft> questions;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final q in questions) counts[q.type] = (counts[q.type] ?? 0) + 1;
    return _Panel(title: 'Paper summary', icon: Icons.analytics_outlined, child: Wrap(spacing: 10, runSpacing: 10, children: [
      _Metric(label: 'Questions', value: '${questions.length}', icon: Icons.format_list_numbered_outlined),
      _Metric(label: 'Total marks', value: '$totalMarks', icon: Icons.scoreboard_outlined),
      for (final entry in counts.entries) _Metric(label: _format(entry.key).title, value: '${entry.value}', icon: _format(entry.key).icon),
    ]));
  }
}

class _FormatAccordion extends StatelessWidget {
  const _FormatAccordion({required this.selected, required this.batchCount, required this.batchMarks, required this.questionFileName, required this.answerScriptName, required this.uploadingQuestions, required this.uploadingAnswerScript, required this.onSelect, required this.onAddOne, required this.onAddSet, required this.onUploadQuestions, required this.onUploadAnswerScript});
  final String selected;
  final TextEditingController batchCount;
  final TextEditingController batchMarks;
  final String questionFileName;
  final String answerScriptName;
  final bool uploadingQuestions;
  final bool uploadingAnswerScript;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onAddOne;
  final VoidCallback onAddSet;
  final VoidCallback onUploadQuestions;
  final VoidCallback onUploadAnswerScript;

  @override
  Widget build(BuildContext context) {
    return _Panel(title: 'Question formats', icon: Icons.unfold_more_outlined, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('All formats stay folded. Open one format to add questions for that format.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 12),
      for (final format in _formats) _FormatTile(format: format, selected: selected == format.type, batchCount: batchCount, batchMarks: batchMarks, onOpen: () => onSelect(format.type), onAddOne: () => onAddOne(format.type), onAddSet: onAddSet),
      const SizedBox(height: 10),
      _UploadButton(title: 'Upload existing question file', fileName: questionFileName, busy: uploadingQuestions, icon: Icons.upload_file_outlined, onPressed: onUploadQuestions),
      const SizedBox(height: 8),
      _UploadButton(title: 'Upload marking guide / answer script', fileName: answerScriptName, busy: uploadingAnswerScript, icon: Icons.fact_check_outlined, onPressed: onUploadAnswerScript),
    ]));
  }
}

class _FormatTile extends StatelessWidget {
  const _FormatTile({required this.format, required this.selected, required this.batchCount, required this.batchMarks, required this.onOpen, required this.onAddOne, required this.onAddSet});
  final _Format format;
  final bool selected;
  final TextEditingController batchCount;
  final TextEditingController batchMarks;
  final VoidCallback onOpen;
  final VoidCallback onAddOne;
  final VoidCallback onAddSet;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant)),
      child: ExpansionTile(
        initiallyExpanded: selected,
        onExpansionChanged: (expanded) { if (expanded) onOpen(); },
        leading: Icon(format.icon, color: selected ? scheme.primary : null),
        title: Text(format.title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(format.subtitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(alignment: Alignment.centerLeft, child: Text(format.detail, style: TextStyle(color: scheme.onSurfaceVariant))),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            SizedBox(width: 120, child: TextField(controller: batchCount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'No. to add'))),
            SizedBox(width: 120, child: TextField(controller: batchMarks, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Mark each'))),
            FilledButton.icon(onPressed: onAddOne, icon: const Icon(Icons.add_outlined), label: const Text('Add one')),
            OutlinedButton.icon(onPressed: onAddSet, icon: const Icon(Icons.playlist_add_outlined), label: const Text('Add set')),
          ]),
        ],
      ),
    );
  }
}

class _QuestionList extends StatelessWidget {
  const _QuestionList({required this.questions, required this.onChanged, required this.onDuplicate, required this.onRemove});
  final List<_QuestionDraft> questions;
  final VoidCallback onChanged;
  final ValueChanged<_QuestionDraft> onDuplicate;
  final ValueChanged<_QuestionDraft> onRemove;

  @override
  Widget build(BuildContext context) {
    return _Panel(title: 'Questions added', icon: Icons.fact_check_outlined, child: questions.isEmpty ? const Text('No question added yet.') : Column(children: [
      for (var i = 0; i < questions.length; i++) _QuestionCard(number: i + 1, item: questions[i], onChanged: onChanged, onDuplicate: () => onDuplicate(questions[i]), onRemove: () => onRemove(questions[i])),
    ]));
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.number, required this.item, required this.onChanged, required this.onDuplicate, required this.onRemove});
  final int number;
  final _QuestionDraft item;
  final VoidCallback onChanged;
  final VoidCallback onDuplicate;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final issues = item.requiredIssues(number);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.24), borderRadius: BorderRadius.circular(16), border: Border.all(color: issues.isEmpty ? scheme.outlineVariant : scheme.error)),
      child: ExpansionTile(
        initiallyExpanded: number == 1,
        leading: CircleAvatar(backgroundColor: scheme.primaryContainer, foregroundColor: scheme.onPrimaryContainer, child: Text('$number')),
        title: Text(item.prompt.trim().isEmpty ? 'New ${_format(item.type).title}' : item.prompt.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Wrap(spacing: 6, runSpacing: 4, children: [_Pill(_format(item.type).title), _Pill('${item.marks} marks'), if (item.topic.trim().isNotEmpty) _Pill(item.topic), _Pill(issues.isEmpty ? 'Complete' : '${issues.length} to check')]),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        children: [
          Wrap(spacing: 10, runSpacing: 10, children: [
            SizedBox(width: 230, child: DropdownButtonFormField<String>(initialValue: item.type, items: [for (final f in _formats) DropdownMenuItem(value: f.type, child: Text(f.title))], onChanged: (v) { item.setType(v ?? item.type); onChanged(); }, decoration: const InputDecoration(labelText: 'Format'))),
            SizedBox(width: 120, child: TextFormField(initialValue: item.marks, keyboardType: TextInputType.number, onChanged: (v) { item.marks = v; onChanged(); }, decoration: const InputDecoration(labelText: 'Marks'))),
            SizedBox(width: 250, child: TextFormField(initialValue: item.topic, onChanged: (v) { item.topic = v; onChanged(); }, decoration: const InputDecoration(labelText: 'Topic / CLO'))),
          ]),
          const SizedBox(height: 10),
          TextFormField(initialValue: item.prompt, minLines: 2, maxLines: 5, onChanged: (v) { item.prompt = v; onChanged(); }, decoration: const InputDecoration(labelText: 'Question text', prefixIcon: Icon(Icons.help_outline))),
          const SizedBox(height: 10),
          _FieldsForFormat(item: item, onChanged: onChanged),
          if (issues.isNotEmpty) ...[const SizedBox(height: 10), _IssueBox(issues: issues)],
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            OutlinedButton.icon(onPressed: onDuplicate, icon: const Icon(Icons.copy_outlined), label: const Text('Duplicate')),
            TextButton.icon(onPressed: onRemove, icon: const Icon(Icons.delete_outline), label: const Text('Remove')),
          ]),
        ],
      ),
    );
  }
}

class _FieldsForFormat extends StatelessWidget {
  const _FieldsForFormat({required this.item, required this.onChanged});
  final _QuestionDraft item;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    if (item.type == 'single_choice' || item.type == 'multiple_choice') {
      final multiple = item.type == 'multiple_choice';
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(multiple ? 'Tick every correct answer.' : 'Select one correct answer.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        for (var i = 0; i < item.options.length; i++) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 48, child: multiple ? Checkbox(value: item.options[i].correct, onChanged: (v) { item.options[i] = item.options[i].copy(correct: v ?? false); item.syncAnswer(); onChanged(); }) : Radio<String>(value: item.options[i].keyName, groupValue: item.singleCorrect, onChanged: (v) { item.setSingleCorrect(v ?? item.options[i].keyName); onChanged(); })),
          SizedBox(width: 40, child: Padding(padding: const EdgeInsets.only(top: 14), child: Text(item.options[i].keyName, style: const TextStyle(fontWeight: FontWeight.w900)))),
          Expanded(child: TextFormField(initialValue: item.options[i].text, onChanged: (v) { item.options[i] = item.options[i].copy(text: v); onChanged(); }, decoration: const InputDecoration(labelText: 'Answer option'))),
        ])),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(onPressed: () { item.addOption(); onChanged(); }, icon: const Icon(Icons.add_outlined), label: const Text('Add option')),
          if (multiple) SizedBox(width: 260, child: SwitchListTile(value: item.partialMarking, onChanged: (v) { item.partialMarking = v; onChanged(); }, dense: true, contentPadding: EdgeInsets.zero, title: const Text('Allow partial marking'))),
        ]),
      ]);
    }
    if (item.type == 'essay') {
      return Column(children: [
        TextFormField(initialValue: item.answer, minLines: 3, maxLines: 7, onChanged: (v) { item.answer = v; onChanged(); }, decoration: const InputDecoration(labelText: 'Marking guide / expected answer', prefixIcon: Icon(Icons.fact_check_outlined))),
        const SizedBox(height: 10),
        TextFormField(initialValue: item.rubric, minLines: 2, maxLines: 5, onChanged: (v) { item.rubric = v; onChanged(); }, decoration: const InputDecoration(labelText: 'Rubric points', prefixIcon: Icon(Icons.grading_outlined))),
      ]);
    }
    if (item.type == 'drag_drop') {
      return TextFormField(initialValue: item.answer, minLines: 2, maxLines: 5, onChanged: (v) { item.answer = v; onChanged(); }, decoration: const InputDecoration(labelText: 'Correct matching pairs', helperText: 'Example: CPU=Processor; RAM=Memory', prefixIcon: Icon(Icons.drag_indicator_outlined)));
    }
    if (item.type == 'image_question' || item.type == 'file_upload') {
      return TextFormField(initialValue: item.answer, minLines: 2, maxLines: 6, onChanged: (v) { item.answer = v; onChanged(); }, decoration: InputDecoration(labelText: item.type == 'image_question' ? 'Expected picture answer / marking guide' : 'Expected file/practical marking guide', prefixIcon: const Icon(Icons.fact_check_outlined)));
    }
    return TextFormField(initialValue: item.answer, minLines: 2, maxLines: 5, onChanged: (v) { item.answer = v; onChanged(); }, decoration: const InputDecoration(labelText: 'Correct answer / accepted answers', helperText: 'Use semicolon or new line for alternatives.', prefixIcon: Icon(Icons.fact_check_outlined)));
  }
}

class _ReviewPage extends StatelessWidget {
  const _ReviewPage({required this.title, required this.course, required this.instructions, required this.duration, required this.totalMarks, required this.questions, required this.saving, required this.onBack, required this.onSubmit});
  final String title;
  final String course;
  final String instructions;
  final String duration;
  final int totalMarks;
  final List<_QuestionDraft> questions;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Panel(title: 'Final review before submission', icon: Icons.preview_outlined, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 10, runSpacing: 10, children: [
          _Metric(label: 'Questions', value: '${questions.length}', icon: Icons.format_list_numbered_outlined),
          _Metric(label: 'Total marks', value: '$totalMarks', icon: Icons.scoreboard_outlined),
          _Metric(label: 'Duration', value: '$duration mins', icon: Icons.timer_outlined),
        ]),
        const SizedBox(height: 12),
        _Line(label: 'Course', value: course),
        _Line(label: 'Title', value: title),
        _Line(label: 'Instructions', value: instructions),
      ])),
      const SizedBox(height: 14),
      _Panel(title: 'Question preview', icon: Icons.list_alt_outlined, child: Column(children: [
        for (var i = 0; i < questions.length; i++) _ReviewTile(number: i + 1, item: questions[i]),
      ])),
      const SizedBox(height: 14),
      Wrap(spacing: 8, runSpacing: 8, children: [
        OutlinedButton.icon(onPressed: saving ? null : onBack, icon: const Icon(Icons.arrow_back_outlined), label: const Text('Back to edit')),
        FilledButton.icon(onPressed: saving ? null : onSubmit, icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_outlined), label: const Text('Submit for review')),
      ]),
    ]);
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.number, required this.item});
  final int number;
  final _QuestionDraft item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: scheme.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 6, runSpacing: 4, children: [_Pill('Question $number'), _Pill(_format(item.type).title), _Pill('${item.marks} marks')]),
        const SizedBox(height: 8),
        Text(item.prompt, style: const TextStyle(fontWeight: FontWeight.w800)),
        if (item.needsOptions) ...[const SizedBox(height: 8), for (final option in item.validOptions) Text('${option.keyName}. ${option.text}${option.correct ? '  ✓' : ''}')],
        if (!item.needsOptions && item.answer.trim().isNotEmpty) ...[const SizedBox(height: 8), Text('Answer guide: ${item.answer}', style: TextStyle(color: scheme.onSurfaceVariant))],
      ]),
    );
  }
}

class _ReviewCallout extends StatelessWidget {
  const _ReviewCallout({required this.issues, required this.onReview});
  final List<String> issues;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(16)), child: Wrap(spacing: 12, runSpacing: 10, alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, children: [
      Text(issues.isEmpty ? 'Ready for lecturer review before submission.' : '${issues.length} item(s) must be fixed before review.', style: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w800)),
      FilledButton.icon(onPressed: issues.isEmpty ? onReview : null, icon: const Icon(Icons.preview_outlined), label: const Text('Review paper')),
    ]));
  }
}

class _IssueBox extends StatelessWidget {
  const _IssueBox({required this.issues});
  final List<String> issues;

  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Before review', style: TextStyle(fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      for (final issue in issues) Text('• $issue'),
    ]));
  }
}

class _SubmittedPapersPanel extends StatelessWidget {
  const _SubmittedPapersPanel({required this.items});
  final List<QuestionPaperItem> items;

  @override
  Widget build(BuildContext context) {
    final recent = items.take(6).toList();
    return _Panel(title: 'Recent question papers', icon: Icons.outbox_outlined, child: recent.isEmpty ? const Text('No question papers submitted yet.') : Column(children: [
      for (final item in recent) ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.description_outlined), title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${item.courseLabel} • ${item.questionCount} questions • ${item.totalMarks} marks'), trailing: _Badge(item.statusLabel)),
    ]));
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: scheme.outlineVariant)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: scheme.primary), const SizedBox(width: 10), Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)))]),
      const SizedBox(height: 14),
      child,
    ]));
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(width: 180, child: DecoratedBox(decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(14), border: Border.all(color: scheme.outlineVariant)), child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [Icon(icon, color: scheme.primary), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelMedium)]))]))));
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.title, required this.fileName, required this.busy, required this.icon, required this.onPressed});
  final String title;
  final String fileName;
  final bool busy;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: busy ? null : onPressed, icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(icon), label: Align(alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(title), if (fileName.isNotEmpty) Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12))]))));
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(999)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))));
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), child: Text(label, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800))));
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 140, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))), Expanded(child: Text(value.trim().isEmpty ? 'Not set' : value))]));
  }
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(14)), child: Text(message));
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(14)), child: Row(children: [Expanded(child: Text(message)), TextButton(onPressed: onRetry, child: const Text('Retry'))]));
}

class _Format {
  const _Format(this.type, this.title, this.subtitle, this.detail, this.icon);
  final String type;
  final String title;
  final String subtitle;
  final String detail;
  final IconData icon;
}

const _formats = [
  _Format('single_choice', 'Single answer', 'One correct option only.', 'Best for normal objective questions with one correct answer.', Icons.radio_button_checked_outlined),
  _Format('multiple_choice', 'Multiple answers', 'Two or more correct options.', 'Use when more than one option is correct. Partial marking can be enabled.', Icons.checklist_rtl_outlined),
  _Format('fill_blank', 'Fill in the blank', 'Short typed answer.', 'Best for formulas, keywords, definitions, and short responses.', Icons.short_text_outlined),
  _Format('essay', 'Essay / Theory', 'Long answer with marking guide.', 'Best for explanations, calculations, case studies, and theory answers.', Icons.subject_outlined),
  _Format('drag_drop', 'Drag and drop', 'Matching or ordering task.', 'Best for matching terms, ordering steps, or arranging items.', Icons.drag_indicator_outlined),
  _Format('image_question', 'Picture question', 'Question based on image or diagram.', 'Best for charts, diagrams, screenshots, maps, and visual analysis.', Icons.image_outlined),
  _Format('file_upload', 'File upload / Practical', 'Student submits a file.', 'Best for code, documents, drawings, spreadsheets, or practical tasks.', Icons.attach_file_outlined),
];

_Format _format(String type) => _formats.firstWhere((f) => f.type == type, orElse: () => _formats.first);

class _OptionDraft {
  _OptionDraft(this.keyName, this.text, [this.correct = false]);
  final String keyName;
  final String text;
  final bool correct;
  _OptionDraft copy({String? text, bool? correct}) => _OptionDraft(keyName, text ?? this.text, correct ?? this.correct);
  Map<String, dynamic> toPayload() => {'key': keyName, 'text': text.trim(), 'is_correct': correct};
}

class _QuestionDraft {
  _QuestionDraft({required this.id, required this.type, required this.topic, required this.marks, required this.prompt, required this.answer, this.rubric = '', this.partialMarking = false, List<_OptionDraft>? options}) : options = options ?? _defaultOptions();
  factory _QuestionDraft.single({required String id, String topic = 'Course learning outcome', String marks = '1', String prompt = '', List<_OptionDraft>? options}) => _QuestionDraft(id: id, type: 'single_choice', topic: topic, marks: marks, prompt: prompt, answer: '', options: options);
  factory _QuestionDraft.multiple({required String id, String marks = '1'}) => _QuestionDraft(id: id, type: 'multiple_choice', topic: 'Course learning outcome', marks: marks, prompt: '', answer: '', partialMarking: true);
  factory _QuestionDraft.essay({required String id, String topic = 'Course learning outcome', String marks = '10', String prompt = '', String answer = ''}) => _QuestionDraft(id: id, type: 'essay', topic: topic, marks: marks, prompt: prompt, answer: answer);
  factory _QuestionDraft.forType(String id, String type, String marks) {
    if (type == 'single_choice') return _QuestionDraft.single(id: id, marks: marks);
    if (type == 'multiple_choice') return _QuestionDraft.multiple(id: id, marks: marks);
    if (type == 'essay') return _QuestionDraft.essay(id: id, marks: marks);
    return _QuestionDraft(id: id, type: type, topic: 'Course learning outcome', marks: marks, prompt: '', answer: '');
  }

  String id;
  String type;
  String topic;
  String marks;
  String prompt;
  String answer;
  String rubric;
  bool partialMarking;
  List<_OptionDraft> options;

  bool get needsOptions => type == 'single_choice' || type == 'multiple_choice';
  List<_OptionDraft> get validOptions => options.where((o) => o.text.trim().isNotEmpty).toList();
  Set<String> get correctKeys => options.where((o) => o.correct).map((o) => o.keyName).toSet();
  String? get singleCorrect => correctKeys.isEmpty ? null : correctKeys.first;

  static List<_OptionDraft> _defaultOptions() => [_OptionDraft('A', ''), _OptionDraft('B', ''), _OptionDraft('C', ''), _OptionDraft('D', '')];

  _QuestionDraft copy(String newId) => _QuestionDraft(id: newId, type: type, topic: topic, marks: marks, prompt: prompt, answer: answer, rubric: rubric, partialMarking: partialMarking, options: [for (final o in options) o.copy()]);

  void setType(String next) {
    type = next;
    if (needsOptions && options.length < 2) options = _defaultOptions();
    if (type == 'multiple_choice') partialMarking = true;
    if (type == 'single_choice' && correctKeys.length > 1) setSingleCorrect(correctKeys.first);
  }

  void addOption() {
    options.add(_OptionDraft(String.fromCharCode('A'.codeUnitAt(0) + options.length), ''));
  }

  void setSingleCorrect(String key) {
    options = [for (final o in options) _OptionDraft(o.keyName, o.text, o.keyName == key)];
    syncAnswer();
  }

  void syncAnswer() {
    if (needsOptions) answer = correctKeys.join(',');
  }

  List<String> requiredIssues(int number) {
    final out = <String>[];
    final prefix = 'Question $number';
    if (prompt.trim().isEmpty) out.add('$prefix needs question text.');
    if ((int.tryParse(marks.trim()) ?? 0) <= 0) out.add('$prefix needs valid marks.');
    if (needsOptions && validOptions.length < 2) out.add('$prefix needs at least two options.');
    if (type == 'single_choice' && correctKeys.length != 1) out.add('$prefix needs exactly one correct answer.');
    if (type == 'multiple_choice' && correctKeys.length < 2) out.add('$prefix needs at least two correct answers.');
    if (!needsOptions && answer.trim().isEmpty) out.add('$prefix needs an answer key or marking guide.');
    return out;
  }

  Map<String, dynamic> toPayload(int number) {
    final payload = <String, dynamic>{
      'id': id,
      'type': type,
      'question_type': type,
      'topic': topic,
      'prompt': prompt,
      'question_text': prompt,
      'marks': int.tryParse(marks.trim()) ?? 0,
      'order_number': number,
      'metadata': {'topic': topic, 'rubric': rubric, 'partial_marking': partialMarking},
    };
    if (needsOptions) {
      payload['options'] = [for (final o in validOptions) o.toPayload()];
      payload['correct_answer'] = type == 'single_choice' ? singleCorrect : null;
      payload['correct_answers'] = correctKeys.toList();
    } else if (type == 'fill_blank') {
      payload['correct_answer'] = answer;
    } else if (type == 'drag_drop') {
      payload['matching_guide'] = answer;
      payload['pairs'] = _pairs(answer);
    } else {
      payload['marking_guide'] = answer;
    }
    if (type == 'image_question') payload['allowed_file_types'] = ['jpg', 'jpeg', 'png'];
    if (type == 'file_upload') payload['allowed_file_types'] = ['pdf', 'docx', 'zip', 'jpg', 'png'];
    return payload;
  }

  List<Map<String, String>> _pairs(String value) {
    final out = <Map<String, String>>[];
    for (final raw in value.split(';')) {
      final parts = raw.split('=');
      if (parts.length == 2) out.add({'left': parts[0].trim(), 'right': parts[1].trim()});
    }
    return out;
  }
}
