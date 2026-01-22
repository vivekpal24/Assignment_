# Recipe Finder

A modern Flutter application for discovering and managing recipes using TheMealDB API. Built with Clean Architecture principles, Riverpod state management, and comprehensive testing.

## Features

### 🔍 Recipe Discovery
- **Smart Search**: Debounced search with real-time filtering
- **Advanced Filters**: Filter by category and cuisine/area
- **Sort Options**: Sort recipes by name (ascending/descending)
- **Dual View Modes**: Switch between grid and list layouts
- **Active Filter Count**: Visual badge showing applied filters

### 📖 Recipe Details
- **Rich Information**: Full recipe details with ingredients and instructions
- **Video Tutorials**: Embedded YouTube player with fallback to external app
- **Image Viewer**: Full-screen image viewing with Hero animations
- **Offline Support**: Recipe details cached locally for offline access
- **Step-by-Step Instructions**: Numbered, formatted cooking instructions

### ❤️ Favorites Management
- **Animated Toggle**: Heart-beat scale effect on favorite button
- **Persistent Storage**: Favorites saved locally with Hive
- **Dedicated Screen**: Browse all favorite recipes
- **Quick Access**: Favorites icon in app bar with badge count

### 🎨 Modern UI/UX
- **Material Design 3**: Modern, clean interface with custom color scheme
- **Smooth Animations**: Hero transitions, shimmer loading, scale effects
- **Dark Theme Support**: Optimized for both light and dark modes
- **Responsive Layouts**: Adaptive UI for different screen sizes
- **Error States**: User-friendly error messages with retry functionality
- **Empty States**: Helpful empty state screens with action buttons

### 🧭 Navigation
- **GoRouter**: Declarative routing with named routes
- **Deep Linking Ready**: Structured for future deep link support
- **Clean URLs**: Semantic route paths (`/`, `/recipe/:id`, `/favorites`)

## Architecture

### Clean Architecture
The project follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/        # App-wide constants (colors, sizes, strings)
│   ├── errors/          # Error handling (failures)
│   ├── router/          # GoRouter configuration
│   ├── theme/           # App theme configuration
│   └── widgets/         # Reusable widgets
│
└── features/
    └── recipes/
        ├── data/
        │   ├── datasources/    # Remote & local data sources
        │   ├── models/         # Data models
        │   └── repositories/   # Repository implementations
        ├── domain/
        │   ├── entities/       # Business entities
        │   ├── repositories/   # Repository interfaces
        │   └── usecases/       # Business logic
        └── presentation/
            ├── providers/      # Riverpod state management
            ├── screens/        # App screens
            └── widgets/        # Feature-specific widgets
```

### State Management
- **Riverpod 2.x**: Reactive state management with providers
- **AsyncNotifier**: For async state with automatic loading/error handling
- **Family Providers**: For parameterized providers (e.g., recipe by ID)
- **State Invalidation**: Efficient cache invalidation and refresh

### Data Layer
- **Hive**: Local database for caching and favorites
- **HTTP**: API calls to TheMealDB
- **Either Pattern**: Functional error handling with dartz
- **Mappers**: Conversion between models and entities

## Technologies

### Core
- **Flutter 3.x**: UI framework
- **Dart 3.x**: Programming language

### State Management & Architecture
- **flutter_riverpod**: State management
- **go_router**: Declarative routing
- **dartz**: Functional programming utilities

### Data & Storage
- **http**: API calls
- **hive**: Local database
- **hive_flutter**: Hive Flutter integration

### UI & Assets
- **cached_network_image**: Image caching
- **shimmer**: Loading animations
- **youtube_player_iframe**: YouTube video playback
- **url_launcher**: External link handling

### Development & Testing
- **flutter_test**: Widget testing
- **mocktail**: Mocking for tests
- **equatable**: Value equality

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android NDK 27.0.12077973 (for Android builds)

### Installation

1. **Clone the repository**
   ```bash
   git clone <(https://github.com/vivekpal24/Assignment_)>
   cd Assignmen_/recipe_finder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Initialize Hive adapters** (if needed)
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/recipes/presentation/providers/favorites_provider_test.dart
```

### Code Analysis

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib test
```

## Project Structure Highlights

### Key Files

- **`lib/main.dart`**: App entry point with Hive initialization
- **`lib/core/router/app_router.dart`**: Centralized routing configuration
- **`lib/core/theme/app_theme.dart`**: App-wide theme settings
- **`lib/features/recipes/presentation/providers/recipe_list_provider.dart`**: Main recipe list state
- **`lib/features/recipes/presentation/providers/favorites_provider.dart`**: Favorites state management

### Configuration

- **`pubspec.yaml`**: Dependencies and assets
- **`android/app/build.gradle.kts`**: Android build configuration
- **`analysis_options.yaml`**: Linter rules (if present)

## API

This app uses [TheMealDB API](https://www.themealdb.com/api.php):
- **Search**: `/search.php?s={query}`
- **Filter**: `/filter.php?c={category}` or `/filter.php?a={area}`
- **Details**: `/lookup.php?i={id}`
- **Categories**: `/list.php?c=list`
- **Areas**: `/list.php?a=list`

## Testing Coverage

- ✅ **Unit Tests**: Providers, repositories, use cases
- ✅ **Widget Tests**: Key screens and components
- ✅ **Integration Tests**: End-to-end user flows
- **Coverage**: 45 tests passing across all layers

## Known Limitations

1. **YouTube Videos**: Some recipe videos may not be embeddable due to YouTube restrictions. Use the "Open in YouTube App" fallback button.
2. **API Rate Limits**: TheMealDB free tier has usage limits
3. **Network Dependency**: Initial recipe loading requires internet connection

## Future Enhancements

- [ ] Deep linking support
- [ ] Recipe sharing functionality
- [ ] Custom recipe creation
- [ ] Meal planning
- [ ] Grocery list generation
- [ ] Nutrition information

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [TheMealDB](https://www.themealdb.com/) for providing the recipe API
- Flutter and Dart teams for the excellent framework
- Riverpod community for state management guidance
