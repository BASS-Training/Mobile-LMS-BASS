import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';

/// Parsing JSON dari endpoint `case-studies/by-lesson/{id}` menjadi entitas domain.
class CaseStudyModel {
  static CaseStudyEntity fromApi(Map<String, dynamic> data) {
    final template = data['template'];
    final sections = <CaseStudySectionEntity>[];
    if (template is Map && template['sections'] is List) {
      for (final s in (template['sections'] as List)) {
        if (s is Map) {
          sections.add(_sectionFromJson(Map<String, dynamic>.from(s)));
        }
      }
    }

    CaseStudySubmissionEntity? submission;
    final sub = data['submission'];
    if (sub is Map) {
      submission = _submissionFromJson(Map<String, dynamic>.from(sub));
    }

    return CaseStudyEntity(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      courseId: data['courseId']?.toString() ?? '',
      allowAnswerDownload: data['allowAnswerDownload'] == true,
      scoringEnabled: data['scoringEnabled'] != false,
      sections: sections,
      submission: submission,
    );
  }

  static CaseStudySectionEntity _sectionFromJson(Map<String, dynamic> json) {
    final blocks = <CaseStudyBlockEntity>[];
    if (json['blocks'] is List) {
      for (final b in (json['blocks'] as List)) {
        if (b is Map) {
          blocks.add(_blockFromJson(Map<String, dynamic>.from(b)));
        }
      }
    }
    return CaseStudySectionEntity(
      id: json['id']?.toString() ?? '',
      level: (json['level'] as num?)?.toInt() ?? 1,
      title: json['title']?.toString() ?? '',
      instruction: json['instruction']?.toString() ?? '',
      blocks: blocks,
    );
  }

  static CaseStudyBlockEntity _blockFromJson(Map<String, dynamic> json) {
    final kind = json['kind']?.toString() ?? 'text';
    CaseStudyTableEntity? table;
    if (kind == 'table' && json['table'] is Map) {
      table = _tableFromJson(Map<String, dynamic>.from(json['table']));
    }
    return CaseStudyBlockEntity(
      id: json['id']?.toString() ?? '',
      kind: kind,
      label: json['label']?.toString() ?? '',
      table: table,
    );
  }

  static CaseStudyTableEntity _tableFromJson(Map<String, dynamic> json) {
    final cells = <List<CaseStudyCellEntity>>[];
    final rawCells = json['cells'];
    if (rawCells is List) {
      for (var r = 0; r < rawCells.length; r++) {
        final rowRaw = rawCells[r];
        final row = <CaseStudyCellEntity>[];
        if (rowRaw is List) {
          for (var c = 0; c < rowRaw.length; c++) {
            final cellRaw = rowRaw[c] is Map
                ? Map<String, dynamic>.from(rowRaw[c])
                : <String, dynamic>{};
            row.add(
              CaseStudyCellEntity(
                row: r,
                col: c,
                rowSpan: (cellRaw['rowSpan'] as num?)?.toInt() ?? 1,
                colSpan: (cellRaw['colSpan'] as num?)?.toInt() ?? 1,
                covered: cellRaw['covered'] == true,
                role: cellRaw['role']?.toString() ?? 'input',
                text: cellRaw['text']?.toString() ?? '',
                bg: cellRaw['bg']?.toString() ?? '#ffffff',
                align: cellRaw['align']?.toString() ?? 'left',
                bold: cellRaw['bold'] == true,
              ),
            );
          }
        }
        cells.add(row);
      }
    }
    return CaseStudyTableEntity(cells: cells);
  }

  static CaseStudySubmissionEntity _submissionFromJson(
    Map<String, dynamic> json,
  ) {
    final rawAnswers = json['answers'];
    final answers = <String, dynamic>{};
    if (rawAnswers is Map) {
      rawAnswers.forEach((k, v) => answers[k.toString()] = v);
    }
    return CaseStudySubmissionEntity(
      submissionId: json['submissionId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'draft',
      answers: answers,
      score: (json['score'] as num?)?.toInt(),
      feedback: json['feedback']?.toString(),
    );
  }
}
