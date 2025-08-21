# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## PLan & Review
- Always in plan mode to make a plan.
- After get the plan, make sure you write the plan to .claude/tasks/TASK_NAME.md.
- The plan should be a detailed implementation plan and the reasoning behind them, as well as tasks broken down.
- If the task require external knowledge or certain package, also research to get latest knowledge (use Task tool for research)
- Do not over plan it, always think MVP.
- Once you write the plan, firstly ask me to review it. Do not continue until I approve the plan.

### While implementing
- You should update the plan as you work.
- After you complete tasks in the plan, you should update and append detailed descriptions of the changes you made, so following tasks can be easily hand over to other engineers.

## Project Overview

Heroes Colombia is a Flutter mobile application that enables military personnel and government employees in Colombia to discover local businesses offering special promotions and discounts. The app features location-based business discovery with Google Maps integration and business management tools for owners.

## Development Commands

### Build and Development
- `flutter run` - Run the app in debug mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Install dependencies
- `flutter pub deps` - Show dependency tree

### Code Quality
- `flutter analyze` - Run static analysis (currently shows 165 issues)
- `flutter test` - Run unit tests
- `flutter pub run build_runner build` - Generate code (auto_route, freezed, etc.)

### Version Management
- `./ios/update_version.sh` - Script to sync iOS version with pubspec.yaml version

## Architecture Overview

### Clean Architecture Structure
The project follows clean architecture principles with these main layers:

- **Domain Layer** (`lib/src/domain/`):
  - `models/` - Data models (Business, User, Promotion, etc.)
  - `repositories/` - Abstract interfaces for data access
  - `services/` - Business logic services (Analytics, Places)

- **Presentation Layer** (`lib/src/presentation/`):
  - `cubits/` - BLoC state management using Cubit pattern
  - `pages/` - UI screens organized by feature
  - `widgets/` - Reusable UI components

- **Configuration** (`lib/src/config/`):
  - `router/` - AutoRoute navigation configuration
  - `app_themes.dart` - Theme definitions

### State Management
- **Primary**: Flutter BLoC with Cubit pattern
- **Cubits**: Organized by feature (auth, business, profile, map, etc.)
- **Global State**: MultiBlocProvider in `main.dart` provides app-wide cubits

### Dependency Injection
- **Container**: GetIt (singleton pattern)
- **Setup**: `lib/src/locator.dart` registers all dependencies
- **Services**: Firebase services, repositories, utilities

### Navigation
- **Router**: AutoRoute with nested routes
- **Guards**: AuthGuard for protected routes
- **Structure**: 
  - Entry point (`/`)
  - Auth flows (`/welcome`)
  - User dashboard (`/dashboard`) - protected
  - Business dashboard (`/businessDashboard`) - protected
  - Individual pages with custom transitions

### Key Dependencies
- **State Management**: `flutter_bloc`, `provider`
- **Navigation**: `auto_route`
- **Backend**: Firebase (Auth, Firestore, Storage, Analytics, Messaging)
- **Maps**: `google_maps_flutter`, `flutter_map`
- **Location**: `geolocator`, `location`, `geocoding`
- **UI**: `adaptive_theme`, `flutter_form_builder`, `ionicons`
- **Networking**: `dio`
- **Storage**: `shared_preferences`
- **Utilities**: `get_it`, `equatable`, `intl`

## Code Organization

### Feature Modules
1. **Authentication** - Login, signup, password recovery
2. **Dashboard** - Main user interface with search, favorites, profile
3. **Business Management** - Business owner tools and analytics
4. **Maps & Location** - Interactive maps with business markers
5. **Search & Discovery** - Business and promotion search

### Key Files
- `main.dart` - App entry point with Firebase and BLoC setup
- `lib/src/locator.dart` - Dependency injection configuration
- `lib/src/config/router/app_router.dart` - Route definitions
- `firebase_options.dart` - Firebase configuration
- `.env` - Environment variables (not in version control)

## Development Guidelines

### Following Cursor Rules
The project has specific Flutter development guidelines in `.cursor/rules/flutter.mdc`:
- Use clean architecture with repository pattern
- Prefer BLoC/Cubit for state management over Riverpod (as specified in rules)
- Use GetIt for dependency injection
- AutoRoute for navigation
- Break down complex widgets to avoid deep nesting
- Use const constructors where possible
- Follow SOLID principles

### Code Style
- Uses `flutter_lints` for linting rules
- PascalCase for classes, camelCase for variables/methods
- Avoid deep widget nesting - extract to smaller components
- Use early returns to reduce nesting

### Firebase Integration
- Configured for both iOS and Android
- Services: Authentication, Firestore, Storage, Analytics, Cloud Messaging
- Environment-specific configuration via DefaultFirebaseOptions

### Known Issues
- Currently 165 static analysis issues (mostly deprecated API usage)
- Many `deprecated_member_use` warnings for Theme properties
- Some `use_build_context_synchronously` warnings in async operations
- Unused imports in some files

## Testing
- Standard Flutter widget testing framework
- Run tests with `flutter test`
- No specific test configuration found - uses Flutter defaults

## Platform Support
- **Primary**: iOS and Android
- **Secondary**: macOS, Linux, Windows (configured but not primary targets)
- Minimum Android SDK: 21
- iOS deployment target configured in project settings