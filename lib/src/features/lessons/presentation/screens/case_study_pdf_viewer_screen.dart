import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Menampilkan PDF jawaban studi kasus secara in-app, dengan tombol unduh
/// (menyimpan ke penyimpanan aplikasi lalu membuka via aplikasi eksternal).
class CaseStudyPdfViewerScreen extends StatelessWidget {
  final Uint8List bytes;
  final String fileName;

  const CaseStudyPdfViewerScreen({
    super.key,
    required this.bytes,
    this.fileName = 'studi-kasus.pdf',
  });

  Future<void> _saveAndOpen(BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/$fileName';
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      final result = await OpenFilex.open(path);
      if (context.mounted && result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tersimpan di: $path')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jawaban (PDF)'),
        actions: [
          IconButton(
            tooltip: 'Unduh',
            icon: const Icon(Icons.download),
            onPressed: () => _saveAndOpen(context),
          ),
        ],
      ),
      body: SfPdfViewer.memory(bytes),
    );
  }
}
