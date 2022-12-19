

# Define the array of winget applications to be installed
$wingetApps = @(
    "7zip.7zip",
    "Corsair.iCUE.4",
    "CreativeTechnology.CreativeApp",
    "Discord.Discord",
    "ElectronicArts.EADesktop",
    "GOG.Galaxy",
    "Microsoft.BingWallpaper",
    "Microsoft.Office",
    "Microsoft.Teams",
    "Microsoft.VisualStudioCode",
    "Nvidia.GeForceExperience",
    "OpenWhisperSystems.Signal",
    "Plex.Plex",
    "Prusa3D.PrusaSlicer",
    "PuTTY.PuTTY",
    "SlackTechnologies.Slack",
    "TechSmith.SnagIt.2022", #Look for 2023 upgrade
    "Valve.Steam"
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
        winget install $wingetApp | Out-Null
        Write-Output "$wingetApp installed successfully"
    } catch [System.Management.Automation.ActionPreferenceStopException] {
        Write-Error "Error installing $wingetApp: $($_.Exception.Message)"
    }
}
