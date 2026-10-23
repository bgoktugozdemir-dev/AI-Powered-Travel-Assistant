import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_assistant/common/constants/app_assets.dart';
import 'package:travel_assistant/common/utils/helpers/loading_overlay_helper.dart';

abstract class _Constants {
  static const double animationSize = 240;
}

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({
    this.isDismissible = false,
    this.onDismiss,
    this.loadingAsset,
    this.label,
    super.key,
  });

  final bool isDismissible;
  final VoidCallback? onDismiss;
  final String? loadingAsset;
  final String? label;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with LoadingOverlayHelper {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          widget.isDismissible
              ? () {
                hideLoadingOverlay();
                widget.onDismiss?.call();
              }
              : null,
      child: PopScope(
        canPop: false,
        child: Material(
          color: Colors.black.withAlpha(180),
          child: Center(
            child: Column(
              spacing: 24,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Capped: without a size, Lottie takes the composition's own
                // size (1000x1000 for the default one), which pushes the label
                // off-screen on short viewports.
                Flexible(
                  child: Lottie.asset(
                    widget.loadingAsset ?? AppAssets.loadingIndicatorLottie,
                    width: _Constants.animationSize,
                    height: _Constants.animationSize,
                    fit: BoxFit.contain,
                  ),
                ),
                if (widget.label != null)
                  Text(
                    widget.label!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
