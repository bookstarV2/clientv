import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// UI v2 design tokens taken from the Figma `UI_v2` color/text styles
/// (docs/디자인). Screens of the learning module should use these instead of
/// hard-coded values.
abstract final class Bs {
  static const white = Color(0xFFFFFFFF); // W1
  static const bg = Color(0xFFFAFAFA); // W2 – screen background
  static const surface = Color(0xFFEFF0F2); // W3 – cards, fields, chips
  static const g1 = Color(0xFFD4D9DD);
  static const g2 = Color(0xFFBCC2C6); // disabled text, back chevron
  static const g3 = Color(0xFF6B6B75); // secondary text / icons
  static const g4 = Color(0xFF5C5C6A);
  static const g5 = Color(0xFF4C4C57);
  static const g6 = Color(0xFF393942);
  static const g7 = Color(0xFF2D2D33);
  static const black = Color(0xFF191919); // B1 – primary text
  static const primary = Color(0xFF775DFF); // P1
  static const primarySoft = Color(0xFFD7D3F5); // selected answer background
  static const primaryTint = Color(0xFFEFECFD); // lavender pill / chip
  static const placeholder = Color(0xFFD9D9D9);
  static const kakao = Color(0xFFFEE500);
  static const dim = Color(0x99000000);
  static const gradientEnd = Color(0xFFE6E1FF);

  static const font = 'Pretendard';

  static TextStyle text(double size,
          {FontWeight weight = FontWeight.w400,
          Color color = black,
          double height = 1.45,
          double letterSpacing = -0.2}) =>
      TextStyle(
        fontFamily: font,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// H4 24/145 bold – rarely used large headline.
  static TextStyle get h4 => text(24, weight: FontWeight.w700);

  /// B0 22/145 semibold – hero titles ("읽은 책이 오래 기억되도록").
  static TextStyle get headline => text(22, weight: FontWeight.w600);

  /// B1 20/145 semibold – section heroes / sheet titles.
  static TextStyle get title => text(20, weight: FontWeight.w600);

  /// B3 18/140 bold – quiz question, book title.
  static TextStyle get subtitle =>
      text(18, weight: FontWeight.w600, height: 1.4);

  /// B5 16/145 – top bar title, buttons, list titles.
  static TextStyle get body1 => text(16, weight: FontWeight.w500);

  /// B7 14/150 – body text.
  static TextStyle get body2 => text(14, height: 1.5);

  /// B9 12/160 – captions.
  static TextStyle get caption => text(12, height: 1.6, color: g3);

  static const pagePadding = EdgeInsets.symmetric(horizontal: 16);
  static const radius = 12.0;
  static const buttonRadius = 10.0;
}

/// Monochrome icon exported from the Figma design (assets/images/learning).
class BsIcon extends StatelessWidget {
  const BsIcon(this.name, {super.key, this.size = 24, this.color});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/images/learning/$name.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        color: color,
        colorBlendMode: color == null ? null : BlendMode.srcIn,
        excludeFromSemantics: true,
      );
}

enum BsCharacter { books, cloud, dizzy }

/// Purple BookStar characters used across empty states and bottom sheets.
class BsCharacterImage extends StatelessWidget {
  const BsCharacterImage(this.character, {super.key, this.width});

  final BsCharacter character;
  final double? width;

  @override
  Widget build(BuildContext context) => switch (character) {
        BsCharacter.books => SvgPicture.asset(
            'assets/images/learning/char_books.svg',
            width: width ?? 112,
            excludeFromSemantics: true),
        BsCharacter.cloud => Image.asset(
            'assets/images/learning/char_cloud.png',
            width: width ?? 82,
            excludeFromSemantics: true),
        BsCharacter.dizzy => Image.asset(
            'assets/images/learning/char_dizzy.png',
            width: width ?? 82,
            excludeFromSemantics: true),
      };
}

/// Top bar of every v2 screen: 56pt high, centered 16pt title, optional grey
/// back chevron on the left and a single icon action on the right.
class BsTopBar extends StatelessWidget implements PreferredSizeWidget {
  const BsTopBar({
    super.key,
    this.title,
    this.showBack = false,
    this.onBack,
    this.trailing,
    this.titleStyle,
  });

  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;
  final TextStyle? titleStyle;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: Text(title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle ?? Bs.text(16, weight: FontWeight.w600)),
              ),
            if (showBack)
              Positioned(
                left: 4,
                top: 2,
                child: IconButton(
                  tooltip: '뒤로',
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  icon: const BsIcon('ic_back', size: 24, color: Bs.g2),
                ),
              ),
            if (trailing != null)
              Positioned(right: 4, top: 2, child: trailing!),
          ],
        ),
      );
}

/// Icon button used as the right action of [BsTopBar].
class BsTopBarAction extends StatelessWidget {
  const BsTopBarAction(
      {super.key,
      required this.icon,
      required this.tooltip,
      required this.onPressed,
      this.color = Bs.g3});

  final String icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: BsIcon(icon, size: 24, color: color),
      );
}

/// Scaffold with the v2 background, [BsTopBar] and an optional bottom area
/// (usually a [BsPrimaryButton]) pinned above the home indicator.
class BsScaffold extends StatelessWidget {
  const BsScaffold({
    super.key,
    required this.body,
    this.title,
    this.showBack = false,
    this.onBack,
    this.trailing,
    this.bottom,
    this.backgroundColor = Bs.bg,
    this.bottomGradient = false,
  });

  final Widget body;
  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget? bottom;
  final Color backgroundColor;

  /// Lavender gradient behind the bottom buttons on answer screens.
  final bool bottomGradient;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: backgroundColor,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: bottomGradient
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.62, 1],
                    colors: [Bs.bg, Bs.bg, Bs.gradientEnd],
                  )
                : null,
          ),
          child: SafeArea(
            // Without a bottom bar the body runs under the home indicator as
            // in the Figma frames; scrolling bodies add the bottom inset to
            // their own end padding instead.
            bottom: bottom != null,
            child: Column(
              children: [
                BsTopBar(
                    title: title,
                    showBack: showBack,
                    onBack: onBack,
                    trailing: trailing),
                Expanded(child: body),
                if (bottom != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: bottom,
                  ),
              ],
            ),
          ),
        ),
      );
}

/// Full-width 56pt primary CTA (e.g. "내 책으로 퀴즈 풀기", "정답 확인하기").
class BsPrimaryButton extends StatelessWidget {
  const BsPrimaryButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.loading = false,
      this.height = 56});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          backgroundColor: enabled ? Bs.primary : Bs.surface,
          disabledBackgroundColor: Bs.surface,
          foregroundColor: Bs.white,
          disabledForegroundColor: Bs.g2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Bs.buttonRadius)),
          textStyle: Bs.text(16, weight: FontWeight.w600, height: 1.15),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: Bs.primary))
            : Text(label),
      ),
    );
  }
}

/// White 56pt button with purple label (e.g. "이 퀴즈 다시 풀기", "취소").
class BsSecondaryButton extends StatelessWidget {
  const BsSecondaryButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.height = 56,
      this.expand = true});

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: expand ? double.infinity : null,
        height: height,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: Bs.white,
            foregroundColor: Bs.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Bs.buttonRadius)),
            textStyle: Bs.text(16, weight: FontWeight.w600, height: 1.15),
          ),
          child: Text(label),
        ),
      );
}

/// Small 29pt button inside chapter rows (Figma 2.2 "퀴즈풀기" filled,
/// "다시풀기" white). The tap target is padded to 48pt.
class BsSmallButton extends StatelessWidget {
  const BsSmallButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.filled = true});

  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 29),
          padding: const EdgeInsets.symmetric(horizontal: 11),
          tapTargetSize: MaterialTapTargetSize.padded,
          visualDensity: VisualDensity.standard,
          backgroundColor: filled ? Bs.primary : Bs.white,
          foregroundColor: filled ? Bs.white : Bs.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: Bs.text(14, weight: FontWeight.w500, height: 1.2),
        ),
        child: Text(label),
      );
}

/// Pill chip of Figma 2.1 "읽는중 책 / 완독한 책": 34pt pill inside a 44pt
/// tap area.
class BsChip extends StatelessWidget {
  const BsChip(
      {super.key,
      required this.label,
      required this.selected,
      required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _selectedFill = Color(0xFFE0DBFB);
  static const _selectedBorder = Color(0xFF8E79FF);

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Container(
              constraints: const BoxConstraints(minHeight: 34),
              padding: const EdgeInsets.symmetric(horizontal: 11.5),
              decoration: ShapeDecoration(
                color: selected ? _selectedFill : Bs.surface,
                shape: StadiumBorder(
                    side: BorderSide(
                        color:
                            selected ? _selectedBorder : Colors.transparent)),
              ),
              child: Center(
                widthFactor: 1,
                child: Text(label,
                    style: Bs.text(14,
                        weight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected ? Bs.primary : Bs.g2)),
              ),
            ),
          ),
        ),
      );
}

/// Thin rounded progress bar (Figma: #8E79FF fill on a W3 track).
class BsProgressBar extends StatelessWidget {
  const BsProgressBar(
      {super.key,
      required this.value,
      this.height = 4,
      this.width,
      this.color = fill});

  static const fill = Color(0xFF8E79FF);

  final double value;
  final double height;
  final double? width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height);
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Bs.surface, borderRadius: radius),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0, 1).toDouble(),
          child: DecoratedBox(
              decoration: BoxDecoration(color: color, borderRadius: radius)),
        ),
      ),
    );
  }
}

/// Book cover with the Figma 1pt W3 outline; falls back to a lavender block
/// showing the title.
class BsBookCover extends StatelessWidget {
  const BsBookCover(
      {super.key,
      required this.url,
      required this.title,
      this.width = 60,
      this.height,
      this.radius = 2});

  final String url;
  final String title;
  final double width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final h = height ?? width * 1.43;
    final placeholder = Container(
      width: width,
      height: h,
      color: Bs.primaryTint,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      child: Text(title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Bs.text(11, weight: FontWeight.w600, color: Bs.g5)),
    );
    return Semantics(
      image: true,
      label: '$title 표지',
      child: Container(
        width: width,
        height: h,
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: Bs.surface),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: url.trim().isEmpty
              ? placeholder
              : CachedNetworkImage(
                  imageUrl: url,
                  width: width,
                  height: h,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => placeholder,
                  errorWidget: (_, __, ___) => placeholder,
                ),
        ),
      ),
    );
  }
}

/// Empty state: character + grey centered message (+ optional action).
class BsEmptyState extends StatelessWidget {
  const BsEmptyState(
      {super.key,
      required this.message,
      this.character = BsCharacter.dizzy,
      this.action,
      this.characterWidth});

  final String message;
  final BsCharacter character;
  final Widget? action;
  final double? characterWidth;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BsCharacterImage(character, width: characterWidth),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: Bs.text(14, color: Bs.g6, height: 1.5)),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      );
}

/// Bottom sheet used for "사용안내", "퀴즈 오류 신고", "신고 접수" (Figma
/// 0.2.4 / 2.3.1): white, 26pt top radius, close button, cloud character,
/// 20pt title, body and a primary CTA.
Future<T?> showBsSheet<T>(
  BuildContext context, {
  required String title,
  Widget? body,
  String? message,
  required String primaryLabel,
  required VoidCallback onPrimary,
  BsCharacter character = BsCharacter.cloud,
  bool isDismissible = true,
}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      useRootNavigator: true,
      backgroundColor: Bs.white,
      barrierColor: Bs.dim,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BsCharacterImage(character, width: 82),
                    const SizedBox(height: 20.5),
                    Text(title,
                        style: Bs.text(20,
                            weight: FontWeight.w600, letterSpacing: 0)),
                    if (message != null) ...[
                      const SizedBox(height: 12),
                      Text(message,
                          style: Bs.text(16,
                              weight: FontWeight.w500,
                              color: Bs.g7,
                              height: 1.5)),
                    ],
                    if (body != null) ...[const SizedBox(height: 12), body],
                    const SizedBox(height: 28),
                    BsPrimaryButton(label: primaryLabel, onPressed: onPrimary),
                  ],
                ),
              ),
              Positioned(
                top: 14,
                right: 6,
                child: IconButton(
                  tooltip: '닫기',
                  style: IconButton.styleFrom(
                    fixedSize: const Size(44, 44),
                    minimumSize: const Size(44, 44),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const BsIcon('ic_close', size: 16, color: Bs.g3),
                ),
              ),
            ],
          ),
        ),
      ),
    );

/// Centered dialog (Figma 4.2.1 "이 지도를 이미지로 공유할까요?").
Future<bool?> showBsConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = '취소',
  BsCharacter character = BsCharacter.cloud,
}) =>
    showDialog<bool>(
      context: context,
      barrierColor: Bs.dim,
      useRootNavigator: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Bs.bg,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.fromLTRB(21.5, 25, 21.5, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BsCharacterImage(character, width: 82),
              const SizedBox(height: 16.5),
              Text(title,
                  textAlign: TextAlign.center,
                  style: Bs.text(18,
                      weight: FontWeight.w700, height: 1.4, letterSpacing: 0)),
              const SizedBox(height: 7),
              Text(message,
                  textAlign: TextAlign.center,
                  style:
                      Bs.text(14, color: Bs.g7, height: 1.5, letterSpacing: 0)),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: BsSecondaryButton(
                        label: cancelLabel,
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BsPrimaryButton(
                        label: confirmLabel,
                        onPressed: () => Navigator.of(dialogContext).pop(true)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

enum BsOptionState { idle, selected, answer, dimmed }

/// Answer option row inside [BsQuizCard] (Figma 0.2.2 / 2.3 / 3.2): white
/// 50pt tile; lavender with a check when selected; purple ring on the answer.
class BsOptionTile extends StatelessWidget {
  const BsOptionTile(
      {super.key,
      required this.text,
      required this.state,
      this.onTap,
      this.semanticsLabel});

  final String text;
  final BsOptionState state;
  final VoidCallback? onTap;

  /// Replaces the announced label (defaults to the text, "정답, …" on answers).
  final String? semanticsLabel;

  static const selectedTextColor = Color(0xFF44339C);

  @override
  Widget build(BuildContext context) {
    final selected = state == BsOptionState.selected;
    final textColor = switch (state) {
      BsOptionState.selected => selectedTextColor,
      BsOptionState.dimmed => Bs.g2,
      _ => Bs.g6,
    };
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semanticsLabel ??
          (state == BsOptionState.answer ? '정답, $text' : text),
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: selected ? Bs.primarySoft : Bs.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Bs.radius),
          side: BorderSide(
              color: selected ? Bs.primary : Colors.transparent, width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Bs.radius),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 15, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(text,
                        style: Bs.text(16,
                            weight:
                                selected ? FontWeight.w600 : FontWeight.w500,
                            color: textColor,
                            height: 1.4,
                            letterSpacing: 0)),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    Image.asset('assets/images/learning/ic_check_selected.png',
                        width: 26, height: 26, excludeFromSemantics: true),
                  ],
                  if (state == BsOptionState.answer) ...[
                    const SizedBox(width: 8),
                    const BsIcon('ic_answer_ring', size: 24, color: Bs.primary),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Grey rounded container holding a "Q" question and its options.
class BsQuizCard extends StatelessWidget {
  const BsQuizCard({super.key, required this.question, required this.options});

  final String question;
  final List<Widget> options;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        decoration: BoxDecoration(
            color: Bs.surface, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text('Q',
                        style: Bs.text(18,
                            weight: FontWeight.w600,
                            color: Bs.primary,
                            height: 1.4,
                            letterSpacing: 0)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(question,
                          style: Bs.text(18,
                              weight: FontWeight.w600,
                              color: Bs.g7,
                              height: 1.4,
                              letterSpacing: 0))),
                ],
              ),
            ),
            for (final (index, option) in options.indexed) ...[
              if (index > 0) const SizedBox(height: 12),
              option,
            ],
          ],
        ),
      );
}

/// White "왜 정답인가요?" explanation card.
class BsExplanationCard extends StatelessWidget {
  const BsExplanationCard(
      {super.key, required this.body, this.title = '왜 정답인가요?'});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 17, 16, 17),
        decoration: BoxDecoration(
            color: Bs.white, borderRadius: BorderRadius.circular(Bs.radius)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Bs.text(16,
                    weight: FontWeight.w600, color: Bs.g7, letterSpacing: 0)),
            const SizedBox(height: 8),
            Text(body,
                style: Bs.text(14,
                    weight: FontWeight.w500,
                    color: Bs.g5,
                    height: 1.5,
                    letterSpacing: 0)),
          ],
        ),
      );
}

/// Page/carousel indicator (Figma 1.1 메인): the active item is a 20×8
/// lavender pill, the others 8pt grey dots, 4pt apart.
class BsPageDots extends StatelessWidget {
  const BsPageDots(
      {super.key,
      required this.count,
      required this.index,
      this.activeColor = const Color(0xFF8E79FF)});

  final int count;
  final int index;
  final Color activeColor;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$count개 중 ${index + 1}번째',
        excludeSemantics: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
                width: i == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == index ? activeColor : Bs.g1,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      );
}
