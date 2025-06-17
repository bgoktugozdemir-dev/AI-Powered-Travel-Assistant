import 'package:flutter/material.dart';

abstract class _Constants {
  static const double defaultBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double iconSize = 20.0;
  static const double dismissButtonSize = 24.0;
  static const Duration fadeAnimationDuration = Duration(milliseconds: 300);

  // Button Keys
  static const String buttonDismissAlert = 'button_dismiss_alert';
}

/// Alert types that correspond to Bootstrap's contextual classes
enum AlertType {
  primary,
  secondary,
  success,
  danger,
  warning,
  info,
  light,
  dark,
}

/// A customizable alert card widget inspired by Bootstrap's alert component.
///
/// Supports different alert types, dismissible functionality, icons, and additional content.
/// Follows Material Design principles while maintaining Bootstrap-like styling.
class AlertCard extends StatefulWidget {
  /// Creates an [AlertCard].
  const AlertCard({
    super.key,
    required this.type,
    required this.content,
    this.title,
    this.icon,
    this.isDismissible = false,
    this.onDismissed,
    this.actions,
    this.showIcon = true,
    this.customBackgroundColor,
    this.customBorderColor,
    this.customTextColor,
    this.borderRadius = _Constants.defaultBorderRadius,
    this.padding = const EdgeInsets.all(_Constants.defaultPadding),
    this.elevation = 1.0,
  });

  /// The type of alert which determines the color scheme
  final AlertType type;

  /// The main content of the alert
  final Widget content;

  /// Optional title displayed at the top of the alert
  final String? title;

  /// Optional custom icon. If null, a default icon based on type will be used
  final IconData? icon;

  /// Whether the alert can be dismissed by the user
  final bool isDismissible;

  /// Callback when the alert is dismissed
  final VoidCallback? onDismissed;

  /// Optional action buttons displayed at the bottom
  final List<Widget>? actions;

  /// Whether to show the icon (default true)
  final bool showIcon;

  /// Custom background color (overrides type-based color)
  final Color? customBackgroundColor;

  /// Custom border color (overrides type-based color)
  final Color? customBorderColor;

  /// Custom text color (overrides type-based color)
  final Color? customTextColor;

  /// Border radius of the alert card
  final double borderRadius;

  /// Padding inside the alert card
  final EdgeInsets padding;

  /// Elevation of the alert card
  final double elevation;

  @override
  State<AlertCard> createState() => _AlertCardState();

  /// Creates a success alert card
  static AlertCard success({
    required Widget content,
    String? title,
    bool isDismissible = false,
    VoidCallback? onDismissed,
    List<Widget>? actions,
    bool showIcon = true,
    Key? key,
  }) {
    return AlertCard(
      key: key,
      type: AlertType.success,
      content: content,
      title: title,
      isDismissible: isDismissible,
      onDismissed: onDismissed,
      actions: actions,
      showIcon: showIcon,
    );
  }

  /// Creates an error/danger alert card
  static AlertCard error({
    required Widget content,
    String? title,
    bool isDismissible = false,
    VoidCallback? onDismissed,
    List<Widget>? actions,
    bool showIcon = true,
    Key? key,
  }) {
    return AlertCard(
      key: key,
      type: AlertType.danger,
      content: content,
      title: title,
      isDismissible: isDismissible,
      onDismissed: onDismissed,
      actions: actions,
      showIcon: showIcon,
    );
  }

  /// Creates a warning alert card
  static AlertCard warning({
    required Widget content,
    String? title,
    bool isDismissible = false,
    VoidCallback? onDismissed,
    List<Widget>? actions,
    bool showIcon = true,
    Key? key,
  }) {
    return AlertCard(
      key: key,
      type: AlertType.warning,
      content: content,
      title: title,
      isDismissible: isDismissible,
      onDismissed: onDismissed,
      actions: actions,
      showIcon: showIcon,
    );
  }

  /// Creates an info alert card
  static AlertCard info({
    required Widget content,
    String? title,
    bool isDismissible = false,
    VoidCallback? onDismissed,
    List<Widget>? actions,
    bool showIcon = true,
    Key? key,
  }) {
    return AlertCard(
      key: key,
      type: AlertType.info,
      content: content,
      title: title,
      isDismissible: isDismissible,
      onDismissed: onDismissed,
      actions: actions,
      showIcon: showIcon,
    );
  }
}

class _AlertCardState extends State<AlertCard> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: _Constants.fadeAnimationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    final alertConfig = _getAlertConfiguration(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: widget.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          side: BorderSide(
            color: widget.customBorderColor ?? alertConfig.borderColor,
            width: 1.0,
          ),
        ),
        color: widget.customBackgroundColor ?? alertConfig.backgroundColor,
        child: Padding(
          padding: widget.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(alertConfig),
              if (widget.title != null) const SizedBox(height: 8.0),
              _buildContent(alertConfig),
              if (widget.actions != null && widget.actions!.isNotEmpty) ...[
                const SizedBox(height: 12.0),
                _buildActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(_AlertConfiguration config) {
    if (widget.title == null && !widget.showIcon && !widget.isDismissible) {
      return const SizedBox.shrink();
    }

    return Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showIcon)
          Icon(
            widget.icon ?? config.defaultIcon,
            color: widget.customTextColor ?? config.iconColor,
            size: _Constants.iconSize,
          ),
        if (widget.title != null)
          Expanded(
            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: widget.customTextColor ?? config.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (widget.isDismissible)
          InkWell(
            key: const Key(_Constants.buttonDismissAlert),
            onTap: _dismissAlert,
            borderRadius: BorderRadius.circular(4.0),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.close,
                size: _Constants.dismissButtonSize,
                color: widget.customTextColor ?? config.textColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(_AlertConfiguration config) {
    return DefaultTextStyle(
      style:
          Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: widget.customTextColor ?? config.textColor,
          ) ??
          TextStyle(color: widget.customTextColor ?? config.textColor),
      child: widget.content,
    );
  }

  Widget _buildActions() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: widget.actions!,
    );
  }

  void _dismissAlert() {
    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
        widget.onDismissed?.call();
      }
    });
  }

  _AlertConfiguration _getAlertConfiguration(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (widget.type) {
      case AlertType.primary:
        return _AlertConfiguration(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.25),
          borderColor: colorScheme.primary.withValues(alpha: 0.6),
          textColor: const Color(0xFF1a1a1a),
          iconColor: const Color(0xFF1a1a1a),
          defaultIcon: Icons.info_rounded,
        );
      case AlertType.secondary:
        return _AlertConfiguration(
          backgroundColor: colorScheme.secondary.withValues(alpha: 0.25),
          borderColor: colorScheme.secondary.withValues(alpha: 0.6),
          textColor: const Color(0xFF1a1a1a),
          iconColor: const Color(0xFF1a1a1a),
          defaultIcon: Icons.info_rounded,
        );
      case AlertType.success:
        return _AlertConfiguration(
          backgroundColor: const Color(0xFF198754).withValues(alpha: 0.25),
          borderColor: const Color(0xFF198754).withValues(alpha: 0.6),
          textColor: const Color(0xFF0a3622),
          iconColor: const Color(0xFF0a3622),
          defaultIcon: Icons.check_circle_rounded,
        );
      case AlertType.danger:
        return _AlertConfiguration(
          backgroundColor: const Color(0xFFdc3545).withValues(alpha: 0.25),
          borderColor: const Color(0xFFdc3545).withValues(alpha: 0.6),
          textColor: const Color(0xFF58151c),
          iconColor: const Color(0xFF58151c),
          defaultIcon: Icons.error_rounded,
        );
      case AlertType.warning:
        return _AlertConfiguration(
          backgroundColor: const Color(0xFFffc107).withValues(alpha: 0.25),
          borderColor: const Color(0xFFffc107).withValues(alpha: 0.6),
          textColor: const Color(0xFF4d3d02),
          iconColor: const Color(0xFF4d3d02),
          defaultIcon: Icons.warning_rounded,
        );
      case AlertType.info:
        return _AlertConfiguration(
          backgroundColor: const Color(0xFF0dcaf0).withValues(alpha: 0.25),
          borderColor: const Color(0xFF0dcaf0).withValues(alpha: 0.6),
          textColor: const Color(0xFF033d4a),
          iconColor: const Color(0xFF033d4a),
          defaultIcon: Icons.info_rounded,
        );
      case AlertType.light:
        return _AlertConfiguration(
          backgroundColor: colorScheme.surface,
          borderColor: colorScheme.outline.withValues(alpha: 0.4),
          textColor: colorScheme.onSurface,
          iconColor: colorScheme.onSurfaceVariant,
          defaultIcon: Icons.lightbulb_rounded,
        );
      case AlertType.dark:
        return _AlertConfiguration(
          backgroundColor: colorScheme.inverseSurface.withValues(alpha: 0.15),
          borderColor: colorScheme.inverseSurface.withValues(alpha: 0.4),
          textColor: colorScheme.inverseSurface,
          iconColor: colorScheme.inverseSurface,
          defaultIcon: Icons.contrast_rounded,
        );
    }
  }
}

/// Configuration class for alert styling
class _AlertConfiguration {
  const _AlertConfiguration({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.defaultIcon,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final IconData defaultIcon;
}
