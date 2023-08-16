

# Define the array of winget applications to be installed
$wingetApps = @(
    "CreativeTechnology.CreativeApp",
    "Discord.Discord",
    "ElectronicArts.EADesktop",
    "EpicGames.EpicGamesLauncher",
    "Git.Git",
    "GOG.Galaxy",
    "Microsoft.BingWallpaper",
    "Microsoft.Office",
    "Microsoft.VisualStudioCode.Insiders",
    "Nvidia.GeForceExperience",
    "Plex.Plex",
    "Prusa3D.PrusaSlicer",
    "SlackTechnologies.Slack",
    "Valve.Steam", 
    "9N4WGH0Z6VHQ", # Win11 HEVC Encoding
    "9P1HQ5TQZMGD", # Microsoft Loop
    "9PLDPG46G47Z", # Xbox Insider Hub
    "9NBLGGH30XJ3" # Xbox Accessories
)

<#
Leftovers
    Yealink USB Connect
    Razer Synapse
    Battle.net Launcher
    FanControl https://getfancontrol.com/
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
