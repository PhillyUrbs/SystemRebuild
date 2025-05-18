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

# Define the array of winget applications to be installed
$wingetApps = @(
    "Bitwarden.Bitwarden",
    "Discord.Discord",
    "ElectronicArts.EADesktop",
    "EpicGames.EpicGamesLauncher",
    "Git.Git",
    "GOG.Galaxy",
    "Microsoft.BingWallpaper",
    "Microsoft.Office",
    "Microsoft.PowerShell",
    "Microsoft.VisualStudioCode.Insiders",
    #"mtkennerly.ludusavi", # Game Backups
    "Plex.Plex",
    "Prusa3D.PrusaSlicer",
    "Rem0o.FanControl",
    #"RazerInc.RazerInstaller",
    "Valve.Steam", 
    "Yealink.YealinkUSBConnect",
    #"9N4WGH0Z6VHQ", # Win11 HEVC Encoding (no longer working)
    # "9P1HQ5TQZMGD", # Microsoft Loop
    "9NF8H0H7WMLT", # NVIDIA Control Panel
    #"XP8K0HKJFRXGCK", # oh-my-posh
    "9PLDPG46G47Z", # Xbox Insider Hub
    "9NBLGGH30XJ3", # Xbox Accessories
    "9N1F85V9T8BN" # Windows App
)

if ($architecture -eq 12) {
    Write-Output "ARM64 architecture detected. Adjusting settings for ARM64 laptop..."
    $wingetApps = $wingetApps | Where-Object { $_ -notmatch "Valve.Steam|9NF8H0H7WMLT" }
} elseif ($architecture -eq 9) {
    Write-Output "x64 architecture detected."
} else {
    Write-Output "Other architecture detected: $architecture"
}

# Set power configuration to ultimate if it is a desktop. If it is a laptop, set power to balanced
# Power Scheme GUID: e9a42b02-d5df-448d-aa00-03f14749eb61  (Ultimate Performance) 
# Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced)
if ((Get-CimInstance -ClassName Win32_ComputerSystem).PCSystemType -eq 1) { # Desktop
    powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 # Set to Ultimate Performance
} else {
    # Laptop
    $wingetApps = $wingetApps | Where-Object { $_ -notmatch "Yealink.YealinkUSBConnect|9NF8H0H7WMLT|ElectronicArts.EADesktop|EpicGames.EpicGamesLauncher|GOG.Galaxy|Rem0o.FanControl" }
    powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e # Set to Balanced
}

<#
Leftovers
    BypassPaywall edge extension https://gitlab.com/magnolia1234/bypass-paywalls-chrome-clean/-/releases
        [DONE] allow extension install via reg key
        add extension to edge and allow auto updates. Not sure if edge extension developer mode is needed. 
#>

# Iterate through the array and install each winget application
foreach ($wingetApp in $wingetApps) {
    try {
        winget install $wingetApp -e --accept-source-agreements
        Write-Output "$wingetApp installed successfully"
    } catch [System.Management.Automation.ActionPreferenceStopException] {
        Write-Error "Error installing $wingetApp - $($_.Exception.Message)"
    }
}

# download and silently install the battle.net launcher. the download link is https://us.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe#/Battle.net-Setup.exe and the silent install switch is -s /quiet.
# Invoke-WebRequest -Uri "https://us.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe#/Battle.net-Setup.exe" -OutFile "Battle.net-Setup.exe"
# .\Battle.net-Setup.exe -s /quiet
# Remove-Item -Path "Battle.net-Setup.exe"
# Remove-Item -Path "$env:PUBLIC\Desktop\Battle.net.lnk"

# enable windows hotpatching
if (-Not (Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update" -Force
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Update" -Name "AllowRebootlessUpdates" -PropertyType DWord -Value 1 -Force

# create the registry entries to install the BypassPaywall extension for Edge
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallAllowlist" /v "1" /t REG_SZ /d "lkbebcjgcmobigpeffafkodonchffocl" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist" /v "1" /t REG_SZ /d "lkbebcjgcmobigpeffafkodonchffocl" /f

#need to install the extension manually from https://gitlab.com/magnolia1234/bypass-paywalls-chrome-clean/-/releases

# Windows App point to SelfHost environment
reg add HKCU\Software\Microsoft\Windows365 /v Environment /t REG_DWORD /d 0

# === CONFIG ===
$appPath = "C:\Program Files\Plex\Plex\plex.exe"
$gpuRegPath = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
$powerThrottleKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"

# === GPU Preference Setup ===
try {
    if (-not (Test-Path $gpuRegPath)) {
        New-Item -Path $gpuRegPath -Force | Out-Null
    }

    $escapedPath = $appPath.Replace("\", "\\")
    Set-ItemProperty -Path $gpuRegPath -Name "$escapedPath" -Value "GpuPreference=2;" -Force

    # Validate GPU setting
    $gpuValue = (Get-ItemProperty -Path $gpuRegPath -Name "$escapedPath" -ErrorAction Stop)."$escapedPath"
    if ($gpuValue -eq "GpuPreference=2;") {
        Write-Host "✅ GPU preference successfully set to High Performance for:"
        Write-Host "   $appPath"
    } else {
        Write-Warning "❌ Failed to validate GPU preference setting."
    }
}
catch {
    Write-Error "❌ Error setting GPU preference: $_"
}

# === Power Throttling Disable ===
try {
    if (-not (Test-Path $powerThrottleKey)) {
        New-Item -Path $powerThrottleKey -Force | Out-Null
    }

    New-ItemProperty -Path $powerThrottleKey -Name "PowerThrottlingOff" -Value 1 -PropertyType DWord -Force

    # Validate throttling setting
    $throttleValue = (Get-ItemProperty -Path $powerThrottleKey -Name "PowerThrottlingOff" -ErrorAction Stop).PowerThrottlingOff
    if ($throttleValue -eq 1) {
        Write-Host "✅ Power throttling has been successfully disabled system-wide."
    } else {
        Write-Warning "❌ Failed to validate PowerThrottlingOff setting."
    }
}
catch {
    Write-Error "❌ Error disabling power throttling: $_"
}

Write-Host "`n🔄 A system reboot is recommended for changes to take full effect."
