# Ensure script is running as Administrator
function Ensure-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Host "🔒 Script not running as administrator. Restarting with elevated privileges..."
        $newProcess = Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -PassThru
        $newProcess.WaitForExit()
        exit
    }
}
Ensure-Admin

# Detect system architecture and role
$arch = (Get-CimInstance -ClassName Win32_OperatingSystem).OSArchitecture
$archType = if ($arch -like "*ARM64*") { "ARM64" } elseif ($arch -like "*64*") { "x64" } else { "Other" }

$deviceType = (Get-CimInstance -ClassName Win32_ComputerSystem).PCSystemType
$deviceRole = if ($deviceType -eq 1) { "Desktop" } else { "Laptop" }

Write-Host "🔍 System Context: Architecture = $archType | Device = $deviceRole"

# Set power plan based on device role
try {
    if ($deviceRole -eq "Desktop") {
        powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
        Write-Host "⚡ Power plan set to Ultimate Performance"
    } else {
        powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e
        Write-Host "🔋 Power plan set to Balanced"
    }
} catch {
    Write-Warning "❌ Failed to set power plan: $_"
}

# === Load App List from JSON and Filter ===
$appConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "winget-apps.json"
if (-Not (Test-Path $appConfigPath)) {
    Write-Error "❌ App configuration file not found at: $appConfigPath"
    exit 1
}
try {
    $rawAppList = Get-Content $appConfigPath -Raw | ConvertFrom-Json
    Write-Host "📦 Loaded $($rawAppList.Count) apps from configuration."
} catch {
    Write-Error "❌ Failed to parse winget-apps.json: $_"
    exit 1
}

$filteredApps = $rawAppList | Where-Object {
    $_.ExcludeOn -notcontains $archType -and $_.ExcludeOn -notcontains $deviceRole
}

foreach ($app in $filteredApps) {
    try {
        Write-Host "📥 Installing $($app.Name)..."
        winget install $($app.Id) -e --accept-source-agreements --accept-package-agreements
        Write-Host "✅ Installed: $($app.Name)"
    } catch {
        Write-Warning "❌ Failed to install $($app.Name): $($_.Exception.Message)"
    }
}

# === Enable Windows Hotpatching ===
try {
    $updatePath = "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update"
    if (-not (Test-Path $updatePath)) {
        New-Item -Path $updatePath -Force | Out-Null
    }
    New-ItemProperty -Path $updatePath -Name "AllowRebootlessUpdates" -PropertyType DWord -Value 1 -Force | Out-Null
    Write-Host "✅ Enabled Windows Hotpatching"
} catch {
    Write-Warning "❌ Failed to enable Hotpatching: $_"
}

# === BypassPaywall Extension for Edge ===
try {
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallAllowlist" /v "1" /t REG_SZ /d "lkbebcjgcmobigpeffafkodonchffocl" /f | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist" /v "1" /t REG_SZ /d "lkbebcjgcmobigpeffafkodonchffocl" /f | Out-Null
    Write-Host "✅ BypassPaywall extension policy applied to Edge"
} catch {
    Write-Warning "❌ Failed to apply Edge extension policy: $_"
}

# === Windows App SelfHost Environment ===
try {
    reg add HKCU\Software\Microsoft\Windows365 /v Environment /t REG_DWORD /d 0 /f | Out-Null
    Write-Host "✅ Windows365 Environment set to SelfHost"
} catch {
    Write-Warning "❌ Failed to apply Windows App environment setting: $_"
}

# === Set GPU Preference for Plex ===
try {
    $appPath = "C:\Program Files\Plex\Plex\plex.exe"
    $gpuRegPath = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
    if (-not (Test-Path $gpuRegPath)) {
        New-Item -Path $gpuRegPath -Force | Out-Null
    }

    $escapedPath = $appPath.Replace("\", "\\")
    Set-ItemProperty -Path $gpuRegPath -Name "$escapedPath" -Value "GpuPreference=2;" -Force

    $gpuValue = (Get-ItemProperty -Path $gpuRegPath -Name "$escapedPath" -ErrorAction Stop)."$escapedPath"
    if ($gpuValue -eq "GpuPreference=2;") {
        Write-Host "✅ GPU preference set to High Performance for $appPath"
    } else {
        Write-Warning "⚠️ Failed to validate GPU preference setting"
    }
} catch {
    Write-Error "❌ Error setting GPU preference: $_"
}

# === Disable Power Throttling ===
try {
    $powerThrottleKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
    if (-not (Test-Path $powerThrottleKey)) {
        New-Item -Path $powerThrottleKey -Force | Out-Null
    }

    New-ItemProperty -Path $powerThrottleKey -Name "PowerThrottlingOff" -Value 1 -PropertyType DWord -Force | Out-Null
    $throttleValue = (Get-ItemProperty -Path $powerThrottleKey -Name "PowerThrottlingOff" -ErrorAction Stop).PowerThrottlingOff
    if ($throttleValue -eq 1) {
        Write-Host "✅ Power throttling disabled system-wide"
    } else {
        Write-Warning "⚠️ Failed to validate PowerThrottlingOff setting"
    }
} catch {
    Write-Error "❌ Error disabling power throttling: $_"
}

Write-Host "`n🔄 A system reboot is recommended for all changes to take effect."
