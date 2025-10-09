# Flutter Port Configuration Guide

## ✅ Fixed Port Configuration Complete!

Your Flutter web app is now configured to **always run on port 3000**.

---

## 🚀 How to Run Flutter on Port 3000

### Method 1: VS Code (Recommended)

1. Open VS Code
2. Press `F5` or go to Run > Start Debugging
3. Select **"Flutter Web (Chrome - Port 3000)"** from the dropdown
4. Your app will open at `http://localhost:3000`

### Method 2: Command Line

```bash
flutter run -d chrome --web-port=3000 --web-hostname=localhost
```

### Method 3: Using the Default Configuration

Just run the normal command - it will use port 3000 automatically:

```bash
flutter run -d chrome
```

The port is now set in `.vscode/settings.json` so it applies to all runs!

---

## 📁 Files Created/Modified

### 1. `.vscode/launch.json`

Pre-configured launch profiles for different platforms:

- Flutter Web (Chrome - Port 3000) ⭐ **Recommended**
- Flutter Web (Edge - Port 3000)
- Flutter Desktop (Windows)
- Flutter Mobile (Android)

### 2. `.vscode/settings.json`

Default Flutter run configuration:

- Always uses port 3000 for web
- Always uses localhost as hostname
- Includes Dart formatting settings

---

## 🔧 Backend CORS Configuration

Since your Flutter app now runs on port 3000, you need to update your backend CORS settings.

### Update Your Backend `Program.cs`:

**Add this BEFORE `builder.Build()`:**

```csharp
// CORS Configuration
builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterAppPolicy", policy =>
    {
        policy.WithOrigins(
                "http://localhost:3000",      // Flutter web port
                "http://127.0.0.1:3000"       // Alternative localhost
            )
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});
```

**Add this AFTER `app.Build()` and BEFORE `app.Run()`:**

```csharp
// Enable CORS
app.UseCors("FlutterAppPolicy");
```

### Full Example:

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// CORS Configuration
builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterAppPolicy", policy =>
    {
        policy.WithOrigins(
                "http://localhost:3000",
                "http://127.0.0.1:3000"
            )
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

var app = builder.Build();

// Configure HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("FlutterAppPolicy");  // ⭐ Add this line
app.UseAuthorization();
app.MapControllers();

app.Run();
```

---

## ✅ Verification Steps

### 1. Stop Any Running Flutter Apps

Close all Flutter web instances.

### 2. Restart Backend with CORS

1. Stop your backend API
2. Add the CORS configuration above
3. Restart your backend
4. Verify it's running at `http://localhost:5105`

### 3. Run Flutter App

```bash
flutter run -d chrome
```

### 4. Verify Port

- Check browser URL: should be `http://localhost:3000`
- Open DevTools Console (F12)
- Try registering a new user
- Should work without CORS errors!

---

## 🎯 Port Summary

| Service     | Port | URL                                      |
| ----------- | ---- | ---------------------------------------- |
| Flutter Web | 3000 | http://localhost:3000                    |
| Backend API | 5105 | http://localhost:5105                    |
| Swagger UI  | 5105 | http://localhost:5105/swagger/index.html |

---

## 🔍 Testing Different Platforms

### Chrome (Port 3000)

```bash
flutter run -d chrome
```

### Edge (Port 3000)

```bash
flutter run -d edge
```

### Windows Desktop (No port needed)

```bash
flutter run -d windows
```

### Android Emulator (No port needed, but API URL changes)

```bash
flutter run -d android
```

**Note:** For Android, change API URL to `http://10.0.2.2:5105/api` in `api_service.dart`

---

## 📱 Platform-Specific API URLs

### For Web (localhost:3000)

```dart
static const String baseUrl = 'http://localhost:5105/api';
```

### For Android Emulator

```dart
static const String baseUrl = 'http://10.0.2.2:5105/api';
```

### For iOS Simulator

```dart
static const String baseUrl = 'http://localhost:5105/api';
```

### For Physical Device

```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:5105/api';
// Example: http://192.168.1.100:5105/api
```

---

## 🛠️ Advanced Configuration

### Change Port to Something Else

If you want a different port (e.g., 8080), edit `.vscode/settings.json`:

```json
{
  "dart.flutterRunAdditionalArgs": [
    "--web-port=8080",
    "--web-hostname=localhost"
  ]
}
```

Don't forget to update backend CORS to allow the new port!

### Use a Specific Hostname

```json
{
  "dart.flutterRunAdditionalArgs": [
    "--web-port=3000",
    "--web-hostname=0.0.0.0" // Allows access from network
  ]
}
```

---

## 🐛 Troubleshooting

### Port 3000 Already in Use

```bash
# Windows - Find what's using port 3000
netstat -ano | findstr :3000

# Kill the process (replace PID with actual number)
taskkill /PID <PID> /F
```

### CORS Error Still Appears

1. Verify backend CORS configuration is added
2. Restart backend completely
3. Clear browser cache (Ctrl+Shift+Delete)
4. Hard reload page (Ctrl+F5)
5. Check browser console for exact error message

### Wrong Port Used

1. Close all Flutter instances
2. Check `.vscode/settings.json` exists
3. Run from VS Code (F5) instead of terminal
4. Or use: `flutter run -d chrome --web-port=3000`

### Can't Access from Another Device

1. Change hostname to `0.0.0.0` in settings
2. Use your computer's IP address
3. Update backend CORS to allow your IP
4. Make sure firewall allows port 3000

---

## 📝 Quick Commands Cheat Sheet

```bash
# Run on web (port 3000)
flutter run -d chrome

# Run on Windows desktop
flutter run -d windows

# Run on Android emulator
flutter run -d android

# List available devices
flutter devices

# Clean and rebuild
flutter clean
flutter pub get
flutter run -d chrome

# Check what's using port 3000
netstat -ano | findstr :3000
```

---

## 🎉 Benefits of Fixed Port

✅ **Consistent URLs** - Always `http://localhost:3000`
✅ **Easier Backend CORS** - Only need to allow one port
✅ **Better Bookmarking** - URL doesn't change between runs
✅ **Simpler Testing** - No need to update port numbers
✅ **Professional Setup** - Industry standard configuration

---

## 📚 Related Files

- `.vscode/launch.json` - Run configurations
- `.vscode/settings.json` - Default Flutter settings
- `lib/services/api_service.dart` - API URL configuration
- Backend `Program.cs` - CORS configuration

---

## ✨ Next Steps

1. ✅ Restart your Flutter app
2. ✅ Update backend CORS configuration
3. ✅ Test user registration
4. ✅ Verify no CORS errors
5. 🎯 Start building features!

Your development environment is now properly configured! 🚀
