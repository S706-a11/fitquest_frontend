# Running FitQuest on Your Phone - Complete Guide

## 🚀 Quick Start

### Step 1: Get Your PC's IP Address

Run one of these PowerShell scripts:

**Option A - Interactive (Recommended):**

```powershell
.\run_with_ip.ps1
```

**Option B - Quick:**

```powershell
.\run_phone.ps1
```

**Option C - Manual Command:**

```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notmatch "^127\." -and $_.InterfaceAlias -notmatch "Loopback" } | Select-Object IPAddress, InterfaceAlias
```

**Your IP will look like:**

- `192.168.1.x` (Home WiFi)
- `192.168.0.x` (Home WiFi)
- `10.0.0.x` (Some networks)

### Step 2: Update API URLs in Your App

You need to replace `localhost` with your PC's IP address in these files:

#### File 1: `lib/services/api_service.dart`

```dart
static const String baseUrl = 'http://192.168.1.x:5105/api';  // Replace 192.168.1.x with YOUR IP
```

#### File 2: `lib/services/quest_service.dart`

```dart
static const String baseUrl = 'http://192.168.1.x:5105/api';  // Replace 192.168.1.x with YOUR IP
```

#### File 3: `lib/services/exercise_service.dart`

```dart
static const String baseUrl = 'http://192.168.1.x:5105/api';  // Replace 192.168.1.x with YOUR IP
```

#### File 4: `lib/services/user_service.dart`

```dart
static const String baseUrl = 'http://192.168.1.x:5105/api';  // Replace 192.168.1.x with YOUR IP
```

### Step 3: Make Sure Backend Allows External Connections

Your ASP.NET Core backend needs to listen on all interfaces, not just localhost.

**Update your backend's `Program.cs` or `launchSettings.json`:**

```json
{
  "profiles": {
    "http": {
      "commandName": "Project",
      "launchBrowser": true,
      "applicationUrl": "http://0.0.0.0:5105", // Changed from localhost to 0.0.0.0
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```

**Or in Program.cs:**

```csharp
builder.WebHost.UseUrls("http://0.0.0.0:5105");
```

### Step 4: Configure Windows Firewall

Allow incoming connections on port 5105:

**PowerShell (Run as Administrator):**

```powershell
New-NetFirewallRule -DisplayName "FitQuest API" -Direction Inbound -LocalPort 5105 -Protocol TCP -Action Allow
```

**Or manually:**

1. Open Windows Defender Firewall
2. Advanced Settings → Inbound Rules → New Rule
3. Port → TCP → 5105 → Allow the connection

### Step 5: Connect Your Phone

#### For Android:

1. Enable USB Debugging on your phone:

   - Settings → About Phone → Tap "Build Number" 7 times
   - Settings → Developer Options → Enable "USB Debugging"

2. Connect phone to PC via USB

3. Check device is connected:

   ```powershell
   flutter devices
   ```

   You should see your phone listed.

4. Run the app:
   ```powershell
   flutter run
   ```
   Or select your device from the list:
   ```powershell
   flutter run -d <device-id>
   ```

#### For iOS:

1. Connect iPhone to PC via USB
2. Trust the computer on your iPhone
3. Make sure you have Xcode installed (Mac) or iOS development tools
4. Check device:
   ```powershell
   flutter devices
   ```
5. Run:
   ```powershell
   flutter run
   ```

### Step 6: Verify Connection

**On your phone, check if the app can reach the backend:**

1. Open the app
2. If there's an error connecting, check:
   - ✅ Phone and PC on same WiFi network
   - ✅ IP address is correct in service files
   - ✅ Backend is running and listening on 0.0.0.0:5105
   - ✅ Firewall rule is added
   - ✅ No VPN or proxy blocking connection

**Test from phone browser:**
Open browser on phone and navigate to:

```
http://192.168.1.x:5105/swagger/index.html
```

(Replace with YOUR IP)

If Swagger UI loads, your backend is accessible!

## 🔧 Troubleshooting

### Problem: "Connection refused" or "Network unreachable"

**Solution 1: Check same network**

```powershell
# On PC - Get your IP
ipconfig

# On Phone - Check WiFi settings
# Make sure first 3 numbers match (e.g., 192.168.1.x)
```

**Solution 2: Verify backend is accessible**

```powershell
# Test from PC first
curl http://localhost:5105/api/exercise-types

# Then test with IP
curl http://192.168.1.x:5105/api/exercise-types
```

**Solution 3: Check firewall**

```powershell
# List firewall rules
Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*5105*" }

# If not found, add rule (Run as Admin)
New-NetFirewallRule -DisplayName "FitQuest API" -Direction Inbound -LocalPort 5105 -Protocol TCP -Action Allow
```

### Problem: Phone not detected by Flutter

**For Android:**

```powershell
# Check ADB devices
flutter devices

# If not showing, try:
# 1. Unplug and replug USB cable
# 2. Toggle "USB Debugging" off and on
# 3. Change USB mode to "File Transfer" or "MTP"
# 4. Install USB drivers for your phone model
```

**For iOS:**

```powershell
# Make sure:
# 1. Phone is unlocked
# 2. You tapped "Trust" on the phone
# 3. iTunes/Apple Mobile Device service is running
```

### Problem: GPS not working on phone

Make sure you added location permissions:

**Android (`android/app/src/main/AndroidManifest.xml`):**

```xml
<manifest ...>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <application ...>
    </application>
</manifest>
```

**iOS (`ios/Runner/Info.plist`):**

```xml
<dict>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>FitQuest needs your location to track workout distance and route</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>FitQuest tracks your workout route</string>
</dict>
```

## 📱 Recommended Testing Flow

1. **Update IP addresses** in all service files
2. **Restart backend** with 0.0.0.0:5105
3. **Add firewall rule** for port 5105
4. **Connect phone** via USB
5. **Run script**: `.\run_with_ip.ps1`
6. **Select device** from the list
7. **Test API connection** in the app
8. **Test GPS tracking** outdoors

## 💡 Pro Tips

### Development Mode

For easier testing, consider using environment variables:

```dart
// lib/config/environment.dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:5105/api',
  );
}
```

Then run with:

```powershell
flutter run --dart-define=API_URL=http://192.168.1.x:5105/api
```

### Quick IP Check

Add to your Windows Terminal profile:

```powershell
function Get-MyIP {
    Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -notmatch "^127\." } |
    Select-Object -First 1 -ExpandProperty IPAddress
}
```

Then just run: `Get-MyIP`

### Backend CORS Configuration

Make sure your backend allows requests from your phone:

```csharp
// In Program.cs
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// ...
app.UseCors("AllowAll");
```

## 🎯 Checklist Before Running

- [ ] Got your PC's IP address
- [ ] Updated all 4 service files with IP
- [ ] Backend listening on 0.0.0.0:5105
- [ ] Firewall rule added for port 5105
- [ ] Phone connected and detected by Flutter
- [ ] Phone and PC on same WiFi
- [ ] Location permissions added to manifests
- [ ] Backend CORS configured

## 🚀 Ready to Run!

```powershell
# Quick command
.\run_with_ip.ps1

# Or manual
flutter run -d <your-device-id>
```

Your app should now connect to the backend and GPS tracking should work on your physical device! 🎉

---

**Need Help?**

- Check device connection: `flutter devices`
- Check backend status: `curl http://YOUR_IP:5105/api/exercise-types`
- View Flutter logs: `flutter logs`
- Check backend logs: Look at your API console output
