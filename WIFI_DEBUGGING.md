# WiFi Debugging Quick Reference

## 🚀 Quick Start (Android via WiFi)

### One-Time Setup

1. **Connect phone via USB first**
2. **Enable WiFi debugging:**
   ```powershell
   adb tcpip 5555
   ```
3. **Get phone's IP address:**
   - Settings → WiFi → Your Network → IP Address
   - Or: `adb shell ip addr show wlan0`
4. **Connect via WiFi:**
   ```powershell
   adb connect PHONE_IP:5555
   ```
   Example: `adb connect 192.168.1.50:5555`
5. **Unplug USB cable**
6. **Verify connection:**
   ```powershell
   adb devices
   ```

### Automated Setup

Run the automated setup script:

```powershell
.\connect_wifi.ps1
```

This script will:

- Check for USB connection
- Enable WiFi debugging
- Detect phone's IP automatically
- Connect via WiFi
- Verify connection

## 📱 Running Your App

### Option 1: Using run_phone.ps1

```powershell
.\run_phone.ps1
```

Shows IPs and device list, then launches app

### Option 2: Direct Flutter Command

```powershell
flutter run -d PHONE_IP:5555
```

### Option 3: Let Flutter Choose

```powershell
flutter run
```

(If only one device is connected)

## 🔧 Common Commands

### Connection Management

```powershell
# Check connected devices
adb devices

# Connect to phone via WiFi
adb connect 192.168.1.50:5555

# Disconnect from WiFi
adb disconnect

# Disconnect specific device
adb disconnect 192.168.1.50:5555

# Switch back to USB mode
adb usb

# Reconnect (if connection drops)
adb connect PHONE_IP:5555
```

### Device Information

```powershell
# Get phone's IP address
adb shell ip addr show wlan0

# Get device model
adb shell getprop ro.product.model

# Check WiFi status
adb shell dumpsys wifi | findstr "mNetworkInfo"
```

### Flutter Commands

```powershell
# List all devices
flutter devices

# Run on specific device
flutter run -d DEVICE_ID

# Hot reload (while app is running)
r

# Hot restart (while app is running)
R

# View logs
flutter logs
```

## 💡 Pro Tips

### Keep Connection Alive

WiFi debugging can disconnect. To reconnect quickly:

```powershell
# Create a function in your PowerShell profile
function Reconnect-Phone {
    param([string]$IP = "192.168.1.50")
    adb connect "$IP:5555"
    adb devices
}
```

Then just run: `Reconnect-Phone`

### Multiple Devices

```powershell
# Connect to multiple phones
adb connect 192.168.1.50:5555
adb connect 192.168.1.51:5555

# Run on specific device
flutter run -d 192.168.1.50:5555
```

### Check Connection Status

```powershell
adb devices -l
# Shows detailed device info including model and connection type
```

## ⚠️ Troubleshooting

### Problem: "unable to connect to..."

**Solutions:**

```powershell
# 1. Check phone and PC are on same WiFi
ipconfig  # Check PC's IP
# Check phone's IP in WiFi settings

# 2. Try reconnecting
adb disconnect
adb connect PHONE_IP:5555

# 3. Restart ADB server
adb kill-server
adb start-server
adb connect PHONE_IP:5555

# 4. Check if port 5555 is open on phone
adb shell netstat | findstr 5555
```

### Problem: Connection keeps dropping

**Solutions:**

1. **Disable battery optimization** for ADB on phone
2. **Keep screen on** during development
3. **Use USB** if WiFi is unstable
4. **Check router settings** - some routers block device-to-device communication

### Problem: "device unauthorized"

**Solutions:**

1. **Check phone screen** - authorization dialog may have appeared
2. **Revoke USB debugging** authorizations and reconnect
3. **Re-enable WiFi debugging:**
   ```powershell
   adb disconnect
   # Connect USB
   adb tcpip 5555
   adb connect PHONE_IP:5555
   ```

### Problem: Can't find phone's IP

**Method 1: From PC via ADB**

```powershell
adb shell ip addr show wlan0 | findstr "inet "
```

**Method 2: On Phone**

- Settings → About Phone → Status → IP Address
- Settings → WiFi → Current Network → Advanced

**Method 3: Using App**

- Install "Network Info II" or similar from Play Store

## 🎯 Complete Workflow Example

```powershell
# 1. Initial WiFi setup (USB connected)
adb tcpip 5555
adb shell ip addr show wlan0  # Note the IP

# 2. Disconnect USB, connect via WiFi
adb connect 192.168.1.50:5555

# 3. Verify
adb devices
# Output: 192.168.1.50:5555    device

# 4. Update API URLs in your code
# Change localhost to your PC's IP in service files

# 5. Run Flutter app
flutter run -d 192.168.1.50:5555

# 6. Test GPS features (go outside!)
# The map and GPS tracking will work on the phone
```

## 📋 Checklist for First Run

- [ ] Phone and PC on same WiFi network
- [ ] USB Debugging enabled on phone
- [ ] ADB working (`adb devices` shows your phone)
- [ ] WiFi debugging enabled (`adb tcpip 5555`)
- [ ] Phone's IP address noted
- [ ] Connected via WiFi (`adb connect IP:5555`)
- [ ] USB cable disconnected
- [ ] Device shows in `flutter devices`
- [ ] API URLs updated to use PC's IP
- [ ] Backend running and accessible from phone
- [ ] Firewall rule added for port 5105
- [ ] Location permissions added to AndroidManifest.xml

## 🚀 You're Ready!

```powershell
# Quick command to run
.\run_phone.ps1

# Or
flutter run
```

Your phone will now receive the app wirelessly, and you can test the GPS tracker features! 🎉
