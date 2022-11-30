<#
Leftovers
    Yealink USB Connect
    Razer Synapse
    Battle.net Launcher
#>

$apps = {
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
}

foreach ($app in $apps)
{
    winget install $app        
}