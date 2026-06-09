import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Renders backend rich-text (HTML) content as cleanly formatted text.
///
/// Lesson material from the LMS comes as HTML (`<h1>`, `<h2>`, `<ul>`, `<li>`,
/// `<strong>`, `&nbsp;`, …). Showing it with a plain [Text] widget leaks the
/// raw tags, so we render it here with consistent, app-styled typography.
class HtmlContent extends StatelessWidget {
  final String html;

  const HtmlContent({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: html,
      // Trim the default surrounding whitespace so the content sits flush with
      // the card padding around it.
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(14),
          lineHeight: LineHeight(1.7),
          color: AppColors.slate,
        ),
        'h1': Style(
          margin: Margins.only(top: 8, bottom: 8),
          fontSize: FontSize(22),
          fontWeight: FontWeight.w800,
          lineHeight: LineHeight(1.25),
          color: AppColors.charcoal,
        ),
        'h2': Style(
          margin: Margins.only(top: 18, bottom: 8),
          fontSize: FontSize(18),
          fontWeight: FontWeight.w800,
          lineHeight: LineHeight(1.3),
          color: AppColors.charcoal,
        ),
        'h3': Style(
          margin: Margins.only(top: 14, bottom: 6),
          fontSize: FontSize(16),
          fontWeight: FontWeight.w700,
          lineHeight: LineHeight(1.35),
          color: AppColors.charcoal,
        ),
        'p': Style(
          margin: Margins.only(bottom: 12),
          fontSize: FontSize(14),
          lineHeight: LineHeight(1.85),
          color: AppColors.slate,
        ),
        'strong': Style(
          fontWeight: FontWeight.w700,
          color: AppColors.charcoal,
        ),
        'b': Style(
          fontWeight: FontWeight.w700,
          color: AppColors.charcoal,
        ),
        'ul': Style(
          margin: Margins.only(top: 4, bottom: 12, left: 4),
          padding: HtmlPaddings.only(left: 16),
        ),
        'ol': Style(
          margin: Margins.only(top: 4, bottom: 12, left: 4),
          padding: HtmlPaddings.only(left: 16),
        ),
        'li': Style(
          margin: Margins.only(bottom: 8),
          fontSize: FontSize(14),
          lineHeight: LineHeight(1.7),
          color: AppColors.slate,
        ),
        'a': Style(
          color: AppColors.red,
          textDecoration: TextDecoration.underline,
        ),
        'blockquote': Style(
          margin: Margins.only(top: 8, bottom: 12, left: 0),
          padding: HtmlPaddings.only(left: 14, top: 8, bottom: 8),
          border: const Border(
            left: BorderSide(color: AppColors.red, width: 3),
          ),
          backgroundColor: AppColors.peach.withValues(alpha: 0.35),
          fontStyle: FontStyle.italic,
          color: AppColors.charcoal,
        ),
      },
    );
  }
}
