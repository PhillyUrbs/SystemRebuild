

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
    "RazerInc.RazerInstaller",
    "Valve.Steam", 
    "Yealink.YealinkUSBConnect",
    #"9N4WGH0Z6VHQ", # Win11 HEVC Encoding (no longer working)
    # "9P1HQ5TQZMGD", # Microsoft Loop
    "9NF8H0H7WMLT", #NVIDIA Control Panel
    #"XP8K0HKJFRXGCK", # oh-my-posh
    "9PLDPG46G47Z", # Xbox Insider Hub
    "9NBLGGH30XJ3", # Xbox Accessories
    "9N1F85V9T8BN" # Windows App
)

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
Invoke-WebRequest -Uri "https://us.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe#/Battle.net-Setup.exe" -OutFile "Battle.net-Setup.exe"
.\Battle.net-Setup.exe -s /quiet
Remove-Item -Path "Battle.net-Setup.exe"
Remove-Item -Path "$env:PUBLIC\Desktop\Battle.net.lnk"

<#
# download the latest dll from https://github.com/Mourdraug/FanControl.AsusWMI/releases and place it in C:\Program Files\FanControl\Plugins
$downloadUrl = "https://github.com/Mourdraug/FanControl.AsusWMI/releases/latest/download/FanControl.AsusWMI.dll"
$downloadPath = "C:\Program Files\FanControl\Plugins\FanControl.AsusWMI.dll"
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
Unblock-File $downloadPath
#>

# create the registry entries to install the BypassPaywall extension for Edge
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallAllowlist" /v "1" /t REG_SZ /d "lkbebcjgcmobigpeffafkodonchffocl" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist" /v "1" /t REG_SZ /d "lkbebcjgcmobigpeffafkodonchffocl" /f

#need to install the extension manually from https://gitlab.com/magnolia1234/bypass-paywalls-chrome-clean/-/releases

# Windows App point to SH environment
reg add HKCU\Software\Microsoft\Windows365 /v Environment /t REG_DWORD /d 0

# Remove Razer Game Manager Service as a Depenant service of Razer Synapse Service
# reg import "./Razer.reg"

<#
#stop and disable Razer Game Manager Service
# REQUIRES REBOOT
net stop "Razer Synapse Service"
net stop "Razer Game Manager Service"
sc.exe config "Razer Game Manager Service" start= disabled
net start "Razer Synapse Service"
#>

# Set power configuration to ultimate if it is a desktop. If it is a laptop, set power to balanced
# Power Scheme GUID: e9a42b02-d5df-448d-aa00-03f14749eb61  (Ultimate Performance) 
# Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced)
if ((Get-CimInstance -ClassName Win32_ComputerSystem).PCSystemType -eq 1) {
    powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
} else {
    powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e
}
