# Flutter Runner with WiFi Support
# Usage: .\run_phone.ps1

Write-Host "`n=================================" -ForegroundColor Cyan
Write-Host "  FitQuest Mobile Runner (WiFi)" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Get PC local IP addresses
Write-Host "`n[YOUR PC IP ADDRESSES:]" -ForegroundColor Green
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -notmatch "^127\." -and 
    $_.InterfaceAlias -notmatch "Loopback" 
}

$primaryIP = $null
foreach ($ip in $ipAddresses) {
    $interface = $ip.InterfaceAlias
    $address = $ip.IPAddress
    Write-Host "   [$interface] " -NoNewline -ForegroundColor Yellow
    Write-Host "$address" -ForegroundColor White
    
    # Try to identify the WiFi adapter
    if ($interface -match "Wi-Fi|Wireless|WLAN" -and $null -eq $primaryIP) {
        $primaryIP = $address
    }
}

if ($null -eq $primaryIP -and $ipAddresses.Count -gt 0) {
    $primaryIP = $ipAddresses[0].IPAddress
}

Write-Host "`n[Update API URLs to:]" -ForegroundColor Cyan
Write-Host "   http://$primaryIP:5105/api" -ForegroundColor Yellow

Write-Host "`n[CONNECT YOUR PHONE VIA WiFi:]" -ForegroundColor Magenta
Write-Host "`n   For Android:" -ForegroundColor White
Write-Host "   1. Connect phone via USB first" -ForegroundColor Gray
Write-Host "   2. Enable USB Debugging in Developer Options" -ForegroundColor Gray
Write-Host "   3. Run: " -NoNewline -ForegroundColor Gray
Write-Host "adb tcpip 5555" -ForegroundColor Yellow
Write-Host "   4. Get your phone IP (Settings > WiFi > Network Details)" -ForegroundColor Gray
Write-Host "   5. Run: " -NoNewline -ForegroundColor Gray
Write-Host "adb connect PHONE_IP:5555" -ForegroundColor Yellow
Write-Host "   6. Disconnect USB cable" -ForegroundColor Gray
Write-Host "   7. Your phone is now connected wirelessly!" -ForegroundColor Green

Write-Host "`n   Or use automated setup:" -ForegroundColor White
Write-Host "   Run: " -NoNewline -ForegroundColor Gray
Write-Host ".\connect_wifi.ps1" -ForegroundColor Yellow

Write-Host "`n   For iOS:" -ForegroundColor White
Write-Host "   1. Connect iPhone and Mac/PC to same WiFi" -ForegroundColor Gray
Write-Host "   2. Enable 'Connect via network' in Xcode/Finder" -ForegroundColor Gray
Write-Host "   3. Device will appear in flutter devices" -ForegroundColor Gray

Write-Host "`n[Checking for connected devices...]" -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Cyan

flutter devices

Write-Host "`n===================================`n" -ForegroundColor Cyan
Write-Host "[Quick Commands:]" -ForegroundColor Yellow
Write-Host "   Automated WiFi setup: " -NoNewline -ForegroundColor White
Write-Host ".\connect_wifi.ps1" -ForegroundColor Green
Write-Host "   Manual WiFi connect: " -NoNewline -ForegroundColor White
Write-Host "adb tcpip 5555 && adb connect PHONE_IP:5555" -ForegroundColor Green
Write-Host "   Disconnect WiFi: " -NoNewline -ForegroundColor White
Write-Host "adb disconnect" -ForegroundColor Green
Write-Host "   Check devices: " -NoNewline -ForegroundColor White
Write-Host "flutter devices" -ForegroundColor Green

Write-Host "`n[Ready to run?]" -ForegroundColor Cyan
Write-Host "Enter device ID or press Enter to list devices again" -ForegroundColor Gray
$deviceChoice = Read-Host "Device ID"

if ($deviceChoice -eq "") {
    Write-Host "`n[Available devices:]" -ForegroundColor Yellow
    flutter devices
}
elseif ($deviceChoice.ToLower() -eq "all" -or $deviceChoice.ToLower() -eq "default") {
    Write-Host "`n>> Starting on default device..." -ForegroundColor Green
    flutter run
}
else {
    Write-Host "`n>> Starting on device: $deviceChoice" -ForegroundColor Green
    flutter run -d $deviceChoice
}
