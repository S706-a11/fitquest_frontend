# Android WiFi Debugging Setup
# This script helps you connect your Android phone via WiFi
# Usage: .\connect_wifi.ps1

Write-Host "`n=================================" -ForegroundColor Cyan
Write-Host "  Android WiFi Debugging Setup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

Write-Host "`n[Prerequisites:]" -ForegroundColor Yellow
Write-Host "   * Phone and PC on same WiFi network" -ForegroundColor White
Write-Host "   * USB cable (for initial setup)" -ForegroundColor White
Write-Host "   * USB Debugging enabled on phone" -ForegroundColor White
Write-Host "   * ADB installed (comes with Flutter)" -ForegroundColor White

Write-Host "`n[Step 1: Connect phone via USB]" -ForegroundColor Magenta
Write-Host "   Connect your phone with USB cable and press Enter..." -ForegroundColor Gray
$null = Read-Host

Write-Host "`n[Checking for USB-connected devices...]" -ForegroundColor Cyan
$devices = adb devices
Write-Host $devices

if ($devices -match "device$") {
    Write-Host "   >> Device found!" -ForegroundColor Green
}
else {
    Write-Host "   >> No device found!" -ForegroundColor Red
    Write-Host "   Make sure:" -ForegroundColor Yellow
    Write-Host "   • USB Debugging is enabled" -ForegroundColor White
    Write-Host "   • You authorized the PC on your phone" -ForegroundColor White
    Write-Host "   • USB cable is working" -ForegroundColor White
    exit
}

Write-Host "`n[Step 2: Enable WiFi debugging on phone]" -ForegroundColor Magenta
Write-Host "   Switching to WiFi mode..." -ForegroundColor Gray
adb tcpip 5555

Start-Sleep -Seconds 2

Write-Host "`n[Step 3: Get your phone IP address]" -ForegroundColor Magenta
Write-Host "   On your phone: Settings > WiFi > Network Details" -ForegroundColor Gray
Write-Host "   Or run: adb shell ip addr show wlan0" -ForegroundColor Gray
Write-Host "`n   Getting phone IP..." -ForegroundColor Gray

try {
    $phoneIP = adb shell ip addr show wlan0 | Select-String -Pattern "inet\s+(\d+\.\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
    if ($phoneIP) {
        Write-Host "   Phone IP detected: " -NoNewline -ForegroundColor Green
        Write-Host "$phoneIP" -ForegroundColor Yellow
    }
    else {
        Write-Host "   Could not auto-detect phone IP" -ForegroundColor Yellow
        $phoneIP = Read-Host "`n   Enter your phone IP address manually"
    }
}
catch {
    $phoneIP = Read-Host "`n   Enter your phone IP address manually"
}

Write-Host "`n[Step 4: Disconnect USB cable]" -ForegroundColor Magenta
Write-Host "   You can now unplug the USB cable" -ForegroundColor Gray
Write-Host "   Press Enter when ready..." -ForegroundColor Gray
$null = Read-Host

Write-Host "`n[Step 5: Connecting via WiFi...]" -ForegroundColor Magenta
Write-Host "   Connecting to $phoneIP`:5555..." -ForegroundColor Gray
$connectResult = adb connect "$($phoneIP):5555"
Write-Host "   $connectResult" -ForegroundColor White

Start-Sleep -Seconds 2

Write-Host "`n[Connected Devices:]" -ForegroundColor Green
adb devices

Write-Host "`n[Setup Complete!]" -ForegroundColor Green
Write-Host "`nYour phone is now connected via WiFi!" -ForegroundColor Cyan
Write-Host "`n[Next steps:]" -ForegroundColor Yellow
Write-Host "   1. Run: " -NoNewline -ForegroundColor White
Write-Host "flutter devices" -ForegroundColor Green -NoNewline
Write-Host " (to see your device)" -ForegroundColor White
Write-Host "   2. Run: " -NoNewline -ForegroundColor White
Write-Host ".\run_phone.ps1" -ForegroundColor Green -NoNewline
Write-Host " (to launch app)" -ForegroundColor White
Write-Host "   3. Or: " -NoNewline -ForegroundColor White
Write-Host "flutter run -d $phoneIP`:5555" -ForegroundColor Green

Write-Host "`n[Useful Commands:]" -ForegroundColor Yellow
Write-Host "   • Reconnect: " -NoNewline -ForegroundColor White
Write-Host "adb connect $phoneIP`:5555" -ForegroundColor Green
Write-Host "   • Disconnect: " -NoNewline -ForegroundColor White
Write-Host "adb disconnect" -ForegroundColor Green
Write-Host "   • Check connection: " -NoNewline -ForegroundColor White
Write-Host "adb devices" -ForegroundColor Green
Write-Host "   • Back to USB: " -NoNewline -ForegroundColor White
Write-Host "adb usb" -ForegroundColor Green

Write-Host "`n=================================" -ForegroundColor Cyan
