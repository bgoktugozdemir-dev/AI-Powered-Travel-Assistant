import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:travel_assistant/common/services/unsplash_service.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class _Constants {
  static const String photographerToken = '{photographer}';
  static const String unsplashToken = '{unsplash}';
  static const String unsplashName = 'Unsplash';
  static final RegExp tokens = RegExp(
    '${RegExp.escape(photographerToken)}|${RegExp.escape(unsplashToken)}',
  );
}

Future<void> _openInBrowser(Uri uri) async {
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// "Photo by [photographer] on [Unsplash]", with both names linking to
/// Unsplash.
///
/// The Unsplash API guidelines require this credit wherever a photo from the
/// API is shown, with links that carry `utm_source=<app name>` and
/// `utm_medium=referral` (see [UnsplashLinks]).
class UnsplashCredit extends StatefulWidget {
  /// Creates an [UnsplashCredit].
  ///
  /// [onOpenLink] opens a link; it can be replaced in tests.
  const UnsplashCredit({
    required this.photographer,
    this.onOpenLink = _openInBrowser,
    super.key,
  });

  /// The photographer to credit.
  final UnsplashUser photographer;

  /// Opens a link.
  final Future<void> Function(Uri uri) onOpenLink;

  @override
  State<UnsplashCredit> createState() => _UnsplashCreditState();
}

class _UnsplashCreditState extends State<UnsplashCredit> {
  late final TapGestureRecognizer _photographerTap = TapGestureRecognizer()
    ..onTap = () => widget.onOpenLink(
      UnsplashLinks.profile(widget.photographer.username),
    );

  late final TapGestureRecognizer _unsplashTap = TapGestureRecognizer()
    ..onTap = () => widget.onOpenLink(UnsplashLinks.home());

  @override
  void dispose() {
    _photographerTap.dispose();
    _unsplashTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Colors.white,
    );
    final linkStyle = textStyle?.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: Colors.white,
    );

    // The translation decides the word order. Ask it for a template with the
    // tokens in place of the names, then swap each token for a link.
    final template = l10n.unsplashPhotoCredit(
      _Constants.photographerToken,
      _Constants.unsplashToken,
    );
    final spans = <InlineSpan>[];
    template.splitMapJoin(
      _Constants.tokens,
      onMatch: (match) {
        final isPhotographer = match[0] == _Constants.photographerToken;
        spans.add(
          TextSpan(
            text: isPhotographer
                ? widget.photographer.name
                : _Constants.unsplashName,
            style: linkStyle,
            recognizer: isPhotographer ? _photographerTap : _unsplashTap,
          ),
        );
        return '';
      },
      onNonMatch: (text) {
        spans.add(TextSpan(text: text));
        return '';
      },
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text.rich(
          TextSpan(style: textStyle, children: spans),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
