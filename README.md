# FitQuest Frontend 🏃‍♂️💪

A gamified fitness tracking application built with Flutter, featuring quest-based challenges, XP progression, and real-time fitness tracking.

## ✨ Features

- 🎮 **Gamification** - Turn fitness into an RPG-style adventure
- 🎯 **Quest System** - Daily challenges and custom fitness goals
- 📊 **Progress Tracking** - Monitor XP, levels, and achievements
- 🏆 **Leaderboards** - Compete with friends
- 💪 **Exercise Library** - Comprehensive workout database
- 👤 **User Profiles** - Track personal fitness journey

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

## 📚 Documentation

- [**HOW_TO_RUN.md**](HOW_TO_RUN.md) - Quick start guide and launch options
- [**PORT_CONFIGURATION.md**](PORT_CONFIGURATION.md) - Port 3000 setup details
- [**API_INTEGRATION.md**](API_INTEGRATION.md) - Complete API documentation
- [**QUICK_REFERENCE.md**](QUICK_REFERENCE.md) - Code examples and patterns
- [**ARCHITECTURE.md**](ARCHITECTURE.md) - System architecture diagrams
- [**TROUBLESHOOTING.md**](TROUBLESHOOTING.md) - Common issues and solutions
- [**FIELD_MAPPING.md**](FIELD_MAPPING.md) - Backend field name reference

## 🎯 Key Features Implementation

### ✅ Implemented

- User authentication (login/register)
- User profile management
- XP and leveling system
- Active quest display
- Settings and logout
- API integration layer
- State management with Provider

### 🚧 To Be Implemented

- Quest creation and management UI
- Exercise tracking
- Leaderboard functionality
- Daily/Monthly goals
- Quest exercises integration
- Profile editing

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme.dart                   # App theming
├── models/
│   └── user.dart               # User data model
├── services/
│   ├── api_service.dart        # REST API client
│   └── auth_service.dart       # Authentication logic
├── providers/
│   └── user_provider.dart      # State management
├── pages/
│   ├── login_page.dart         # Login screen
│   ├── register_page.dart      # Registration screen
│   ├── home_page.dart          # Dashboard
│   ├── quests_page.dart        # Quest management
│   ├── quest_tracker_page.dart # Active quest tracking
│   ├── leaderboard_page.dart   # User rankings
│   ├── settings_page.dart      # Settings & profile
│   └── api_test_page.dart      # API debugging tool
└── widgets/
    ├── xp_bar.dart             # XP progress bar
    └── quest_card.dart         # Quest display card
```

## 🔧 Configuration

### API Endpoint

Located in `lib/services/api_service.dart`:

```dart
// For Web/iOS Simulator/Desktop
static const String baseUrl = 'http://localhost:5105/api';

// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:5105/api';

// For Physical Device
static const String baseUrl = 'http://YOUR_IP:5105/api';
```

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

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more details.

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

- Check [HOW_TO_RUN.md](HOW_TO_RUN.md) for setup instructions
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Review [API_INTEGRATION.md](API_INTEGRATION.md) for API details
- Use [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for code examples

## 🎉 Getting Started

1. **Install dependencies:** `flutter pub get`
2. **Start backend:** Ensure API is running on port 5105
3. **Run app:** Double-click `run_web.bat` or press F5 in VS Code
4. **Create account:** Register a new user
5. **Start questing:** Begin your fitness journey!

Happy coding and stay fit! 🏋️‍♂️💪
