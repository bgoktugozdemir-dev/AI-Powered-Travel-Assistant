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
    required this.child,
    this.header,
    super.key,
  });

  final IconData icon;
  final String title;
  final Widget? header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: _Constants.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_Constants.borderRadius),
      ),
      child: Column(
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
                  children: [
                    Icon(icon, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const Divider(),
                const SizedBox(height: _Constants.spacing),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
