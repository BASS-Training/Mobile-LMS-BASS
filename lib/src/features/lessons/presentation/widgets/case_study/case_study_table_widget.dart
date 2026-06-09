import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';

/// Merender tabel studi kasus, menghormati merge (rowSpan/colSpan) memakai
/// Stack berposisi. Kolom berlebar sama; bila melebihi layar bisa di-scroll
/// horizontal.
class CaseStudyTableWidget extends StatelessWidget {
  final CaseStudyTableEntity table;
  final bool readOnly;

  /// Mengembalikan controller untuk sel input (mode edit). Null bila read-only.
  final TextEditingController Function(CaseStudyCellEntity cell)?
  controllerProvider;

  /// Nilai jawaban untuk sel input pada mode read-only.
  final String Function(CaseStudyCellEntity cell)? valueProvider;

  const CaseStudyTableWidget({
    super.key,
    required this.table,
    this.readOnly = false,
    this.controllerProvider,
    this.valueProvider,
  });

  static Color _hexColor(String hex, Color fallback) {
    var h = hex.replaceAll('#', '').trim();
    if (h.length == 6) h = 'FF$h';
    if (h.length != 8) return fallback;
    final value = int.tryParse(h, radix: 16);
    return value == null ? fallback : Color(value);
  }

  Alignment _alignment(String align) {
    switch (align) {
      case 'center':
        return Alignment.center;
      case 'right':
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final cols = table.cols;
    final rows = table.rows;
    if (cols == 0 || rows == 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        const rowHeight = 60.0;
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;
        final cellWidth = (maxWidth / cols) < 110.0
            ? 110.0
            : (maxWidth / cols);

        final children = <Widget>[];
        for (final row in table.cells) {
          for (final cell in row) {
            if (cell.covered) continue;
            children.add(
              Positioned(
                left: cell.col * cellWidth,
                top: cell.row * rowHeight,
                width: cell.colSpan * cellWidth,
                height: cell.rowSpan * rowHeight,
                child: _buildCell(cell),
              ),
            );
          }
        }

        final grid = SizedBox(
          width: cols * cellWidth,
          height: rows * rowHeight,
          child: Stack(children: children),
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: grid,
        );
      },
    );
  }

  Widget _buildCell(CaseStudyCellEntity cell) {
    final bg = _hexColor(cell.bg, Colors.white);
    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: cell.bold ? FontWeight.bold : FontWeight.normal,
      color: const Color(0xFF1F2937),
    );

    Widget content;
    if (cell.isInput) {
      if (readOnly) {
        final value = valueProvider?.call(cell) ?? '';
        content = Text(
          value.isEmpty ? '—' : value,
          style: textStyle,
          textAlign: _textAlign(cell.align),
        );
      } else {
        content = TextField(
          controller: controllerProvider?.call(cell),
          maxLines: null,
          textAlign: _textAlign(cell.align),
          style: textStyle,
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: cell.text.isEmpty ? null : cell.text,
            hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            contentPadding: EdgeInsets.zero,
          ),
        );
      }
    } else {
      content = Text(
        cell.text,
        style: textStyle,
        textAlign: _textAlign(cell.align),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: const Color(0xFF9CA3AF), width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      alignment: _alignment(cell.align),
      child: SingleChildScrollView(child: content),
    );
  }
}
