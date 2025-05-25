import 'package:flutter/cupertino.dart';

abstract class _Constants {
  static const padding = EdgeInsets.all(16);
}

class TravelFormStepLayout extends StatelessWidget {
  const TravelFormStepLayout({required this.children, this.spacing = 0, super.key});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: _Constants.padding,
      child: Column(
        spacing: spacing,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
