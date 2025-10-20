# 🧪 How to Access API Test Page

## Quick Access Steps

### Option 1: Via Settings (Recommended)

1. **Run the app**

   ```bash
   flutter run -d edge
   ```

2. **Login** to your account (or register if new)

3. **Navigate to Settings**

   - Click the **Settings** icon in the bottom navigation bar (rightmost icon)

4. **Scroll down** to the "Developer Tools" section

5. **Click "API Connection Test"**
   - This opens the API Test Page where you can test all backend endpoints

---

## What You Can Test

The API Test Page allows you to test:

### ✅ User Endpoints

- **Get All Users** - Fetch all users from database
- **Create Test User** - Create a test user with timestamp

### ✅ Exercise Endpoints

- **Get Exercises** - Fetch all available exercises
- **Get Exercise Types** - Fetch exercise categories

---

## Features

- **Live API Testing** - Test backend endpoints without writing code
- **Response Viewer** - See full JSON responses
- **Error Display** - View error messages if API calls fail
- **Troubleshooting Tips** - Built-in help for common issues

---

## Troubleshooting

### API Not Responding?

1. Make sure your backend API is running at `http://localhost:5105`
2. Check Swagger UI: `http://localhost:5105/swagger/index.html`
3. For Android emulator, use: `http://10.0.2.2:5105`
4. For physical device, use your computer's IP address

### Can't See the Page?

- Make sure you're logged in
- Navigate to Settings (bottom right icon)
- Scroll to "Developer Tools" section
- Click "API Connection Test"

---

## Screenshot Guide

```
┌─────────────────────────────┐
│         FitQuest            │
├─────────────────────────────┤
│  [Home] [Quests] ... [⚙️]   │ ← Click Settings
└─────────────────────────────┘
              ↓
┌─────────────────────────────┐
│         SETTING             │
├─────────────────────────────┤
│  Profile              >     │
│  Notification         >     │
│  Theme           Dark       │
│ ─────────────────────────── │
│  Developer Tools            │
│  API Connection Test  🐛    │ ← Click this!
└─────────────────────────────┘
              ↓
┌─────────────────────────────┐
│  API Connection Test        │
├─────────────────────────────┤
│  [Get All Users]            │ ← Test buttons
│  [Get Exercise Types]       │
│  [Get Exercises]            │
│  [Create Test User]         │
│                             │
│  Result:                    │
│  ✅ SUCCESS or ❌ FAILED     │
└─────────────────────────────┘
```

---

## Quick Commands

```bash
# Run on Edge browser
flutter run -d edge

# Run on Chrome (port 3000)
flutter run -d chrome --web-port 3000

# Run on Windows desktop
flutter run -d windows
```

---

**Status:** ✅ Available in Settings → Developer Tools  
**Updated:** October 20, 2025
