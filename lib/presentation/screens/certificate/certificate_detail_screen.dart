import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/config/theme.dart';
import 'package:lms_mobile_app/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/auth/auth_state.dart';

class CertificateDetailScreen extends StatelessWidget {
  final CourseEntity course;

  const CertificateDetailScreen({super.key, required this.course});

  String _issueDate() {
    //sementara static, nanti bisa diubah sesuai data yang didapat dari API
    return '6 Mei 2026';
  }

  @override
  Widget build(BuildContext context) {
    final holderName = context.select<AuthBloc, String>((bloc) {
      final state = bloc.state;
      if (state is AuthSuccess) return state.user.name;
      return 'User';
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Certificate Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionBox(
              title: 'Certificate Preview',
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.black45, width: 1),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 20,
                      top: 16,
                      child: Container(
                        width: 38,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(painter: _MountainPainter()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    text: 'Download',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur download akan segera hadir!'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionBtn(
                    text: 'Share',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur share akan segera hadir!'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionBox(
              title: 'Verified Certificate',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('Certificate Holder'),
                  _FieldValue(holderName),
                  const SizedBox(height: 10),
                  const _FieldLabel('Course Title'),
                  _FieldValue(course.title),
                  const SizedBox(height: 10),
                  const _FieldLabel('Issue Date'),
                  _FieldValue(_issueDate()),
                  const _FieldLabel('Expired'),
                  _FieldValue('6 Mei 2031'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionBox extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionBox({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black26),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black26)),
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 17, color: Colors.black),
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _ActionBtn({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, color: Colors.black),
    );
  }
}

class _FieldValue extends StatelessWidget {
  final String value;
  const _FieldValue(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade200,
      child: Text(
        value,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }
}

class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    final path1 = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..close();

    final path2 = Path()
      ..moveTo(size.width * 0.55, size.height)
      ..lineTo(size.width * 0.83, size.height * 0.58)
      ..lineTo(size.width, size.height * 0.72)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
