import 'package:flutter/material.dart';

abstract class _Constants {
  static const double elevation = 4;
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double spacing = 8.0;
}

class TravelCard extends StatelessWidget {
  const TravelCard({
    required this.icon,
    required this.title,
    required this.children,
    this.header,
    this.iconColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final Widget? header;
  final List<Widget> children;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: _Constants.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_Constants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(_Constants.borderRadius),
              child: header,
            ),
          Padding(
            padding: const EdgeInsets.all(_Constants.padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  spacing: _Constants.spacing,
                  children: [
                    Icon(
                      icon,
                      color: iconColor ?? Theme.of(context).primaryColor,
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: _Constants.spacing),
                ...children,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
