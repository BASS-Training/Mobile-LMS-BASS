import 'package:flutter/material.dart';

/// Widget untuk menampilkan kartu instruksi kuis
class InstructionCardWidget extends StatelessWidget {
  const InstructionCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 12),
              Text(
                'Instruksi Kuis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Baca pertanyaan dengan seksama dan pilih salah satu jawaban. Pastikan koneksi internet Anda stabil.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
