import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_text_layout/super_text_layout.dart';

import '../test_tools.dart';

void main() {
  group("SuperTextField", () {
    group("configures for", () {
      group("desktop", () {
        testWidgets("automatically", (tester) async {
          debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

          await tester.pumpWidget(
            _buildScaffold(
              child: const SuperTextField(),
            ),
          );

          expect(find.byType(SuperDesktopTextField), findsOneWidget);

          debugDefaultTargetPlatformOverride = null;
        });

        testWidgets("when requested", (tester) async {
          await tester.pumpWidget(
            _buildScaffold(
              child: const SuperTextField(
                configuration: SuperTextFieldPlatformConfiguration.desktop,
              ),
            ),
          );

          expect(find.byType(SuperDesktopTextField), findsOneWidget);
        });
      });

      group("android", () {
        testWidgets("automatically", (tester) async {
          debugDefaultTargetPlatformOverride = TargetPlatform.android;

          await tester.pumpWidget(
            _buildScaffold(
              child: const SuperTextField(),
            ),
          );

          expect(find.byType(SuperAndroidTextField), findsOneWidget);

          debugDefaultTargetPlatformOverride = null;
        });

        testWidgets("when requested", (tester) async {
          await tester.pumpWidget(
            _buildScaffold(
              child: const SuperTextField(
                configuration: SuperTextFieldPlatformConfiguration.android,
              ),
            ),
          );

          expect(find.byType(SuperAndroidTextField), findsOneWidget);
        });
      });

      group("iOS", () {
        testWidgets("automatically", (tester) async {
          debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

          await tester.pumpWidget(
            _buildScaffold(
              child: const SuperTextField(),
            ),
          );

          expect(find.byType(SuperIOSTextField), findsOneWidget);

          debugDefaultTargetPlatformOverride = null;
        });

        testWidgets("when requested", (tester) async {
          await tester.pumpWidget(
            _buildScaffold(
              child: const SuperTextField(
                configuration: SuperTextFieldPlatformConfiguration.iOS,
              ),
            ),
          );

          expect(find.byType(SuperIOSTextField), findsOneWidget);
        });
      });
    });

    group("on mobile", () {
      group("configures inner textfield textInputAction for newline when it's multiline", () {
        testWidgetsOnAndroid('(on Android)', (tester) async {
          await tester.pumpWidget(
            _buildScaffold(
              child: const SuperTextField(
                minLines: 10,
                maxLines: 10,
              ),
            ),
          );

          final innerTextField = tester.widget<SuperAndroidTextField>(find.byType(SuperAndroidTextField).first);

          // Ensure inner textfield action is configured to newline
          // so we are able to receive new lines
          expect(innerTextField.textInputAction, TextInputAction.newline);
        });

        testWidgetsOnIos('(on iOS)', (tester) async {
          await tester.pumpWidget(
            _buildScaffold(
              child: const SuperTextField(
                minLines: 10,
                maxLines: 10,
              ),
            ),
          );

          final innerTextField = tester.widget<SuperIOSTextField>(find.byType(SuperIOSTextField).first);

          // Ensure inner textfield action is configured to newline
          // so we are able to receive new lines
          expect(innerTextField.textInputAction, TextInputAction.newline);
        });
      });

      group("configures inner textfield textInputAction for done when it's singleline", () {
        testWidgetsOnAndroid('(on Android)', (tester) async {
          await tester.pumpWidget(
            _buildScaffold(
              child: const SuperTextField(
                minLines: 1,
                maxLines: 1,
              ),
            ),
          );

          final innerTextField = tester.widget<SuperAndroidTextField>(find.byType(SuperAndroidTextField).first);

          // Ensure inner textfield action is configured to done
          // because we should NOT receive new lines
          expect(innerTextField.textInputAction, TextInputAction.done);
        });

        testWidgetsOnIos('(on iOS)', (tester) async {
          await tester.pumpWidget(
            _buildScaffold(
              child: const SuperTextField(
                minLines: 1,
                maxLines: 1,
              ),
            ),
          );

          final innerTextField = tester.widget<SuperIOSTextField>(find.byType(SuperIOSTextField).first);

          // Ensure inner textfield action is configured to done
          // because we should NOT receive new lines
          expect(innerTextField.textInputAction, TextInputAction.done);
        });
      });
    });

    group("selection", () {
      testWidgetsOnAllPlatforms("is inserted automatically when the field is initialized with focus", (tester) async {
        await tester.pumpWidget(
          _buildScaffold(
            child: SuperTextField(
              focusNode: FocusNode()..requestFocus(),
            ),
          ),
        );
        await tester.pump();

        expect(_isCaretPresent(tester), isTrue);
      });

      testWidgetsOnAllPlatforms("is inserted automatically when the field is given focus", (tester) async {
        final focusNode = FocusNode();
        await tester.pumpWidget(
          _buildScaffold(
            child: SuperTextField(
              focusNode: focusNode,
            ),
          ),
        );
        await tester.pump();

        expect(_isCaretPresent(tester), isFalse);

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        expect(_isCaretPresent(tester), isTrue);
      });
    });

    group('padding', () {
      testWidgetsOnAllPlatforms('is applied when configured', (tester) async {
        await tester.pumpWidget(
          _buildScaffold(
            child: const SuperTextField(
              padding: EdgeInsets.fromLTRB(5, 10, 15, 20),
              minLines: 1,
              maxLines: 2,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final textFieldRect = tester.getRect(find.byType(SuperTextField));
        final contentRect = tester.getRect(find.byType(SuperTextWithSelection));

        // Ensure padding was applied.
        expect(contentRect.left - textFieldRect.left, 5);
        expect(contentRect.top - textFieldRect.top, 10);
        expect(textFieldRect.right - contentRect.right, 15);
        expect(textFieldRect.bottom - contentRect.bottom, 20);
      });
    });
  });
}

Widget _buildScaffold({
  required Widget child,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 300,
        child: child,
      ),
    ),
  );
}

bool _isCaretPresent(WidgetTester tester) {
  final caretMatches = find.byType(TextLayoutCaret).evaluate();
  if (caretMatches.isEmpty) {
    return false;
  }
  final caretState = (caretMatches.single as StatefulElement).state as TextLayoutCaretState;
  return caretState.isCaretPresent;
}
