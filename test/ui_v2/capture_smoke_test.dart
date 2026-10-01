import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:bookstar/modules/learning/view/learning_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_v2_capture.dart';

void main() {
  setUpAll(setUpBsCapture);

  testWidgets('capture smoke', (tester) async {
    await captureBsScreen(
      tester,
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Bs.bg,
          extendBody: true,
          body: BsScaffold(
            title: '내 서재',
            trailing: BsTopBarAction(
                icon: 'ic_add_book', tooltip: '책 추가', onPressed: () {}),
            body: ListView(padding: Bs.pagePadding, children: [
              const SizedBox(height: 24),
              Text('읽고 떠올린 것이\n하나의 세계로', style: Bs.headline),
              const SizedBox(height: 24),
              const BsEmptyState(message: '아직 읽고 있는 책이 없어요'),
              const SizedBox(height: 24),
              BsQuizCard(question: '민지가 다음 날 책을 펼치기 전에 한 행동은 무엇인가요?', options: [
                BsOptionTile(
                    text: '읽은 쪽수를 세었어요',
                    state: BsOptionState.selected,
                    onTap: () {}),
                BsOptionTile(
                    text: '기억한 내용을 자기 말로 떠올렸어요',
                    state: BsOptionState.answer,
                    onTap: () {}),
              ]),
            ]),
          ),
          bottomNavigationBar: BsNavBar(currentIndex: 1, onTap: (_) {}),
        ),
      ),
      'smoke',
    );
  });
}
