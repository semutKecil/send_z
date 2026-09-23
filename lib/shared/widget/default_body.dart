import 'package:flutter/material.dart';

class DefaultBody extends StatelessWidget {
  final Widget child;
  const new({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: child,
        ),
      ),
    );
  }
}
