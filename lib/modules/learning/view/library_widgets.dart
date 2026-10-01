import 'package:flutter/material.dart';

import 'bs_ui.dart';

/// Shared pieces of the 내 서재 screens (Figma 2.1 – 2.4.3).

/// Pushed 내 서재 page: back + "내 서재" top bar; [body] scrolls under the
/// home indicator, so lists add `MediaQuery.paddingOf(context).bottom`.
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Bs.bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const BsTopBar(title: '내 서재', showBack: true),
              Expanded(child: body),
            ],
          ),
        ),
      );
}

/// "유래혁" → "유래혁 저자"; already annotated author strings are kept.
String libraryAuthorLabel(String author) {
  final value = author.trim();
  if (value.isEmpty || value.endsWith('저자') || value.contains('(')) {
    return value;
  }
  return '$value 저자';
}

String libraryTitle(String title) =>
    title.trim().isEmpty ? '제목 없는 책' : title.trim();

/// Quiz progress in whole percent from a 0–100 rate.
int libraryPercent(double rate) => rate.isNaN ? 0 : rate.clamp(0, 100).round();

/// 100pt progress bar followed by "N% 진행"; the label moves under the bar
/// when large text leaves no room beside it.
class LibraryProgress extends StatelessWidget {
  const LibraryProgress({super.key, required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final style = Bs.text(12, color: Bs.g3);
    final label = '$percent% 진행';
    final bar = BsProgressBar(value: percent / 100, width: 100);
    return LayoutBuilder(builder: (context, constraints) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final fits = painter.width + 7 + 48 <= constraints.maxWidth;
      painter.dispose();
      final text = Text(label, style: style);
      return fits
          ? Row(children: [
              Flexible(child: bar),
              const SizedBox(width: 7),
              text,
            ])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [bar, const SizedBox(height: 4), text],
            );
    });
  }
}

/// Book row with a 92×132 cover (2.1 목록, 2.4 추천하는 책, 2.4.1 Completed).
class LibraryBookRow extends StatelessWidget {
  const LibraryBookRow({
    super.key,
    required this.title,
    required this.author,
    required this.cover,
    required this.semanticsLabel,
    required this.onTap,
    this.percent,
    this.titleMaxLines = 2,
    this.padding = const EdgeInsets.only(top: 17, bottom: 16),
  });

  final String title;
  final String author;
  final String cover;
  final String semanticsLabel;
  final VoidCallback onTap;
  final int? percent;
  final int titleMaxLines;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        button: true,
        label: semanticsLabel,
        onTap: onTap,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BsBookCover(url: cover, title: title, width: 92, height: 131),
                const SizedBox(width: 10),
                Expanded(
                  child: _BookText(
                    title: title,
                    author: author,
                    titleMaxLines: titleMaxLines,
                    percent: percent,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// 2열 grid cell: centered cover, then title, author and progress.
class LibraryBookCell extends StatelessWidget {
  const LibraryBookCell({
    super.key,
    required this.title,
    required this.author,
    required this.cover,
    required this.semanticsLabel,
    required this.onTap,
    required this.percent,
  });

  final String title;
  final String author;
  final String cover;
  final String semanticsLabel;
  final VoidCallback onTap;
  final int percent;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        button: true,
        label: semanticsLabel,
        onTap: onTap,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: BsBookCover(
                      url: cover, title: title, width: 92, height: 131)),
              const SizedBox(height: 15),
              _BookText(
                  title: title,
                  author: author,
                  titleMaxLines: 1,
                  authorGap: 3.5,
                  percent: percent),
            ],
          ),
        ),
      );
}

/// Compact search suggestion row with a 54×77 cover (2.4.1 Active).
class LibraryCompactBookRow extends StatelessWidget {
  const LibraryCompactBookRow({
    super.key,
    required this.title,
    required this.author,
    required this.cover,
    required this.semanticsLabel,
    required this.onTap,
  });

  final String title;
  final String author;
  final String cover;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        button: true,
        label: semanticsLabel,
        onTap: onTap,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(top: 11, bottom: 10.5),
            child: Row(
              children: [
                BsBookCover(url: cover, title: title, width: 54, height: 77),
                const SizedBox(width: 11),
                Expanded(
                  child: _BookText(
                      title: title,
                      author: author,
                      titleMaxLines: 1,
                      titleWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
}

class _BookText extends StatelessWidget {
  const _BookText({
    required this.title,
    required this.author,
    required this.titleMaxLines,
    this.percent,
    this.titleWeight = FontWeight.w600,
    this.authorGap = 2,
  });

  final String title;
  final String author;
  final int titleMaxLines;
  final int? percent;
  final FontWeight titleWeight;
  final double authorGap;

  @override
  Widget build(BuildContext context) {
    final authorLabel = libraryAuthorLabel(author);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            maxLines: titleMaxLines,
            overflow: TextOverflow.ellipsis,
            style: Bs.text(16, weight: titleWeight)),
        if (authorLabel.isNotEmpty) ...[
          SizedBox(height: authorGap),
          Text(authorLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Bs.text(14, color: Bs.g3)),
        ],
        if (percent != null) ...[
          const SizedBox(height: 8),
          LibraryProgress(percent: percent!),
        ],
      ],
    );
  }
}

/// "목록 ∨" / "2열 ∧" / "베스트셀러순 ∨" toggle with a 44pt tap area.
class LibraryToggle extends StatelessWidget {
  const LibraryToggle({
    super.key,
    required this.label,
    required this.expanded,
    required this.semanticsLabel,
    required this.onTap,
  });

  final String label;

  /// Shows the up chevron (second option) instead of the down chevron.
  final bool expanded;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        button: true,
        label: semanticsLabel,
        excludeSemantics: true,
        onTap: onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            padding: const EdgeInsets.only(right: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(label, style: Bs.text(14, color: Bs.g3)),
                const SizedBox(width: 5),
                BsIcon(expanded ? 'ic_chevron_up' : 'ic_chevron_down',
                    size: 14, color: Bs.g3),
              ],
            ),
          ),
        ),
      );
}

/// 18pt section title ("진행 중인 목차", "줄거리", "목차").
class LibrarySectionTitle extends StatelessWidget {
  const LibrarySectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Bs.text(18, weight: FontWeight.w600));
}

/// Title, author and the large centered cover of 2.2 목차선택 and 2.4.2 상세.
class LibraryBookHeader extends StatelessWidget {
  const LibraryBookHeader({
    super.key,
    required this.title,
    required this.author,
    required this.cover,
    this.trailing,
  });

  final String title;
  final String author;
  final String cover;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final authorLabel = libraryAuthorLabel(author);
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Bs.title),
        if (authorLabel.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(authorLabel, style: Bs.text(14, color: Bs.g3)),
        ],
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (trailing == null)
          heading
        else
          // The progress sits beside short titles and wraps below long ones.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [heading, trailing!],
          ),
        const SizedBox(height: 11),
        Center(
            child:
                BsBookCover(url: cover, title: title, width: 138, height: 197)),
      ],
    );
  }
}

/// Grey 61pt chapter row; [action] is the small 퀴즈풀기 / 다시풀기 button.
class LibraryChapterRow extends StatelessWidget {
  const LibraryChapterRow({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 61),
        padding: EdgeInsets.symmetric(
            horizontal: 16, vertical: action == null ? 16 : 6.5),
        decoration: BoxDecoration(
            color: Bs.surface, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Bs.text(16, weight: FontWeight.w600, color: Bs.g7)),
            ),
            if (action != null) ...[const SizedBox(width: 12), action!],
          ],
        ),
      );
}
