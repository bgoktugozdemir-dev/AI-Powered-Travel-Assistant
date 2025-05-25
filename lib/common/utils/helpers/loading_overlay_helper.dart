import 'package:flutter/material.dart';
import 'package:travel_assistant/common/ui/loading_overlay.dart';

mixin LoadingOverlayHelper {
  static OverlayEntry? _overlayEntry;

  void showLoadingOverlay(
    BuildContext context, {
    bool isDismissible = false,
    VoidCallback? onDismiss,
    String? loadingAsset,
  }) {
    if (_overlayEntry != null) {
      return;
    }

    _overlayEntry = OverlayEntry(
      builder:
          (context) => LoadingOverlay(
            isDismissible: isDismissible,
            onDismiss: onDismiss,
            loadingAsset: loadingAsset,
          ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void hideLoadingOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
