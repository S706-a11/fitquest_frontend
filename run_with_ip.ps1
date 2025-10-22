# Flutter Run Helper - Shows IP Address for Phone Testing
# Usage: .\run_with_ip.ps1

Write-Host "`n=================================" -ForegroundColor Cyan
Write-Host "  FitQuest Flutter Runner" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Get local IP addresses
Write-Host "`n📱 Your Local IP Addresses:" -ForegroundColor Green
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -notmatch "^127\." -and 
    $_.InterfaceAlias -notmatch "Loopback" 
}

foreach ($ip in $ipAddresses) {
    $interface = $ip.InterfaceAlias
    $address = $ip.IPAddress
    Write-Host "   $interface : " -NoNewline -ForegroundColor Yellow
    Write-Host "$address" -ForegroundColor White
}

Write-Host "`n💡 To connect from your phone:" -ForegroundColor Cyan
Write-Host "   1. Make sure phone and PC are on same WiFi" -ForegroundColor White
Write-Host "   2. Update API base URL in your app to use one of the IPs above" -ForegroundColor White
Write-Host "   3. Example: http://192.168.x.x:5105/api" -ForegroundColor White

Write-Host "`n🚀 Starting Flutter..." -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan

# Ask user which device to run on
Write-Host "`nSelect device:" -ForegroundColor Yellow
Write-Host "1. Edge (Web)" -ForegroundColor White
Write-Host "2. Chrome (Web)" -ForegroundColor White
Write-Host "3. Windows" -ForegroundColor White
Write-Host "4. Physical Device (check with 'flutter devices')" -ForegroundColor White
Write-Host "5. Show available devices" -ForegroundColor White

$choice = Read-Host "`nEnter choice (1-5)"

switch ($choice) {
    "1" { 
        Write-Host "`n🌐 Running on Edge..." -ForegroundColor Green
        flutter run -d edge --web-port=3000
    }
    "2" { 
        Write-Host "`n🌐 Running on Chrome..." -ForegroundColor Green
        flutter run -d chrome --web-port=3000
    }
    "3" { 
        Write-Host "`n💻 Running on Windows..." -ForegroundColor Green
        flutter run -d windows
    }
    "4" {
        Write-Host "`n📱 Listing devices..." -ForegroundColor Green
        flutter devices
        Write-Host "`nEnter device ID:" -ForegroundColor Yellow
        $deviceId = Read-Host
        Write-Host "`n📱 Running on device $deviceId..." -ForegroundColor Green
        flutter run -d $deviceId
    }
    "5" {
        Write-Host "`n📱 Available devices:" -ForegroundColor Green
        flutter devices
        Write-Host "`nRun script again to launch on a device." -ForegroundColor Yellow
    }
    default { 
        Write-Host "`n❌ Invalid choice. Running on default device..." -ForegroundColor Red
        flutter run
    }
}
