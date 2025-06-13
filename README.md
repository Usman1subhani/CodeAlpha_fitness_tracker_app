# Fitness Tracker App

A modern, cross-platform fitness tracker built with Flutter. Track your workouts, set goals, monitor progress, and manage exercises—all with a beautiful, responsive UI.

## Features

- **Workout Tracking:** Log workouts with minutes, calories, notes, and dates.
- **Goal Management:** Create, edit, and delete fitness goals with progress tracking.
- **Exercise Library:** Add, edit, and manage custom exercises.
- **Progress Visualization:** View your stats and goal progress with interactive charts and modern UI.
- **Modern Design:** Fresh color palette, icons, and responsive layouts for a great user experience.
- **Edit Functionality:** Easily update any workout, goal, or exercise.
- **Persistent Storage:** All data is stored locally using SQLite.

## Screenshots

*(Add your screenshots here)*

## Folder Structure

```
lib/
│
├── main.dart                  # App entry point
├── model/
│   ├── exercise.dart          # Exercise data model
│   ├── goal.dart              # Goal data model
│   └── workout.dart           # Workout data model
│
├── helpers/
│   └── database_helper.dart   # SQLite database helper
│
├── screens/
│   ├── exercise_screen.dart   # Exercise management UI
│   ├── goal_screen.dart       # Goal management UI
│   ├── workout_screen.dart    # Workout logging UI
│   └── progress_screen.dart   # Progress and charts UI
│
└── widgets/
    └── bottom_nav_bar.dart    # Custom bottom navigation bar
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- A device or emulator

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/your-username/fitness_tracker_app.git
   cd fitness_tracker_app
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   ```sh
   flutter run
   ```

## Usage

- **Navigation:** Use the bottom navigation bar to switch between Workouts, Goals, Exercises, and Progress.
- **Add/Edit/Delete:** Tap the "+" or edit icons to add or update entries. Long-press or use the delete icon to remove items.
- **Charts:** View your progress and stats on the Progress screen, with interactive and colorful charts.

## Customization

- **Colors & Theme:** Easily update the color palette in each screen’s state class.
- **Database:** Uses SQLite via the `sqflite` package for local storage.

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](LICENSE)

---

**Made with Flutter ❤️**
