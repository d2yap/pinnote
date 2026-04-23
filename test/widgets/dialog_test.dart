import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinnote/widgets/confirm_action_dialog.dart';

// Arrange
Widget buildDialog({
  String title = 'Test Title',
  String content = 'Test Content',
  String confirmLabel = 'Confirm',
  VoidCallback? onConfirm,
  Color confirmColor = Colors.red,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ConfirmActionDialog(
          title: title,
          content: content,
          confirmLabel: confirmLabel,
          onConfirm: onConfirm ?? () {},
          confirmColor: confirmColor,
        ),
      ),
    ),
  );
}

void main() {
  group('ConfirmActionDialog', () {
    testWidgets('renders title and content', (tester) async {
      // Arrange / Act
      await tester.pumpWidget(
        buildDialog(
          title: 'Delete Pin',
          content: 'This will permanently delete your pin.',
        ),
      );

      // Assert
      expect(find.text('Delete Pin'), findsOneWidget);
      expect(
        find.text('This will permanently delete your pin.'),
        findsOneWidget,
      );
    });

    testWidgets('renders confirm label', (tester) async {
      // Arrange / Act
      await tester.pumpWidget(buildDialog(confirmLabel: 'Delete'));

      // Assert
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('renders cancel button', (tester) async {
      // Arrange / Act
      await tester.pumpWidget(buildDialog());

      // Assert
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('confirm button has correct color', (tester) async {
      // Arrange
      await tester.pumpWidget(buildDialog(confirmColor: Colors.blue));

      // Act
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style!.backgroundColor!.resolve({});

      // Assert
      expect(style, Colors.blue);
    });
  });
}
