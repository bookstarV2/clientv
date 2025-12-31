import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:gal/gal.dart';

/// 전체 화면 UI를 캡처하는 서비스
class FullCaptureService {
  /// RepaintBoundary Key를 받아 전체 화면을 이미지로 변환
  static Future<Uint8List?> captureWidget(GlobalKey boundaryKey,
      {double pixelRatio = 1.0}) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // 화면을 이미지로 변환
      final image = await boundary.toImage(pixelRatio: pixelRatio);

      // PNG byte로 변환
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      return byteData.buffer.asUint8List();
    } catch (e, st) {
      debugPrint('FullCaptureService.captureWidget error: $e\n$st');
      return null;
    }
  }

  /// 캡처한 이미지를 다이얼로그로 보여주는 헬퍼
  static Future<Map<String, dynamic>?> showCapturedImage(
      BuildContext context, Uint8List bytes) async {
    if (bytes.isEmpty) return null;

    return await showDialog(
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: ColorName.b1,
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () async {
                  await Gal.putImageBytes(bytes,
                      name:
                          "bookstar_${DateTime.now().millisecondsSinceEpoch}");
                  if (context.mounted) context.pop({'isSaved': true});
                },
                child: Text("저장",
                    style: AppTexts.b5.copyWith(color: ColorName.w1)),
              ),
            )
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: SizedBox(
                width: constraints.maxWidth,
                child: Image.memory(
                  bytes,
                  fit: BoxFit.fitWidth,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 캡처 + 다이얼로그 표시
  static Future<Map<String, dynamic>?> captureAndShow(
      BuildContext context, GlobalKey boundaryKey) async {
    final bytes = await captureWidget(boundaryKey);
    if (bytes != null && bytes.isNotEmpty && context.mounted) {
      return await showCapturedImage(context, bytes);
    }
    return null;
  }
}
