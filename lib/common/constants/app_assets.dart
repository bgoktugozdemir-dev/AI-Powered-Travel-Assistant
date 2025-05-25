/// A utility class for easy access to asset paths.
abstract class AppAssets {
  // Base paths
  static const String _baseLottiePath = 'assets/lotties';

  // Lottie Animations
  static const String flightSearchIndicatorLottie = '$_baseLottiePath/flight_search_indicator.json';
  static const String loadingIndicatorLottie = '$_baseLottiePath/loading_indicator.json';

  // Other Assets (if any in the root of assets/)
  // static const String exampleJsonc = 'assets/example_travel_plan_response.jsonc'; // Example, if needed
  // static const String systemPromptMd = 'assets/system_prompt.md'; // Example, if needed

  // To add more assets:
  // 1. Add the asset to the appropriate subdirectory in the `assets` folder.
  // 2. Define a new static const String here with the correct path.
  // 3. Ensure the asset is listed in pubspec.yaml under flutter > assets.
}
