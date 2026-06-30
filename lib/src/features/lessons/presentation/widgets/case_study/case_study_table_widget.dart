import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Merender tabel studi kasus dengan menghormati merge (rowSpan/colSpan).
/// Lebar kolom menyesuaikan isi (kata tidak dipotong) dan tinggi baris
/// menyesuaikan teks yang membungkus — fleksibel ke samping maupun ke bawah.
class CaseStudyTableWidget extends StatefulWidget {
  final CaseStudyTableEntity table;
  final bool readOnly;

  /// Controller untuk sel input (mode edit). Null bila read-only.
  final TextEditingController Function(CaseStudyCellEntity cell)?
  controllerProvider;

  /// Nilai jawaban sel input pada mode read-only.
  final String Function(CaseStudyCellEntity cell)? valueProvider;

  const CaseStudyTableWidget({
    super.key,
    required this.table,
    this.readOnly = false,
    this.controllerProvider,
    this.valueProvider,
  });

  @override
  State<CaseStudyTableWidget> createState() => _CaseStudyTableWidgetState();
}

class _CaseStudyTableWidgetState extends State<CaseStudyTableWidget> {
  static const double _hPad = 14; // padding kiri+kanan
  static const double _vPad = 12; // padding atas+bawah
  static const double _minCol = 80;
  static const double _maxCol = 240;
  static const double _hardMaxCol = 420;
  static const double _minRow = 42;

  final List<TextEditingController> _listened = [];

  @override
  void initState() {
    super.initState();
    _attachListeners();
  }

  @override
  void didUpdateWidget(covariant CaseStudyTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.table != widget.table ||
        oldWidget.readOnly != widget.readOnly) {
      _detachListeners();
      _attachListeners();
    }
  }

  void _attachListeners() {
    if (widget.readOnly || widget.controllerProvider == null) return;
    for (final row in widget.table.cells) {
      for (final cell in row) {
        if (cell.covered || !cell.isInput) continue;
        final c = widget.controllerProvider!(cell);
        c.addListener(_onChanged);
        _listened.add(c);
      }
    }
  }

  void _detachListeners() {
    for (final c in _listened) {
      c.removeListener(_onChanged);
    }
    _listened.clear();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _detachListeners();
    super.dispose();
  }

  static Color _hexColor(String hex, Color fallback) {
    var h = hex.replaceAll('#', '').trim();
    if (h.length == 6) h = 'FF$h';
    if (h.length != 8) return fallback;
    final value = int.tryParse(h, radix: 16);
    return value == null ? fallback : Color(value);
  }

  // Tabel adalah bagian dari "kertas" dokumen → selalu tinta gelap di atas
  // latar putih/warna sel, sama seperti PDF (lihat AppColors paper/ink).
  TextStyle _styleFor(CaseStudyCellEntity cell) => TextStyle(
    fontSize: 12,
    height: 1.3,
    fontWeight: cell.bold ? FontWeight.bold : FontWeight.normal,
    color: AppColors.ink,
  );

  TextAlign _textAlign(String align) {
    switch (align) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  Alignment _alignment(String align) {
    switch (align) {
      case 'center':
        return Alignment.topCenter;
      case 'right':
        return Alignment.topRight;
      default:
        return Alignment.topLeft;
    }
  }

  String _contentOf(CaseStudyCellEntity cell) {
    if (cell.isInput) {
      if (widget.readOnly) return widget.valueProvider?.call(cell) ?? '';
      return widget.controllerProvider?.call(cell).text ?? '';
    }
    return cell.text;
  }

  double _measureLine(String text, TextStyle style) {
    if (text.isEmpty) return 0;
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  double _measureHeight(String text, TextStyle style, double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(text: text.isEmpty ? ' ' : text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: math.max(20, maxWidth));
    return tp.height;
  }

  /// Lebar yang diinginkan satu sel: cukup untuk seluruh teks (s/d _maxCol),
  /// tapi minimal selebar kata terpanjang agar kata tidak terpotong.
  double _desiredWidth(String text, TextStyle style) {
    if (text.trim().isEmpty) return _minCol;
    final full = _measureLine(text, style) + _hPad;
    double longestWord = 0;
    for (final w in text.split(RegExp(r'\s+'))) {
      longestWord = math.max(longestWord, _measureLine(w, style));
    }
    longestWord += _hPad;
    double width = full <= _maxCol ? full : _maxCol;
    width = math.max(width, longestWord);
    return width.clamp(_minCol, _hardMaxCol);
  }

  @override
  Widget build(BuildContext context) {
    final cells = widget.table.cells;
    final rows = widget.table.rows;
    final cols = widget.table.cols;
    if (rows == 0 || cols == 0) return const SizedBox.shrink();

    // 1) Lebar kolom dari sel ber-colSpan 1.
    final colWidths = List<double>.filled(cols, _minCol);
    for (final row in cells) {
      for (final cell in row) {
        if (cell.covered || cell.colSpan != 1) continue;
        final w = _desiredWidth(_contentOf(cell), _styleFor(cell));
        if (w > colWidths[cell.col]) colWidths[cell.col] = w;
      }
    }
    // Akomodasi sel ber-colSpan > 1 (distribusi kekurangan lebar).
    for (final row in cells) {
      for (final cell in row) {
        if (cell.covered || cell.colSpan <= 1) continue;
        final need = _desiredWidth(_contentOf(cell), _styleFor(cell));
        double have = 0;
        for (var c = cell.col; c < cell.col + cell.colSpan && c < cols; c++) {
          have += colWidths[c];
        }
        if (need > have) {
          final add = (need - have) / cell.colSpan;
          for (var c = cell.col; c < cell.col + cell.colSpan && c < cols; c++) {
            colWidths[c] = (colWidths[c] + add).clamp(_minCol, _hardMaxCol);
          }
        }
      }
    }
    final colOffsets = List<double>.filled(cols + 1, 0);
    for (var c = 0; c < cols; c++) {
      colOffsets[c + 1] = colOffsets[c] + colWidths[c];
    }

    // 2) Tinggi baris dari teks yang membungkus pada lebar sel.
    final rowHeights = List<double>.filled(rows, _minRow);
    final pending = <List<dynamic>>[]; // [cell, height] untuk rowSpan > 1
    for (final row in cells) {
      for (final cell in row) {
        if (cell.covered) continue;
        final innerWidth =
            (colOffsets[math.min(cell.col + cell.colSpan, cols)] -
                colOffsets[cell.col]) -
            _hPad;
        double h =
            _measureHeight(_contentOf(cell), _styleFor(cell), innerWidth) +
            _vPad +
            (cell.isInput && !widget.readOnly ? 8 : 0);
        if (cell.rowSpan == 1) {
          if (h > rowHeights[cell.row]) rowHeights[cell.row] = h;
        } else {
          pending.add([cell, h]);
        }
      }
    }
    for (final item in pending) {
      final cell = item[0] as CaseStudyCellEntity;
      final h = item[1] as double;
      double have = 0;
      for (var r = cell.row; r < cell.row + cell.rowSpan && r < rows; r++) {
        have += rowHeights[r];
      }
      if (h > have) {
        final last = math.min(cell.row + cell.rowSpan - 1, rows - 1);
        rowHeights[last] += (h - have);
      }
    }
    final rowOffsets = List<double>.filled(rows + 1, 0);
    for (var r = 0; r < rows; r++) {
      rowOffsets[r + 1] = rowOffsets[r] + rowHeights[r];
    }

    // 3) Posisikan tiap sel.
    final children = <Widget>[];
    for (final row in cells) {
      for (final cell in row) {
        if (cell.covered) continue;
        final left = colOffsets[cell.col];
        final width =
            colOffsets[math.min(cell.col + cell.colSpan, cols)] - left;
        final top = rowOffsets[cell.row];
        final height =
            rowOffsets[math.min(cell.row + cell.rowSpan, rows)] - top;
        children.add(
          Positioned(
            left: left,
            top: top,
            width: width,
            height: height,
            child: _buildCell(cell),
          ),
        );
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: colOffsets[cols],
        height: rowOffsets[rows],
        child: Stack(children: children),
      ),
    );
  }

  Widget _buildCell(CaseStudyCellEntity cell) {
    final bg = _hexColor(cell.bg, AppColors.paper);
    final style = _styleFor(cell);

    Widget content;
    if (cell.isInput && !widget.readOnly) {
      content = TextField(
        controller: widget.controllerProvider?.call(cell),
        maxLines: null,
        textAlign: _textAlign(cell.align),
        style: style,
        cursorColor: AppColors.ink,
        decoration: InputDecoration(
          isDense: true,
          // Penting: matikan fill agar tidak mewarisi inputDecorationTheme gelap
          // dari tema dark (dulu membuat sel input tampak "pil hitam").
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: cell.text.isEmpty ? null : cell.text,
          hintStyle: const TextStyle(fontSize: 11, color: AppColors.inkFaint),
          contentPadding: EdgeInsets.zero,
        ),
      );
    } else {
      final text = cell.isInput ? _contentOf(cell) : cell.text;
      content = Text(
        cell.isInput && text.isEmpty ? '—' : text,
        style: style,
        textAlign: _textAlign(cell.align),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: const Color(0xFF9CA3AF), width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      alignment: _alignment(cell.align),
      child: content,
    );
  }
}
