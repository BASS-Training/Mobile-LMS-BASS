import 'package:equatable/equatable.dart';

/// Satu sel tabel pada template studi kasus.
class CaseStudyCellEntity extends Equatable {
  final int row;
  final int col;
  final int rowSpan;
  final int colSpan;
  final bool covered;
  final String role; // 'label' | 'input'
  final String text;
  final String bg;
  final String align; // left | center | right
  final bool bold;

  const CaseStudyCellEntity({
    required this.row,
    required this.col,
    this.rowSpan = 1,
    this.colSpan = 1,
    this.covered = false,
    this.role = 'input',
    this.text = '',
    this.bg = '#ffffff',
    this.align = 'left',
    this.bold = false,
  });

  bool get isInput => role == 'input';
  String get key => '$row-$col';

  @override
  List<Object?> get props => [
    row,
    col,
    rowSpan,
    colSpan,
    covered,
    role,
    text,
    bg,
    align,
    bold,
  ];
}

/// Tabel = matriks sel.
class CaseStudyTableEntity extends Equatable {
  final List<List<CaseStudyCellEntity>> cells;

  const CaseStudyTableEntity({this.cells = const []});

  int get rows => cells.length;
  int get cols => cells.isNotEmpty ? cells.first.length : 0;

  @override
  List<Object?> get props => [cells];
}

/// Blok di dalam section: teks (diisi peserta) atau tabel.
class CaseStudyBlockEntity extends Equatable {
  final String id;
  final String kind; // 'text' | 'table'
  final String label; // untuk text block
  final CaseStudyTableEntity? table;

  const CaseStudyBlockEntity({
    required this.id,
    required this.kind,
    this.label = '',
    this.table,
  });

  bool get isText => kind == 'text';
  bool get isTable => kind == 'table';

  @override
  List<Object?> get props => [id, kind, label, table];
}

/// Bab (level 1) atau Subbab (level 2).
class CaseStudySectionEntity extends Equatable {
  final String id;
  final int level;
  final String title;
  final String instruction;
  final List<CaseStudyBlockEntity> blocks;

  const CaseStudySectionEntity({
    required this.id,
    this.level = 1,
    this.title = '',
    this.instruction = '',
    this.blocks = const [],
  });

  @override
  List<Object?> get props => [id, level, title, instruction, blocks];
}

/// Jawaban peserta yang sudah tersimpan di server.
class CaseStudySubmissionEntity extends Equatable {
  final String submissionId;
  final String status; // draft | submitted | graded
  final Map<String, dynamic> answers; // sectionId -> blockId -> (String | Map)
  final int? score;
  final String? feedback;

  const CaseStudySubmissionEntity({
    required this.submissionId,
    required this.status,
    this.answers = const {},
    this.score,
    this.feedback,
  });

  bool get isSubmitted => status == 'submitted' || status == 'graded';
  bool get isGraded => status == 'graded';

  @override
  List<Object?> get props => [submissionId, status, answers, score, feedback];
}

/// Payload lengkap konten studi kasus (template + submission).
class CaseStudyEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final bool allowAnswerDownload;
  final bool scoringEnabled;
  final List<CaseStudySectionEntity> sections;
  final CaseStudySubmissionEntity? submission;

  const CaseStudyEntity({
    required this.id,
    required this.title,
    this.description = '',
    this.courseId = '',
    this.allowAnswerDownload = false,
    this.scoringEnabled = true,
    this.sections = const [],
    this.submission,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    courseId,
    allowAnswerDownload,
    scoringEnabled,
    sections,
    submission,
  ];
}
