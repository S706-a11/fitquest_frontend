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

## ⚡ Quick Reference (Snippets)

Get current user via Provider:

```dart
final userProvider = Provider.of<UserProvider>(context, listen: false);
final user = userProvider.user;
```

Add XP (auto level-up handled in provider):

```dart
await userProvider.addXp(50);
ScaffoldMessenger.of(context).showSnackBar(
   const SnackBar(content: Text('+50 XP earned!')),
);
```

Fetch active quests:

```dart
final quests = await ApiService.getActiveQuests(userProvider.user!.id);
```

Get exercise types:

```dart
final types = await ExerciseService.getExerciseTypes();
```

## 📱 Phone Setup (Run on Device)

1. Find your PC IPv4 (e.g., 192.168.1.X). Scripts provided: `run_with_ip.ps1` (interactive) or `run_phone.ps1` (quick).
2. Update base URLs in `api_service.dart`, `quest_service.dart`, `exercise_service.dart`, and `user_service.dart` (if present) to `http://YOUR_IP:5105/api`.
3. Backend: use `UseUrls("http://0.0.0.0:5105")` and open firewall (see above).
4. Verify from your phone: open `http://YOUR_IP:5105/swagger/index.html`.

Android emulator: use `http://10.0.2.2:5105/api`.

### Port Configuration

The app is configured to always run on **port 3000** for web.

- Configuration: `.vscode/settings.json`
- Launch profiles: `.vscode/launch.json`

## 🧪 Testing

### API Connection Test

1. Open app → Settings → "API Connection Test"
2. Test individual endpoints
3. Verify API responses

### Manual Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🐛 Troubleshooting

### CORS Error

**Solution:** Configure CORS in backend `Program.cs`:

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

### Port Already in Use

```bash
# Find process using port 3000
netstat -ano | findstr :3000

# Kill process
taskkill /PID <PID> /F
```

### Backend Connection Failed

- Ensure backend is running on port 5105
- Check Swagger UI: `http://localhost:5105/swagger/index.html`
- For Android emulator, use `10.0.2.2` instead of `localhost`

### Email/name field mapping

Backend expects `displayName`. The app sends `displayName` when creating/updating users (handled in `api_service.dart`).

### GPS/Permissions

If GPS tracking doesn’t start, ensure location permissions are granted. The tracker shows a friendly message with a retry button if permissions are missing.

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  http: ^1.1.0              # HTTP client
  shared_preferences: ^2.2.2 # Local storage
  provider: ^6.1.1          # State management
  cupertino_icons: ^1.0.8   # iOS icons
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is for educational purposes.

## 👥 Team

- **Repository:** [S706-a11/fitquest_frontend](https://github.com/S706-a11/fitquest_frontend)
- **Branch:** got
- **Default:** main

## 🆘 Need Help?

This README now contains all setup, configuration, API, and troubleshooting guidance in one place. If anything’s unclear, open an issue or a discussion in the repository.

## 🎉 Getting Started

1. **Install dependencies:** `flutter pub get`
2. **Start backend:** Ensure API is running on port 5105
3. **Run app:** Double-click `run_web.bat` or press F5 in VS Code
4. **Create account:** Register a new user
5. **Start questing:** Begin your fitness journey!

Happy coding and stay fit! 🏋️‍♂️💪
