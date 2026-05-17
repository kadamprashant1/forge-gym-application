# Workout Tracker - Technical Documentation

## Project Overview
A modern Android workout tracking app built with Flutter. The app focuses on a 6-day PPL (Push/Pull/Legs) routine, providing video tutorials for every exercise and a simplified "Mark as Done" tracking system.

## Tech Stack
- **Frontend**: Flutter (Dart)
- **Architecture**: Clean Architecture
- **Local Storage**: Hive
- **State Management**: Riverpod
- **Navigation**: go_router
- **External**: url_launcher (for YouTube videos)

## Core Features

### 1. Home Screen (Dashboard)
- Displays "Today's Session" based on the actual day of the week.
- Weekly Routine grid (Monday - Saturday).
- Quick access to start training.

### 2. Workout Detail Screen
- **Video Cards**: Each exercise includes a high-quality YouTube tutorial link.
- **Simplified Logging**: Removed weight/reps/sets input. Users simply mark an exercise as "Done".
- **Goal Reference**: Displays the recommended set and rep range for each exercise as a guide.
- **Session Saving**: Tracks the total duration of the workout and saves it to history.

### 3. Database Design (Hive)

#### Exercise Entity
```dart
{
  id: String,
  workoutDayId: String,
  orderIndex: int,
  exerciseName: String,
  sets: int,
  minReps: int,
  maxReps: int,
  videoUrl: String?, // YouTube Link
  notes: String?
}
```

## UI Design

### Color Palette
- **Primary**: #121212 (Dark Background)
- **Surface**: #1E1E1E (Cards)
- **Accent**: #00FF41 (Neon Green)

### Components
- **Exercise Card**: Features a network image thumbnail from YouTube with a play button overlay.
- **Mark as Done**: A clear toggle button that changes the exercise title color to neon green when completed.

## Development Rules
- Use `url_launcher` for external video content.
- Maintain an offline-first approach (Hive).
- Ensure smooth scrolling even with multiple video thumbnails.
