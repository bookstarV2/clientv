import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

abstract final class LearningColors {
  static const paper = Colors.white;
  static const ink = Color(0xFF28262C);
  static const muted = Color(0xFF69656E);
  static const primary = Color(0xFF6049BE);
  static const lavender = Color(0xFFEFEBF7);
  static const line = Color(0xFFE6E6E6);
  static const surface = Color(0xFFF3F3F3);
  static const green = Color(0xFF267565);
  static const greenSoft = Color(0xFFEAF3EE);
  static const amber = Color(0xFF926029);
  static const amberSoft = Color(0xFFFAEFDC);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',
        brightness: Brightness.light,
        scaffoldBackgroundColor: paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          surface: paper,
          primary: primary,
          onSurface: ink,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: paper,
          foregroundColor: ink,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          elevation: 0,
          titleSpacing: 20,
          titleTextStyle: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: ink,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 54),
            textStyle: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: ink,
            minimumSize: const Size(48, 48),
            side: const BorderSide(color: line),
            textStyle: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            minimumSize: const Size(48, 48),
            textStyle: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: paper,
          selectedColor: lavender,
          side: const BorderSide(color: line),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          labelStyle: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              color: ink,
              fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const WidgetStatePropertyAll(ink),
            backgroundColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.selected) ? lavender : paper),
            side: const WidgetStatePropertyAll(BorderSide(color: line)),
            minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
            textStyle: const WidgetStatePropertyAll(TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: paper,
          surfaceTintColor: Colors.transparent,
          showDragHandle: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
        ),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: states.contains(WidgetState.selected) ? primary : muted,
              )),
          iconTheme: const WidgetStatePropertyAll(
              IconThemeData(size: 24, color: muted)),
        ),
        dividerTheme: const DividerThemeData(color: line, thickness: 1),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ink,
        ),
      );
}

class LearningPage extends StatelessWidget {
  const LearningPage({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.bottom,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) => Theme(
        data: LearningColors.theme,
        child: Scaffold(
          backgroundColor: LearningColors.paper,
          appBar: title == null
              ? null
              : AppBar(title: Text(title!), actions: actions),
          body: SafeArea(child: child),
          bottomNavigationBar: bottom == null
              ? null
              : SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: bottom,
                  ),
                ),
        ),
      );
}

class LearningCard extends StatelessWidget {
  const LearningCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.label,
    this.excludeChildSemantics = false,
    this.flat = false,
  }) : assert(!excludeChildSemantics || label != null);

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? label;

  /// Opt in only for one-action cards whose label describes all child content.
  /// Keep false for reading cards or cards containing independently tappable UI.
  final bool excludeChildSemantics;
  final bool flat;

  @override
  Widget build(BuildContext context) => Semantics(
        button: onTap != null || excludeChildSemantics,
        enabled: excludeChildSemantics ? onTap != null : null,
        onTap: onTap,
        label: label,
        excludeSemantics: excludeChildSemantics,
        child: Material(
          color: flat ? Colors.transparent : color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(flat ? 10 : 16),
            side: BorderSide(
                color: flat ? Colors.transparent : LearningColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
}

class BookCover extends StatelessWidget {
  const BookCover(
      {super.key, required this.url, required this.title, this.width = 62});

  final String url;
  final String title;
  final double width;

  @override
  Widget build(BuildContext context) => Semantics(
        image: true,
        label: '$title 표지',
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x1828262C), offset: Offset(1, 4), blurRadius: 7)
            ],
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: url.trim().isEmpty
                  ? _placeholder()
                  : CachedNetworkImage(
                      imageUrl: url,
                      width: width,
                      height: width * 1.45,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _placeholder(),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )),
        ),
      );

  Widget _placeholder() => Container(
        width: width,
        height: width * 1.45,
        decoration: const BoxDecoration(
          color: LearningColors.lavender,
          border: Border(left: BorderSide(color: Color(0xFFC5BADF), width: 4)),
        ),
        padding: const EdgeInsets.all(8),
        alignment: Alignment.topLeft,
        child: ExcludeSemantics(
            child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topLeft,
          child: SizedBox(
              width: width - 20,
              child: RichText(
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                      text: title,
                      style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: LearningColors.ink)))),
        )),
      );
}

class LearningLabel extends StatelessWidget {
  const LearningLabel(this.text,
      {super.key, this.color = LearningColors.muted});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6),
      );
}

class LearningEmpty extends StatelessWidget {
  const LearningEmpty({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.menu_book_rounded,
    this.action,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                  color: LearningColors.lavender, shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: LearningColors.primary),
            ),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: LearningColors.ink)),
            const SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, height: 1.6, color: LearningColors.muted)),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      );
}

class LearningError extends StatelessWidget {
  const LearningError(
      {super.key,
      required this.onRetry,
      this.message = '잠시 연결이 원활하지 않아요.\n다시 불러와 주세요.'});
  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) => LearningEmpty(
        title: '불러오지 못했어요',
        message: message,
        icon: Icons.cloud_off_rounded,
        action: FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('다시 불러오기'),
        ),
      );
}

const learningTitleStyle = TextStyle(
  fontSize: 27,
  fontWeight: FontWeight.w700,
  height: 1.28,
  letterSpacing: -0.6,
  color: LearningColors.ink,
);

const learningBodyStyle =
    TextStyle(fontSize: 15, height: 1.55, color: LearningColors.muted);
