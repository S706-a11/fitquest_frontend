# FitQuest Flutter - Quick Start Scripts

## 🚀 Easy Launch Methods

### Method 1: Double-Click Batch Files (Easiest!)

#### Run Web App on Chrome (Port 3000)

Double-click: **`run_web.bat`**

- Opens Chrome
- Runs on http://localhost:3000
- No command line needed!

#### Run Web App on Edge (Port 3000)

Double-click: **`run_edge.bat`**

- Opens Microsoft Edge
- Runs on http://localhost:3000
- Alternative to Chrome

#### Interactive Launcher

Double-click: **`run_app.bat`**

- Choose Chrome, Edge, or Windows
- Menu-driven interface
- Easy platform switching

#### Run Windows Desktop App

Double-click: **`run_windows.bat`**

- Opens as native Windows app
- No CORS issues
- Better performance

---

### Method 2: VS Code (Recommended for Development)

1. Open VS Code
2. Press **F5** (or click Run > Start Debugging)
3. Select from dropdown:
   - **Flutter Web (Chrome - Port 3000)** ⭐ Most common
   - **Flutter Web (Edge - Port 3000)**
   - **Flutter Desktop (Windows)** - No CORS issues
   - **Flutter Mobile (Android)**

---

### Method 3: Terminal Commands

#### Web (Chrome, Port 3000)

```bash
flutter run -d chrome --web-port=3000
```

#### Windows Desktop

```bash
flutter run -d windows
```

#### Android Emulator

```bash
flutter run -d android
```

#### List All Devices

```bash
flutter devices
```

---

## 📋 Pre-Launch Checklist

Before running the app:

### ✅ Backend Running?

Check: http://localhost:5105/swagger/index.html

- If not working, start your backend API first

### ✅ CORS Configured?

Backend should allow `http://localhost:3000`

- See `PORT_CONFIGURATION.md` for details

### ✅ Dependencies Installed?

```bash
flutter pub get
```

---

## 🎯 Recommended Workflow

### First Time Setup

1. Install dependencies:

   ```bash
   flutter pub get
   ```

2. Start backend API (port 5105)

3. Run Flutter app:
   - **For web:** Double-click `run_web.bat`
   - **For desktop:** Double-click `run_windows.bat`

### Daily Development

1. Start backend API
2. Press **F5** in VS Code
3. Select "Flutter Web (Chrome - Port 3000)"
4. Start coding!

---

## 🔄 Hot Reload

While app is running:

### Make Code Changes

- **Hot Reload:** Press `r` in terminal (or save file in VS Code)
- **Hot Restart:** Press `R` in terminal
- **Quit:** Press `q` in terminal

### When to Hot Restart vs Full Restart

**Hot Reload** (Press `r`):

- UI changes
- Widget updates
- Function implementations

**Hot Restart** (Press `R`):

- Adding new dependencies
- Changing app initialization
- Provider changes

**Full Restart** (Stop and run again):

- pubspec.yaml changes
- Native code changes
- Asset additions

---

## 🌐 Access URLs

| What              | URL                                      | Notes    |
| ----------------- | ---------------------------------------- | -------- |
| Flutter App (Web) | http://localhost:3000                    | Your app |
| Backend API       | http://localhost:5105                    | REST API |
| Swagger UI        | http://localhost:5105/swagger/index.html | API docs |

---

## 💡 Pro Tips

### Tip 1: Use Windows Desktop for Development

- No CORS issues
- Faster hot reload
- Better debugging
- Run with: `flutter run -d windows`

### Tip 2: Keep Backend Running

- Start backend once, leave it running
- Focus on frontend development
- Backend auto-reloads on changes (if using dotnet watch)

### Tip 3: Use VS Code Launch Configurations

- Press F5 for quick start
- Pre-configured settings
- Easy device switching

### Tip 4: Test on Multiple Platforms

- Web: Good for UI testing
- Windows: Best for development (no CORS)
- Mobile: Test before production

---

## 🐛 Common Issues

### Port 3000 Already in Use

```bash
# Find process
netstat -ano | findstr :3000

# Kill process
taskkill /PID <PID> /F

# Or just change port in .vscode/settings.json
```

### Backend Not Running

```
Error: Failed host lookup
```

**Solution:** Start your backend API first

### CORS Error

```
Access to fetch has been blocked by CORS policy
```

**Solutions:**

1. Configure CORS in backend (see PORT_CONFIGURATION.md)
2. OR use Windows desktop: `flutter run -d windows`

### Hot Reload Not Working

**Solution:** Do a full restart:

```bash
# In terminal, press: R (capital R)
# Or stop app and run again
```

---

## 📱 Testing on Mobile

### Android Emulator

1. Start Android emulator
2. Update API URL in `api_service.dart`:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:5105/api';
   ```
3. Run:
   ```bash
   flutter run -d android
   ```

### iOS Simulator (Mac only)

1. Start iOS simulator
2. Run:
   ```bash
   flutter run -d ios
   ```

### Physical Device

1. Connect device via USB
2. Enable USB debugging
3. Update API URL to your computer's IP:
   ```dart
   static const String baseUrl = 'http://192.168.1.XXX:5105/api';
   ```
4. Run:
   ```bash
   flutter devices  # Find device ID
   flutter run -d <device-id>
   ```

---

## 🎓 Learning Resources

### Flutter Commands

```bash
flutter doctor          # Check setup
flutter devices         # List devices
flutter clean           # Clean build
flutter pub get         # Install dependencies
flutter pub upgrade     # Update dependencies
flutter run --help      # See all options
```

### VS Code Shortcuts

- **F5** - Start debugging
- **Shift+F5** - Stop debugging
- **Ctrl+F5** - Start without debugging
- **Ctrl+Shift+P** - Command palette
- **Ctrl+`** - Open terminal

---

## 📚 Documentation Files

- `PORT_CONFIGURATION.md` - Port setup details
- `API_INTEGRATION.md` - API usage guide
- `QUICK_REFERENCE.md` - Code examples
- `TROUBLESHOOTING.md` - Fix common issues
- `ARCHITECTURE.md` - System design

---

## ✨ You're All Set!

Your Flutter app is configured to run on port 3000.

**Quick Start:**

1. Start backend (http://localhost:5105)
2. Double-click `run_web.bat` or press F5 in VS Code
3. Start coding! 🚀

Happy coding! 💻
