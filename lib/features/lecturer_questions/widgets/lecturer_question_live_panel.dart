import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../data/lecturer_question_api.dart';

class LecturerQuestionLivePanel extends StatefulWidget {
  const LecturerQuestionLivePanel({super.key});

  @override
  State<LecturerQuestionLivePanel> createState() =>
      _LecturerQuestionLivePanelState();
}

class _LecturerQuestionLivePanelState extends State<LecturerQuestionLivePanel> {
  final LecturerQuestionApi _api = LecturerQuestionApi();

  final _titleController = TextEditingController(text: 'Full Question Paper');
  final _descriptionController = TextEditingController(
    text: 'Lecturer submitted question paper for exam officer review.',
  );
  final _instructionsController = TextEditingController(
    text: 'Answer all questions.',
  );
  final _durationController = TextEditingController(text: '120');
  final _examOfficerController = TextEditingController(text: '4');
  final _objectiveCountController = TextEditingController(text: '20');
  final _marksPerQuestionController = TextEditingController(text: '1');

  bool _loading = true;
  bool _saving = false;
  bool _uploadingObjectives = false;
  bool _uploadingAnswerScript = false;
  bool _autoMarkObjective = true;
  String? _error;
  String? _notice;
  String _objectiveUploadName = '';
  String _objectiveUploadUrl = '';
  String _answerScriptName = '';
  String _answerScriptUrl = '';

  int? _selectedCourseId;
  String _selectedType = 'objective';

  List<QuestionCourseOption> _courses = const [];
  List<QuestionPaperItem> _papers = const [];
  final List<_QuestionDraft> _questions = [
    _QuestionDraft(
      id: 'q1',
      type: 'objective',
      topic: 'Stacks and queues',
      marks: '2',
      prompt: 'Which data structure follows last-in-first-out order?',
      answer: 'Stack',
      optionA: 'Queue',
      optionB: 'Stack',
      optionC: 'Array',
      optionD: 'Tree',
    ),
    _QuestionDraft(
      id: 'q2',
      type: 'essay',
      topic: 'Binary search trees',
      marks: '20',
      prompt:
          'Explain insertion and search operations in a binary search tree.',
      answer:
          'Compare at each node, branch left/right, and explain balanced tree cost.',
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
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _durationController.dispose();
    _examOfficerController.dispose();
    _objectiveCountController.dispose();
    _marksPerQuestionController.dispose();
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

  Future<void> _submitToExamOfficer() async {
    final courseId = _selectedCourseId;
    final lecturerId =
        int.tryParse(AuthSession.instance.session?.staffId ?? '') ?? 0;
    final examOfficerId = int.tryParse(_examOfficerController.text.trim()) ?? 0;
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;

    if (courseId == null || courseId == 0) {
      _showError('Select a course before submitting.');
      return;
    }
    if (lecturerId == 0) {
      _showError('Lecturer profile was not found. Please login again.');
      return;
    }
    if (examOfficerId == 0) {
      _showError('Enter the Exam Officer ID.');
      return;
    }
    if (duration <= 0) {
      _showError('Enter a valid exam duration.');
      return;
    }
    if (_questions.isEmpty) {
      _showError('Add at least one question.');
      return;
    }

    final badQuestion = _questions
        .where((item) => item.prompt.trim().isEmpty)
        .toList();
    if (badQuestion.isNotEmpty) {
      _showError('Every question must have question text.');
      return;
    }

    setState(() {
      _saving = true;
      _notice = null;
    });

    try {
      final created = await _api.submitQuestionPaper(
        courseId: courseId,
        lecturerId: lecturerId,
        examOfficerId: examOfficerId,
        title: _titleController.text.trim().isEmpty
            ? 'Untitled question paper'
            : _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        instructions: _instructionsController.text.trim(),
        durationMinutes: duration,
        questionPayload: _buildQuestionPayload(),
      );

      if (!mounted) return;
      setState(() {
        _papers = [created, ..._papers];
        _saving = false;
        _notice = 'Question paper submitted to Exam Officer.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question paper submitted to Exam Officer.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError(error.toString());
    }
  }

  Map<String, dynamic> _buildQuestionPayload() {
    return {
      'version': 1,
      'source': 'lecturer_question_builder',
      'auto_mark_objective': _autoMarkObjective,
      'allowed_question_types': const [
        'objective',
        'fill_blank',
        'drag_drop',
        'essay',
        'image_question',
        'file_upload',
      ],
      'total_marks': _totalMarks,
      'objective_upload': {
        if (_objectiveUploadName.isNotEmpty) 'file_name': _objectiveUploadName,
        if (_objectiveUploadUrl.isNotEmpty) 'file_url': _objectiveUploadUrl,
      },
      'answer_script': {
        if (_answerScriptName.isNotEmpty) 'file_name': _answerScriptName,
        if (_answerScriptUrl.isNotEmpty) 'file_url': _answerScriptUrl,
      },
      'questions': [
        for (var i = 0; i < _questions.length; i++)
          _questions[i].toPayload(i + 1),
      ],
    };
  }

  int get _totalMarks => _questions.fold<int>(
    0,
    (total, item) => total + (int.tryParse(item.marks.trim()) ?? 0),
  );

  void _addQuestion() {
    setState(() {
      _questions.add(
        _QuestionDraft(
          id: 'q${_questions.length + 1}',
          type: _selectedType,
          topic: 'Course learning outcome',
          marks: _marksPerQuestionController.text.trim().isEmpty
              ? '1'
              : _marksPerQuestionController.text.trim(),
          prompt: '',
          answer: '',
        ),
      );
    });
  }

  void _addObjectiveQuestion() {
    setState(() {
      _selectedType = 'objective';
      _questions.add(
        _QuestionDraft(
          id: 'q${_questions.length + 1}',
          type: 'objective',
          topic: 'Course learning outcome',
          marks: _marksPerQuestionController.text.trim().isEmpty
              ? '1'
              : _marksPerQuestionController.text.trim(),
          prompt: '',
          answer: '',
        ),
      );
    });
  }

  void _addObjectiveBatch() {
    final count = int.tryParse(_objectiveCountController.text.trim()) ?? 0;
    final marks = int.tryParse(_marksPerQuestionController.text.trim()) ?? 0;

    if (count <= 0) {
      _showError('Enter the number of objective questions to create.');
      return;
    }
    if (marks <= 0) {
      _showError('Enter marks for each objective question.');
      return;
    }

    setState(() {
      _selectedType = 'objective';
      for (var i = 0; i < count; i++) {
        _questions.add(
          _QuestionDraft(
            id: 'q${_questions.length + 1}',
            type: 'objective',
            topic: 'Course learning outcome',
            marks: '$marks',
            prompt: '',
            answer: '',
          ),
        );
      }
    });
  }

  Future<void> _pickAndUploadObjectives() async {
    await _pickAndUploadQuestionFile(
      category: 'objective_questions',
      uploadingSetter: (value) => _uploadingObjectives = value,
      onUploaded: (name, url) {
        _objectiveUploadName = name;
        _objectiveUploadUrl = url;
      },
    );
  }

  Future<void> _pickAndUploadAnswerScript() async {
    await _pickAndUploadQuestionFile(
      category: 'answer_script',
      uploadingSetter: (value) => _uploadingAnswerScript = value,
      onUploaded: (name, url) {
        _answerScriptName = name;
        _answerScriptUrl = url;
      },
    );
  }

  Future<void> _pickAndUploadQuestionFile({
    required String category,
    required ValueChanged<bool> uploadingSetter,
    required void Function(String fileName, String fileUrl) onUploaded,
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

    setState(() => uploadingSetter(true));
    try {
      final url = await _api.uploadFile(
        bytes: bytes,
        fileName: file.name,
        category: category,
      );
      if (!mounted) return;
      setState(() {
        uploadingSetter(false);
        onUploaded(file.name, url);
        _notice = '${file.name} uploaded.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => uploadingSetter(false));
      _showError(error.toString());
    }
  }

  void _removeQuestion(_QuestionDraft item) {
    setState(() => _questions.remove(item));
  }

  void _showError(String message) {
    setState(() => _notice = null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: _loading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 14,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 780),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.rule_folder_outlined,
                                  color: scheme.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Exam Question Paper',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Prepare all question forms and submit the paper to the Exam Officer for moderation workflow.',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _saving ? null : _submitToExamOfficer,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_outlined),
                        label: const Text('Submit to Exam Officer'),
                      ),
                    ],
                  ),
                  if (_notice != null) ...[
                    const SizedBox(height: 12),
                    _NoticeBox(message: _notice!),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    _ErrorBox(message: _error!, onRetry: _load),
                  ],
                  const SizedBox(height: 16),
                  _PaperDetails(
                    courses: _courses,
                    selectedCourseId: _selectedCourseId,
                    onCourseChanged: (value) =>
                        setState(() => _selectedCourseId = value),
                    titleController: _titleController,
                    descriptionController: _descriptionController,
                    instructionsController: _instructionsController,
                    durationController: _durationController,
                    examOfficerController: _examOfficerController,
                  ),
                  const SizedBox(height: 14),
                  _QuestionTypeBar(
                    selectedType: _selectedType,
                    totalMarks: _totalMarks,
                    questionCount: _questions.length,
                    objectiveCountController: _objectiveCountController,
                    marksPerQuestionController: _marksPerQuestionController,
                    objectiveUploadName: _objectiveUploadName,
                    answerScriptName: _answerScriptName,
                    uploadingObjectives: _uploadingObjectives,
                    uploadingAnswerScript: _uploadingAnswerScript,
                    autoMarkObjective: _autoMarkObjective,
                    onTypeChanged: (value) =>
                        setState(() => _selectedType = value),
                    onAutoMarkChanged: (value) =>
                        setState(() => _autoMarkObjective = value),
                    onAddQuestion: _addQuestion,
                    onAddObjective: _addObjectiveQuestion,
                    onAddObjectiveBatch: _addObjectiveBatch,
                    onUploadObjectives: _pickAndUploadObjectives,
                    onUploadAnswerScript: _pickAndUploadAnswerScript,
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < _questions.length; i++) ...[
                    _QuestionDraftCard(
                      number: i + 1,
                      item: _questions[i],
                      onChanged: () => setState(() {}),
                      onRemove: () => _removeQuestion(_questions[i]),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 8),
                  _SubmittedPapersPanel(items: _papers),
                ],
              ),
      ),
    );
  }
}

class _PaperDetails extends StatelessWidget {
  const _PaperDetails({
    required this.courses,
    required this.selectedCourseId,
    required this.onCourseChanged,
    required this.titleController,
    required this.descriptionController,
    required this.instructionsController,
    required this.durationController,
    required this.examOfficerController,
  });

  final List<QuestionCourseOption> courses;
  final int? selectedCourseId;
  final ValueChanged<int?> onCourseChanged;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController instructionsController;
  final TextEditingController durationController;
  final TextEditingController examOfficerController;

  @override
  Widget build(BuildContext context) {
    return _PanelBox(
      title: 'Paper details',
      icon: Icons.description_outlined,
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 320,
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: selectedCourseId,
                  items: [
                    for (final course in courses)
                      DropdownMenuItem(
                        value: course.id,
                        child: Text(course.label),
                      ),
                  ],
                  onChanged: onCourseChanged,
                  decoration: const InputDecoration(labelText: 'Course'),
                ),
              ),
              SizedBox(
                width: 320,
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Exam title'),
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration minutes',
                  ),
                ),
              ),
              SizedBox(
                width: 190,
                child: TextField(
                  controller: examOfficerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Exam Officer ID',
                    helperText: 'Temporary until staff picker',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descriptionController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: instructionsController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Student instructions',
              prefixIcon: Icon(Icons.rule_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionTypeBar extends StatelessWidget {
  const _QuestionTypeBar({
    required this.selectedType,
    required this.totalMarks,
    required this.questionCount,
    required this.objectiveCountController,
    required this.marksPerQuestionController,
    required this.objectiveUploadName,
    required this.answerScriptName,
    required this.uploadingObjectives,
    required this.uploadingAnswerScript,
    required this.autoMarkObjective,
    required this.onTypeChanged,
    required this.onAutoMarkChanged,
    required this.onAddQuestion,
    required this.onAddObjective,
    required this.onAddObjectiveBatch,
    required this.onUploadObjectives,
    required this.onUploadAnswerScript,
  });

  final String selectedType;
  final int totalMarks;
  final int questionCount;
  final TextEditingController objectiveCountController;
  final TextEditingController marksPerQuestionController;
  final String objectiveUploadName;
  final String answerScriptName;
  final bool uploadingObjectives;
  final bool uploadingAnswerScript;
  final bool autoMarkObjective;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<bool> onAutoMarkChanged;
  final VoidCallback onAddQuestion;
  final VoidCallback onAddObjective;
  final VoidCallback onAddObjectiveBatch;
  final VoidCallback onUploadObjectives;
  final VoidCallback onUploadAnswerScript;

  @override
  Widget build(BuildContext context) {
    return _PanelBox(
      title: 'Question builder',
      icon: Icons.quiz_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricTile(
                label: 'Questions',
                value: '$questionCount',
                icon: Icons.format_list_numbered_outlined,
              ),
              _MetricTile(
                label: 'Total marks',
                value: '$totalMarks',
                icon: Icons.scoreboard_outlined,
              ),
              _MetricTile(
                label: 'Objective mode',
                value: autoMarkObjective ? 'Auto mark' : 'Manual',
                icon: Icons.fact_check_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  items: const [
                    DropdownMenuItem(
                      value: 'objective',
                      child: Text('Objective'),
                    ),
                    DropdownMenuItem(
                      value: 'fill_blank',
                      child: Text('Fill in the blank'),
                    ),
                    DropdownMenuItem(
                      value: 'drag_drop',
                      child: Text('Drag and drop'),
                    ),
                    DropdownMenuItem(
                      value: 'essay',
                      child: Text('Essay / Theory'),
                    ),
                    DropdownMenuItem(
                      value: 'image_question',
                      child: Text('Picture question'),
                    ),
                    DropdownMenuItem(
                      value: 'file_upload',
                      child: Text('File upload / Practical'),
                    ),
                  ],
                  onChanged: (value) => onTypeChanged(value ?? 'objective'),
                  decoration: const InputDecoration(
                    labelText: 'New question type',
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onAddQuestion,
                icon: const Icon(Icons.add_outlined),
                label: const Text('Add question'),
              ),
              FilledButton.icon(
                onPressed: onAddObjective,
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Add objective'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 190,
                child: TextField(
                  controller: objectiveCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'No. of objectives',
                    prefixIcon: Icon(Icons.format_list_numbered_outlined),
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: marksPerQuestionController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Mark each',
                    prefixIcon: Icon(Icons.pin_outlined),
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onAddObjectiveBatch,
                icon: const Icon(Icons.playlist_add_outlined),
                label: const Text('Create objective set'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _UploadAction(
                title: 'Upload objective questions',
                fileName: objectiveUploadName,
                busy: uploadingObjectives,
                icon: Icons.upload_file_outlined,
                onPressed: onUploadObjectives,
              ),
              _UploadAction(
                title: 'Upload answer script',
                fileName: answerScriptName,
                busy: uploadingAnswerScript,
                icon: Icons.fact_check_outlined,
                onPressed: onUploadAnswerScript,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: autoMarkObjective,
            onChanged: onAutoMarkChanged,
            title: const Text(
              'Auto-mark objective and fill-in-the-blank questions',
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _QuestionDraftCard extends StatelessWidget {
  const _QuestionDraftCard({
    required this.number,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  final int number;
  final _QuestionDraft item;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MiniPill(label: 'Question $number'),
              SizedBox(
                width: 230,
                child: DropdownButtonFormField<String>(
                  initialValue: item.type,
                  items: const [
                    DropdownMenuItem(
                      value: 'objective',
                      child: Text('Objective'),
                    ),
                    DropdownMenuItem(
                      value: 'fill_blank',
                      child: Text('Fill in the blank'),
                    ),
                    DropdownMenuItem(
                      value: 'drag_drop',
                      child: Text('Drag and drop'),
                    ),
                    DropdownMenuItem(
                      value: 'essay',
                      child: Text('Essay / Theory'),
                    ),
                    DropdownMenuItem(
                      value: 'image_question',
                      child: Text('Picture question'),
                    ),
                    DropdownMenuItem(
                      value: 'file_upload',
                      child: Text('File upload / Practical'),
                    ),
                  ],
                  onChanged: (value) {
                    item.type = value ?? item.type;
                    onChanged();
                  },
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
              ),
              SizedBox(
                width: 130,
                child: TextFormField(
                  initialValue: item.marks,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    item.marks = value;
                    onChanged();
                  },
                  decoration: const InputDecoration(labelText: 'Marks'),
                ),
              ),
              SizedBox(
                width: 260,
                child: TextFormField(
                  initialValue: item.topic,
                  onChanged: (value) {
                    item.topic = value;
                    onChanged();
                  },
                  decoration: const InputDecoration(labelText: 'Topic / CLO'),
                ),
              ),
              IconButton(
                tooltip: 'Remove question',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: item.prompt,
            minLines: 2,
            maxLines: 5,
            onChanged: (value) {
              item.prompt = value;
              onChanged();
            },
            decoration: InputDecoration(
              labelText: _promptLabel(item.type),
              prefixIcon: const Icon(Icons.help_outline),
            ),
          ),
          if (item.type == 'objective') ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _OptionField(
                  label: 'Option A',
                  value: item.optionA,
                  onChanged: (value) {
                    item.optionA = value;
                    onChanged();
                  },
                ),
                _OptionField(
                  label: 'Option B',
                  value: item.optionB,
                  onChanged: (value) {
                    item.optionB = value;
                    onChanged();
                  },
                ),
                _OptionField(
                  label: 'Option C',
                  value: item.optionC,
                  onChanged: (value) {
                    item.optionC = value;
                    onChanged();
                  },
                ),
                _OptionField(
                  label: 'Option D',
                  value: item.optionD,
                  onChanged: (value) {
                    item.optionD = value;
                    onChanged();
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          TextFormField(
            initialValue: item.answer,
            minLines: 2,
            maxLines: 5,
            onChanged: (value) {
              item.answer = value;
              onChanged();
            },
            decoration: InputDecoration(
              labelText: _answerLabel(item.type),
              prefixIcon: const Icon(Icons.fact_check_outlined),
            ),
          ),
        ],
      ),
    );
  }

  String _promptLabel(String type) {
    switch (type) {
      case 'image_question':
        return 'Picture question instruction';
      case 'file_upload':
        return 'Practical/file upload instruction';
      case 'drag_drop':
        return 'Drag and drop instruction';
      default:
        return 'Question text';
    }
  }

  String _answerLabel(String type) {
    switch (type) {
      case 'objective':
      case 'fill_blank':
        return 'Correct answer / answer key';
      case 'drag_drop':
        return 'Matching guide, example: CPU=Processor; RAM=Memory';
      case 'image_question':
        return 'Expected picture answer / marking guide';
      case 'file_upload':
        return 'Expected file/practical marking guide';
      default:
        return 'Marking guide / expected answer';
    }
  }
}

class _OptionField extends StatelessWidget {
  const _OptionField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _SubmittedPapersPanel extends StatelessWidget {
  const _SubmittedPapersPanel({required this.items});

  final List<QuestionPaperItem> items;

  @override
  Widget build(BuildContext context) {
    final recent = items.take(6).toList();

    return _PanelBox(
      title: 'Submitted question papers',
      icon: Icons.outbox_outlined,
      child: recent.isEmpty
          ? const Text('No question papers submitted yet.')
          : Column(
              children: [
                for (final item in recent)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.description_outlined),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${item.courseLabel} • ${item.questionCount} questions • ${item.totalMarks} marks',
                    ),
                    trailing: _StatusBadge(label: item.statusLabel),
                  ),
              ],
            ),
    );
  }
}

class _PanelBox extends StatelessWidget {
  const _PanelBox({
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 10),
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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
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
      width: 180,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
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

class _UploadAction extends StatelessWidget {
  const _UploadAction({
    required this.title,
    required this.fileName,
    required this.busy,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String fileName;
  final bool busy;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 360,
      child: OutlinedButton.icon(
        onPressed: busy ? null : onPressed,
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title),
              if (fileName.isNotEmpty)
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(message, style: TextStyle(color: scheme.onPrimaryContainer)),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _QuestionDraft {
  _QuestionDraft({
    required this.id,
    required this.type,
    required this.topic,
    required this.marks,
    required this.prompt,
    required this.answer,
    this.optionA = '',
    this.optionB = '',
    this.optionC = '',
    this.optionD = '',
  });

  String id;
  String type;
  String topic;
  String marks;
  String prompt;
  String answer;
  String optionA;
  String optionB;
  String optionC;
  String optionD;

  Map<String, dynamic> toPayload(int number) {
    final markValue = int.tryParse(marks.trim()) ?? 0;

    final payload = <String, dynamic>{
      'id': id.isEmpty ? 'q$number' : id,
      'type': type,
      'topic': topic,
      'prompt': prompt,
      'marks': markValue,
    };

    switch (type) {
      case 'objective':
        payload['options'] = [
          if (optionA.trim().isNotEmpty) {'key': 'A', 'text': optionA.trim()},
          if (optionB.trim().isNotEmpty) {'key': 'B', 'text': optionB.trim()},
          if (optionC.trim().isNotEmpty) {'key': 'C', 'text': optionC.trim()},
          if (optionD.trim().isNotEmpty) {'key': 'D', 'text': optionD.trim()},
        ];
        payload['correct_answer'] = answer;
        break;
      case 'fill_blank':
        payload['correct_answer'] = answer;
        break;
      case 'drag_drop':
        payload['matching_guide'] = answer;
        payload['pairs'] = _pairsFromAnswer(answer);
        break;
      case 'image_question':
        payload['marking_guide'] = answer;
        payload['allowed_file_types'] = ['jpg', 'jpeg', 'png'];
        break;
      case 'file_upload':
        payload['marking_guide'] = answer;
        payload['allowed_file_types'] = ['pdf', 'docx', 'zip', 'jpg', 'png'];
        break;
      default:
        payload['marking_guide'] = answer;
        break;
    }

    return payload;
  }

  List<Map<String, String>> _pairsFromAnswer(String value) {
    final pairs = <Map<String, String>>[];
    for (final raw in value.split(';')) {
      final parts = raw.split('=');
      if (parts.length == 2) {
        pairs.add({'left': parts[0].trim(), 'right': parts[1].trim()});
      }
    }
    return pairs;
  }
}
