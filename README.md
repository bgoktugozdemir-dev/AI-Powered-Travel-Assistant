# travel_assistant

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Remote Config

### Travel Purposes Configuration

The app supports configurable travel purposes through Firebase Remote Config. Set the `travel_purposes` key with a JSON array of travel purpose objects.

**Example JSON for Firebase Remote Config:**

```json
[
  {
    "id": "sightseeing",
    "name": "Sightseeing",
    "localizationKey": "travelPurposeSightseeing",
    "icon": "photo_camera"
  },
  {
    "id": "food",
    "name": "Local Food",
    "localizationKey": "travelPurposeFood",
    "icon": "restaurant"
  },
  {
    "id": "business",
    "name": "Business",
    "localizationKey": "travelPurposeBusiness",
    "icon": "business_center"
  },
  {
    "id": "adventure",
    "name": "Adventure",
    "localizationKey": "travelPurposeAdventure",
    "icon": "hiking"
  },
  {
    "id": "relaxation",
    "name": "Relaxation",
    "localizationKey": "travelPurposeRelaxation",
    "icon": "beach_access"
  }
]
```

**Field Descriptions:**
- `id`: Unique identifier for the travel purpose
- `name`: Fallback English name (used if localization fails)
- `localizationKey`: Key to lookup localized strings in app_en.arb/app_tr.arb
- `icon`: Material Icon name (see TravelPurposeService.getIconForPurpose for supported icons)

If the Firebase Remote Config value is empty or invalid, the app will fall back to the default travel purposes defined in the code.
