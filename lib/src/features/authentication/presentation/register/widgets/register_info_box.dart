import 'package:flutter/material.dart';

/// Soft amber notice used to surface contextual hints (e.g. the AVPN pending
/// validation note) inside a registration step.
class RegisterInfoBox extends StatelessWidget {
  static const Color _background = Color(0xFFFFF7E8);
  static const Color _border = Color(0xFFF4C56A);
  static const Color _icon = Color(0xFFB97700);
  static const Color _text = Color(0xFF8A5A00);

  final String message;

  const RegisterInfoBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20, color: _icon),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12.5, color: _text, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
