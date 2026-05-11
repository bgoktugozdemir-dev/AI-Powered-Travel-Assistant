# Travel Assistant 🌍✈️

![Flutter](https://img.shields.io/badge/Flutter-3.41.6-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
![AI Powered](https://img.shields.io/badge/AI-Powered-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Version](https://img.shields.io/badge/Version-1.2.2-blue.svg)

> **AI-powered travel assistant that helps you plan your perfect trip with personalized recommendations, visa requirements, and travel insights.**

Travel Assistant is a sophisticated Flutter application that leverages artificial intelligence to provide comprehensive travel planning assistance. Whether you're planning a business trip, vacation, or adventure, our app guides you through every aspect of your journey with intelligent recommendations and real-time information.

I was heavily inspired by **[Agent Development Kit (ADK) Demos](https://github.com/meteatamel/adk-demos)**.

## 🚀 Features

### ✈️ **Smart Trip Planning**

- **Multi-step Travel Form**: Intuitive 6-step process to gather your travel preferences
- **Airport Search**: Comprehensive database of global airports with intelligent search
- **Date Selection**: Flexible travel date picker with validation
- **Nationality Support**: International nationality database for visa requirements

### 🤖 **AI-Powered Recommendations**

- **Personalized Suggestions**: AI-driven recommendations based on your travel purposes
- **Visa Requirements**: Automatic visa and document requirement detection
- **Cost Analysis**: Real-time currency conversion and cost of living comparisons
- **Weather Forecasts**: Detailed weather information for your travel dates
- **Local Insights**: Curated recommendations for attractions, food, and activities

### 🎯 **Travel Purposes**

- **Sightseeing**: Tourist attractions and landmarks
- **Local Food**: Culinary experiences and restaurants
- **Business**: Business-friendly accommodations and services
- **Adventure**: Outdoor activities and extreme sports
- **Relaxation**: Spas, beaches, and wellness experiences
- **Visiting Friends**: Social travel recommendations

### 🌐 **Multi-Language Support**

- **English** and **Turkish** localization
- **Extensible**: Easy to add more languages
- **Context-aware**: Smart language switching based on destination

### 📱 **Cross-Platform**

- **Mobile**: iOS and Android optimized
- **Web**: Progressive Web App (PWA) support
- **Desktop**: Windows, macOS, and Linux compatibility
- **Responsive**: Adaptive UI for all screen sizes

## 🛠️ Technologies Used

### **Frontend**

- **Flutter 3.41.6** - Cross-platform UI framework
- **Dart 3.11.4** - Programming language
- **Material Design** - Modern, responsive UI components
- **Lottie** - High-quality animations

### **State Management**

- **BLoC Pattern** - Predictable state management
- **flutter_bloc** - Official BLoC implementation
- **Equatable** - Value equality for state comparison

### **Backend & AI**

- **Firebase AI (Vertex AI)** - AI-powered recommendations
- **Firebase Remote Config** - Dynamic configuration
- **Firebase Analytics** - User behavior tracking
- **Firebase App Check** - Security and abuse prevention

### **Networking & APIs**

- **Retrofit** - Type-safe REST client
- **Dio** - Powerful HTTP client
- **JSON Serialization** - Automated model generation

### **Monitoring & Analytics**

- **Sentry** - Error monitoring and performance tracking
- **Mixpanel** - Advanced analytics and user insights
- **Custom Analytics** - Comprehensive event tracking

### **External Services**

- **Airport APIs** - Global airport database
- **Currency APIs** - Real-time exchange rates
- **Weather APIs** - Detailed weather forecasts
- **Unsplash** - High-quality travel images

## 🏗️ Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── common/                 # Shared components and utilities
│   ├── constants/         # App-wide constants
│   ├── models/           # Data models and DTOs
│   ├── repositories/     # Data access layer
│   ├── services/         # Business logic services
│   ├── theme/           # UI theme configuration
│   ├── ui/              # Reusable UI components
│   └── utils/           # Utility classes and helpers
├── features/            # Feature-based modules
│   ├── travel_form/     # Multi-step travel form
│   ├── results/         # AI-generated recommendations
│   ├── onboarding/      # User onboarding flow
│   └── confirmation/    # Trip confirmation
├── l10n/               # Internationalization
└── main.dart           # App entry point
```

### **Design Patterns**

- **Repository Pattern** - Data access abstraction
- **Service Layer** - Business logic separation
- **BLoC Pattern** - Reactive state management
- **Dependency Injection** - Loose coupling and testability

## 🚀 Getting Started

### **Prerequisites**

- Flutter SDK 3.41.6 or higher
- Dart SDK 3.11.4 or higher
- Firebase CLI (for Firebase configuration)
- Android Studio / Xcode (for mobile development)

### **Installation**

1. **Clone the repository**

   ```bash
   git clone https://github.com/bgoktugozdemir/travel_assistant.git
   cd travel_assistant
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate code**

   ```bash
   dart run build_runner build
   ```

4. **Configure Firebase**

   - Create a new Firebase project
   - Add your platform-specific configuration files
   - Enable required Firebase services (see Configuration section)

5. **Run the app**
   ```bash
   flutter run
   ```

## ⚙️ Configuration

### **Firebase Setup**

1. **Create Firebase Project**

   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Google Analytics (optional)

2. **Enable Required Services**

   - **Firebase AI** - For AI-powered recommendations
   - **Remote Config** - For dynamic configuration
   - **Analytics** - For user behavior tracking
   - **App Check** - For security

3. **Configuration Files**
   - Add `google-services.json` (Android) to `android/app/`
   - Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`
   - Web configuration is in `lib/firebase_options.dart`

### **Remote Config Parameters**

Set up the following parameters in Firebase Remote Config:

```json
{
  "travel_purposes": [
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
    }
  ],
  "mixpanel_project_token": "your_mixpanel_token",
  "sentry_dsn": "your_sentry_dsn",
  "recaptcha_site_key": "your_recaptcha_key"
}
```

### **API Keys**

You'll need API keys for:

- **Airport Database API** - For airport search functionality
- **Currency API** - For real-time exchange rates
- **Weather API** - For weather forecasts
- **Unsplash API** - For travel images (optional)

Add these to your Firebase Remote Config or environment variables.

## 📱 Usage

### **Basic Flow**

1. **Start Journey**: Launch the app and begin the travel planning process
2. **Enter Details**: Complete the 6-step form:
   - Select departure airport
   - Choose destination airport
   - Pick travel dates
   - Select nationality
   - Choose travel purposes
   - Review summary
3. **Get Recommendations**: AI generates personalized travel insights
4. **Explore Results**: View flights, visa requirements, weather, and recommendations
5. **Plan Your Trip**: Use the comprehensive information to plan your perfect journey

### **Advanced Features**

- **Multi-language Support**: Switch between English and Turkish
- **Offline Capability**: Some features work without internet
- **Export Options**: Save or share your travel plan
- **Error Recovery**: Robust error handling with retry mechanisms

## 🧪 Testing

### **Run Tests**

```bash
# Unit tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart

# Widget tests
flutter test test/widget_test.dart
```

### **Code Quality**

```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Check dependencies
flutter pub deps
```

## 📋 Development Guidelines

### **Code Style**

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter_lints` for consistent formatting
- Maximum line length: 80 characters
- Use meaningful variable and function names

### **Architecture Rules**

- **No hardcoded strings** - Use localization files
- **Feature-first structure** - Organize by features, not layers
- **Separation of concerns** - Keep UI, business logic, and data separate
- **Constants class** - Define configurable parameters in `_Constants` classes

### **Git Workflow**

- Use conventional commits
- Create feature branches for new functionality
- Ensure all tests pass before merging
- Update documentation for API changes

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### **How to Contribute**

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes** following our coding standards
4. **Add tests** for new functionality
5. **Commit your changes** (`git commit -m 'Add amazing feature'`)
6. **Push to the branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

### **Development Setup**

```bash
# Clone your fork
git clone https://github.com/bgoktugozdemir/travel_assistant.git

# Add upstream remote
git remote add upstream https://github.com/bgoktugozdemir/travel_assistant.git

# Install dependencies
flutter pub get

# Run tests
flutter test

# Start developing!
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### **Getting Help**

- 📖 [Documentation](https://github.com/bgoktugozdemir/travel_assistant/wiki)
- 🐛 [Issue Tracker](https://github.com/bgoktugozdemir/travel_assistant/issues)
- 💬 [Discussions](https://github.com/bgoktugozdemir/travel_assistant/discussions)

### **Reporting Issues**

Please use our issue templates and provide:

- Device information
- Flutter version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
