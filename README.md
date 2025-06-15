# Fitness Tracker App

A modern, cross-platform fitness tracker built with Flutter.  
Track your workouts, set and monitor goals, and visualize your progress with a beautiful, responsive UI.

---

## 🚀 Features

- **Workout Logging:** Add, edit, and view workouts with minutes, calories, notes, and dates.
- **Goal Management:** Create, edit, and track fitness goals with real-time progress.
- **Progress Visualization:** Interactive weekly charts and concentric goal rings for clear insights.
- **Exercise Library:** Manage your own list of exercises.
- **Modern UI:** Fresh color palette, icons, and smooth scrolling for a great user experience.
- **Date-based Stats:** All stats and charts update live based on the selected date.
- **Persistent Storage:** All data is stored locally using SQLite for privacy and offline access.

---

## 📱 Screenshots

![Untitled design](https://github.com/user-attachments/assets/5f691282-7435-4f7a-9fdf-66d6ff84cab8)

 

---

## 📁 Project Structure

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

---

## 🛠️ Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- A device or emulator

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/Usman1subhani/CodeAlpha_fitness_tracker_app.git
   cd CodeAlpha_fitness_tracker_app
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   ```sh
   flutter run
   ```

---

## 🧭 Usage

- **Navigation:** Use the bottom navigation bar to switch between Workouts, Goals, Exercises, and Progress.
- **Add/Edit/Delete:** Tap the "+" or edit icons to add or update entries. Long-press or use the delete icon to remove items.
- **Charts:** View your progress and stats on the Progress screen, with interactive and colorful charts.
- **Date Selection:** Tap on any day in the progress screen
