import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_assistant/common/constants/app_assets.dart';
import 'package:travel_assistant/common/utils/helpers/loading_overlay_helper.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({this.isDismissible = false, this.onDismiss, this.loadingAsset, this.label, super.key});

  final bool isDismissible;
  final VoidCallback? onDismiss;
  final String? loadingAsset;
  final String? label;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> with LoadingOverlayHelper {
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
                Lottie.asset(widget.loadingAsset ?? AppAssets.loadingIndicatorLottie),
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
