

# Define the array of winget applications to be installed
$wingetApps = @(
    "7zip.7zip",
    "CreativeTechnology.CreativeApp",
    "Discord.Discord",
    "ElectronicArts.EADesktop",
    "EpicGames.EpicGamesLauncher",
    "Git.Git",
    "GOG.Galaxy",
    "Microsoft.BingWallpaper",
    "Microsoft.Office",
    #"Microsoft.Teams",
    "Microsoft.VisualStudioCode.Insiders",
    "Nvidia.GeForceExperience",
    #"OpenWhisperSystems.Signal",
    "Plex.Plex",
    "Prusa3D.PrusaSlicer",
    "SlackTechnologies.Slack",
    "TechSmith.SnagIt.2023",
    "Valve.Steam", 
    "9N4WGH0Z6VHQ" # Win11 HEVC Encoding
)

<#
Leftovers
    Yealink USB Connect
    Razer Synapse
    Battle.net Launcher
#>

# Iterate through the array and install each winget application
foreach ($wingetApp in $wingetApps) {
    try {
        winget install $wingetApp --accept-source-agreements
        Write-Output "$wingetApp installed successfully"
    } catch [System.Management.Automation.ActionPreferenceStopException] {
        Write-Error "Error installing $wingetApp - $($_.Exception.Message)"
    }
}

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
