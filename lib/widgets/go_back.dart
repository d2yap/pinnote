import 'package:flutter/material.dart';

class GoBack extends StatelessWidget {
  const GoBack({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        'Go back',
        style: TextStyle(fontFamily: 'Clash', color: Colors.black),
      ),
    );
  }
}
