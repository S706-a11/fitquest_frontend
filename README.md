# FitQuest Frontend 🏃‍♂️💪

A gamified fitness tracking application built with Flutter, featuring quest-based challenges, XP progression, and real-time fitness tracking.

## ✨ Features

- 🎮 **Gamification** - Turn fitness into an RPG-style adventure
- 🎯 **Quest System** - Daily challenges and custom fitness goals
- 📊 **Progress Tracking** - Monitor XP, levels, and achievements
- 🏆 **Leaderboards** - Compete with friends
- 💪 **Exercise Library** - Comprehensive workout database
- 👤 **User Profiles** - Track personal fitness journey
- 🧭 **Unified Workout Tracker** - Time + Distance in one place (GPS map for running/cycling, timer-only for others), instant save with quest and goal updates

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Backend API running on `http://localhost:5105`
- Chrome/Edge browser (for web) or Windows (for desktop)

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/S706-a11/fitquest_frontend.git
   cd fitquest_frontend
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Ensure backend is running:**
   - Backend API: `http://localhost:5105`
   - Swagger UI: `http://localhost:5105/swagger/index.html`

### Running the App

#### Option 1: Double-Click (Easiest!)

- **Web:** Double-click `run_web.bat`
- **Desktop:** Double-click `run_windows.bat`

#### Option 2: VS Code (Recommended)

1. Press **F5**
2. Select "Flutter Web (Chrome - Port 3000)"

#### Option 3: Command Line

```bash
# Web (Port 3000)
flutter run -d chrome --web-port=3000

# Windows Desktop (Recommended for development)
flutter run -d windows

# Android
flutter run -d android
```

### 🌐 Access the App

- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:5105
- **Swagger UI:** http://localhost:5105/swagger/index.html

## 📱 Supported Platforms

| Platform        | Status       | Command                  |
| --------------- | ------------ | ------------------------ |
| 🌐 Web (Chrome) | ✅ Supported | `flutter run -d chrome`  |
| 🌐 Web (Edge)   | ✅ Supported | `flutter run -d edge`    |
| 🖥️ Windows      | ✅ Supported | `flutter run -d windows` |
| 📱 Android      | ✅ Supported | `flutter run -d android` |
| 🍎 iOS          | ✅ Supported | `flutter run -d ios`     |
| 🐧 Linux        | ✅ Supported | `flutter run -d linux`   |
| 🍎 macOS        | ✅ Supported | `flutter run -d macos`   |

## 🛠️ Tech Stack

- **Framework:** Flutter 3.7.2
- **Language:** Dart
- **State Management:** Provider
- **HTTP Client:** http package
- **Local Storage:** SharedPreferences
- **Backend API:** ASP.NET Core (running separately)

## 📚 All‑in‑One Docs (Contents)

This README consolidates all documentation. Jump to a section:

1. [Quick Start](#-quick-start)
2. [Running the App](#running-the-app)
3. [Port 3000 Setup](#-port-3000-setup)
4. [Configuration](#-configuration)
5. [Architecture Overview](#-architecture-overview)
6. [API Integration](#-api-integration)
7. [Quest Template Generator](#-quest-template-generator)
8. [Quick Reference (Snippets)](#-quick-reference-snippets)
9. [Phone Setup (Run on Device)](#-phone-setup-run-on-device)
10. [Troubleshooting](#-troubleshooting)
11. [Project Structure](#-project-structure)
12. [Contributing](#-contributing)
13. [License](#-license)

## 🎯 Key Features Implementation

### ✅ Implemented

- User authentication (login/register)
- User profile management
- XP and leveling system
- Active quest display
- Settings and logout
- API integration layer
- State management with Provider
- Unified workout tracker (time + distance)
  - Map + GPS for running/cycling; timer-only for swimming/general/strength
  - Finish saves immediately, shows a confirmation, and resets the tracker
  - Applies session progress to all active quests automatically
  - Recomputes Daily and Monthly Goals from exercises
  - Robust session logging with fallback to create a basic exercise if the sessions endpoint is unavailable
- Leaderboard functionality (configurable by metric/period/type)

## 🔌 Port 3000 Setup

The app is configured to run the web build on port 3000.

- VS Code: press F5 and choose “Flutter Web (Chrome - Port 3000)”.
- Batch files: `run_web.bat` and `run_edge.bat` open http://localhost:3000.

If port 3000 is in use (Windows PowerShell):

```powershell
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

Ensure your backend CORS allows http://localhost:3000:

```csharp
builder.Services.AddCors(options =>
{
   options.AddDefaultPolicy(policy =>
   {
      policy.WithOrigins("http://localhost:3000")
           .AllowAnyHeader()
           .AllowAnyMethod();
   });
});

app.UseCors();
```
## 🧪 Quest Template Generator

### Overview

The Quest Template Generator can create 200+ unique quest templates with difficulty scaling, level gating, and category variety.

### How to Use

1. Open the app → Settings tab
2. Scroll to Developer Tools
3. Tap Quest Template Generator

Presets:

- Generate All: full library across categories and difficulties
- Beginner Only: Level 1–5 quests
- High Level Only: Expert + Master templates
- Strength & Cardio: focused mix of those categories

Custom generation:

- Number of Quests (1–1000)
- Save to Database (persist) | Return Templates (preview)
- Add Variance (add ±10–20% XP variety)
- Filters: Categories and Difficulties

### Categories

- General, Strength, Cardio, Flexibility, Endurance, Consistency, WeightLoss, MuscleGain

### Difficulties

| Difficulty   | Level Range | XP Multiplier | Duration | Example               |
| ------------ | ----------- | ------------- | -------- | --------------------- |
| Beginner     | 1–5         | 1x (50 XP)    | 7 days   | Complete 3 exercises  |
| Intermediate | 6–15        | 2x (100 XP)   | 14 days  | Complete 10 exercises |
| Advanced     | 16–30       | 4x (200 XP)   | 21 days  | Complete 20 exercises |
| Expert       | 31–50       | 8x (400 XP)   | 30 days  | Complete 40 exercises |
| Master       | 51–100      | 15x (750 XP)  | 45 days  | Complete 60 exercises |

### Value Scaling Examples

- Reps: 50 → 10,000 across tiers
- Weight: 1,000kg → 250,000kg total lifted
- Duration: 30 → 1,200 minutes

### Common Use Cases

Initial setup (full library):

```
Count: 1000
Save to Database: ✓
Add Variance: ✓
Return Templates: ✗
Categories: (all)
Difficulties: (all)
```

Flexibility-only content:

```
Count: 50
Save to Database: ✓
Categories: Flexibility
Difficulties: (all)
```

Preview without saving:

```
Count: 10
Save to Database: ✗
Return Templates: ✓
Categories: Strength
```

### Response Fields

- Generated: total templates created
- Saved: persisted records
- Duplicates: skipped titles
- Message: info/error message

### Pro Tips

1. Use Generate All for first-time content
2. Add Variance for variety; re-run for more
3. Focus on 2–3 categories for targeted drops
4. Balance by difficulty in separate runs
5. Preview first, then enable Save

### Pattern Examples

Strength:

- Complete {reps} total reps
- Lift {weight}kg total weight
- Do {sets} sets of strength exercises
- Complete {count} strength sessions

Cardio:

- Run/cycle for {duration} minutes
- Cover {distance}km distance
- Complete {count} cardio sessions
- Burn {calories} calories

Consistency:

- Exercise {streak} days in a row
- Exercise {count} times this week
- Don’t miss a workout for {streak} days

### After Generation

1. Go to Quests tab
2. Tap +
3. View templates filtered by your level
4. Claim quests and start playing

Backend: `POST /api/generate-quest-templates`

Frontend: `QuestService.generateQuestTemplates()`; Admin UI in Settings → Developer Tools

## 🧩 Exercise/Exercise Type Generator

Use this developer tool to seed default exercise types and/or create sample exercises for users.

Where: Settings → Developer Tools → “Generate Exercises (Dev)”

### Endpoint

`POST /api/generate-exercises`

### Example Payload

```json
{
   "generateExerciseTypes": true,
   "exerciseTypeCount": 0,
   "exercisesPerUser": 0,
   "includeNotes": true
}
```

Notes:

- Set `generateExerciseTypes: true` and both counts to `0` to create a sensible default type catalog.
- Increase `exerciseTypeCount` to create additional types; set `exercisesPerUser` to create sample sessions per user.
- `includeNotes` adds descriptive notes to generated exercises for easier debugging.

### UI Controls

- Toggle “Generate Exercise Types” to include the type catalog.
- Fields:
   - Exercise Type Count (0 = default)
   - Exercises Per User (0 = none)
   - Include Notes (toggle)
- Quick Action: “Generate Exercise Types Only” runs a preset with defaults.

### Client Method

```dart
final res = await ExerciseService.generateExercises(
   generateExerciseTypes: true,
   exerciseTypeCount: 0,
   exercisesPerUser: 0,
   includeNotes: true,
);
```

This returns a JSON summary (saved counts, duplicates, etc.).