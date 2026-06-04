import 'package:flutter/material.dart';

/// A thin, presentation-only text field for the registration form.
///
/// It owns the [TextEditingController] for its own text but pushes every change
/// out via [onChanged] and reads its [errorText] from the form state — so all
/// validation logic stays in the cubit.
class RegisterTextField extends StatefulWidget {
  final String initialValue;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  const RegisterTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    required this.onChanged,
    this.initialValue = '',
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<RegisterTextField> createState() => _RegisterTextFieldState();
}

class _RegisterTextFieldState extends State<RegisterTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon: widget.suffixIcon,
        errorText: widget.errorText,
      ),
    );
  }
}
