import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_assistant/common/constants/app_assets.dart';
import 'package:travel_assistant/common/utils/helpers/loading_overlay_helper.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({this.isDismissible = false, this.onDismiss, this.loadingAsset, super.key});

  final bool isDismissible;
  final VoidCallback? onDismiss;
  final String? loadingAsset;

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
          child: Center(child: Lottie.asset(widget.loadingAsset ?? AppAssets.loadingIndicatorLottie)),
        ),
      ),
    );
  }
}
