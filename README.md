# Forge - Workout Tracker

Forge is a comprehensive, offline-first workout tracking application built with Flutter. It's designed to help fitness enthusiasts log their progress, manage exercise routines, and visualize their gains through a sleek, data-driven interface.

## ✨ Features

- **Intuitive Workout Logging**: Record sets, reps, and weights for your exercises with ease.
- **Dynamic Progress Charts**: Visualize your strength and volume gains over time using `fl_chart`.
- **Comprehensive History**: A calendar-based view to track your consistency and review past sessions.
- **Customizable Exercises**: Create and manage a personalized library of exercises.
- **User Settings**: Tailor the app experience to your preferences.
- **Offline First Architecture**: Fully functional without an internet connection, powered by Hive local storage.
- **Modern Dark Theme**: Optimized for gym environments and focus.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/) (Reactive caching and state management)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) (Declarative routing)
- **Local Database**: [Hive](https://pub.dev/packages/hive) (Fast, NoSQL local storage)
- **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it) (Service locator)
- **UI Components**: [FL Chart](https://pub.dev/packages/fl_chart), [Google Fonts](https://pub.dev/packages/google_fonts), [Font Awesome](https://pub.dev/packages/font_awesome_flutter)

## 🏗️ Project Structure

The project follows a Clean Architecture approach to ensure maintainability and scalability:

- **`lib/domain`**: The core of the application. Contains Entities (Exercise, WorkoutSession, UserSettings) and Repository abstractions.
- **`lib/data`**: Implementation of repositories, Hive data sources, and models with type adapters.
- **`lib/presentation`**: UI layer organized by feature (home, workout, calendar, progress, settings). Uses Riverpod for state handling.
- **`lib/app`**: Application-wide configurations like themes and routing.
- **`lib/di`**: Dependency injection setup using GetIt.

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.11.0+)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation & Setup

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/forge.git
    cd forge
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run Code Generation**:
    Forge uses `hive_generator` for database adapters. Run this to generate the necessary files:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Configure App Icons** (Optional):
    If you change the icon in `assets/icon/`, update them using:
    ```bash
    flutter pub run flutter_launcher_icons
    ```

5.  **Run the application**:
    ```bash
    flutter run
    ```

## 📱 Screenshots

| Home | Workout | Progress |
| :---: | :---: | :---: |
| ![Home](https://via.placeholder.com/200x400?text=Home+Screen) | ![Workout](https://via.placeholder.com/200x400?text=Workout+Log) | ![Progress](https://via.placeholder.com/200x400?text=Progress+Charts) |

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
