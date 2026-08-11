import 'package:flutter/material.dart';

/// Pixelify Sans'ta rakam "5" harf "S" ile aynı glyph'i paylaşıyor (font
/// tasarımı, düzeltilemez). Bu widget metindeki rakam dizilerini
/// "Silkscreen" fontuyla (rakamları net ayırt edilebilir), geri kalanını
/// miras alınan stille çizer.
class NumberText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const NumberText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  static final _digitRun = RegExp(r'\d+');

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style.merge(style);
    final spans = <TextSpan>[];
    var last = 0;
    for (final match in _digitRun.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      spans.add(TextSpan(text: match.group(0), style: const TextStyle(fontFamily: 'Silkscreen')));
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return RichText(
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(style: base, children: spans),
    );
  }
}
