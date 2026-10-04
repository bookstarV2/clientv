import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/reading_graph.dart';
import 'bs_ui.dart';
import 'reading_graph_canvas.dart';

/// "독서 지도 / N권에서 쌓인 N개의 생각" header + map card used on
/// the 독서 지도 tab (4.1).
class ReadingMapPreview extends ConsumerWidget {
  const ReadingMapPreview({super.key, this.mapHeight = 300, this.onOpen});

  /// Height of the white map card below the header.
  final double mapHeight;

  /// Called when the map card is tapped (e.g. open the 독서 지도 tab).
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readingGraphProvider);
    final retrying = state.hasError;
    final title = state.when(
      skipLoadingOnRefresh: !retrying,
      data: (graph) => graph.nodes.isEmpty
          ? '아직 읽은 책이 없어요'
          : '${graph.books.length}권에서 쌓인 ${graph.questionCount}개의 생각',
      error: (_, __) => '지도를 불러오지 못했어요',
      loading: () => '',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('독서 지도', style: Bs.text(16, color: Bs.g3)),
        const SizedBox(height: 8),
        Text(title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Bs.text(18,
                weight: FontWeight.w700, height: 1.4, letterSpacing: 0)),
        const SizedBox(height: 12),
        Container(
          height: mapHeight,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: Bs.white, borderRadius: BorderRadius.circular(18)),
          child: state.when(
            skipLoadingOnRefresh: !retrying,
            loading: () => const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: Bs.primary)),
            error: (_, __) => ReadingMapMessage(
              message: '기록이 사라진 것은 아니에요.\n연결을 확인하고 다시 불러와 주세요.',
              actionLabel: '다시 불러오기',
              onAction: () => ref.invalidate(readingGraphProvider),
            ),
            data: (graph) => graph.nodes.isEmpty
                ? const ReadingMapMessage.empty()
                : Semantics(
                    button: onOpen != null,
                    onTapHint: '독서 지도 전체 보기',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onOpen,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                        child: ReadingGraphCanvas(
                            graph: graph, interactive: false),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Character + message + small purple button shown inside the map card when
/// there is nothing to draw (4.1 Empty) or the map failed to load.
class ReadingMapMessage extends StatelessWidget {
  const ReadingMapMessage(
      {super.key,
      required this.message,
      required this.actionLabel,
      required this.onAction});

  const ReadingMapMessage.empty({super.key})
      : message = '책을 추가하고 퀴즈를 풀어\n나만의 지도를 만들어 보세요!',
        actionLabel = '책 추가하기',
        onAction = null;

  final String message;
  final String actionLabel;

  /// Defaults to opening 내 서재 to add a book.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Align(
        alignment: const Alignment(0, -.045),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BsCharacterImage(BsCharacter.dizzy, width: 82),
              const SizedBox(height: 13.5),
              Text(message,
                  textAlign: TextAlign.center,
                  style:
                      Bs.text(14, color: Bs.g7, height: 1.5, letterSpacing: 0)),
              const SizedBox(height: 13.5),
              SizedBox(
                width: 200,
                height: 37,
                child: TextButton(
                  onPressed: onAction ?? () => context.go('/library'),
                  style: TextButton.styleFrom(
                    backgroundColor: Bs.primary,
                    foregroundColor: Bs.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    textStyle: Bs.text(14, weight: FontWeight.w600),
                  ),
                  child: Text(actionLabel),
                ),
              ),
            ],
          ),
        ),
      );
}
