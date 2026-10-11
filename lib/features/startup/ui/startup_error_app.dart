import 'package:flutter/material.dart';
import 'package:travel_assistant/common/theme/app_theme.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

abstract class _Constants {
  static const double iconSize = 64;
  static const double maxContentWidth = 420;
  static const EdgeInsets padding = EdgeInsets.all(24);
}

/// What the user sees when the app fails to start.
///
/// It only needs Flutter itself (no Firebase, no Remote Config, no BLoCs), so
/// it can run when any of those failed to initialize. [onRetry] starts the
/// app again, or reloads the page on the web.
class StartupErrorApp extends StatelessWidget {
  /// Creates a [StartupErrorApp].
  const StartupErrorApp({required this.onRetry, super.key});

  /// Called when the user asks to try again.
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      home: _StartupErrorScreen(onRetry: onRetry),
    );
  }
}

class _StartupErrorScreen extends StatefulWidget {
  const _StartupErrorScreen({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  State<_StartupErrorScreen> createState() => _StartupErrorScreenState();
}

class _StartupErrorScreenState extends State<_StartupErrorScreen> {
  bool _isRetrying = false;

  Future<void> _retry() async {
    setState(() => _isRetrying = true);
    try {
      await widget.onRetry();
    } finally {
      // Starting the app again replaces this screen. If it fails once more,
      // the same screen is shown again and must accept another tap.
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: _Constants.padding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _Constants.maxContentWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: _Constants.iconSize,
                    color: theme.colorScheme.error,
                  ),
                  Text(
                    l10n.startupErrorTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(
                    l10n.startupErrorMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  FilledButton.icon(
                    onPressed: _isRetrying ? null : _retry,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.startupErrorRetry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
