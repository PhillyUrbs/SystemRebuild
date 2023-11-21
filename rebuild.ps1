

# Define the array of winget applications to be installed
$wingetApps = @(
    "Bitwarden.Bitwarden",
    #"CreativeTechnology.CreativeApp",
    "Discord.Discord",
    "ElectronicArts.EADesktop",
    "EpicGames.EpicGamesLauncher",
    "Git.Git",
    "GOG.Galaxy",
    "Microsoft.BingWallpaper",
    "Microsoft.Office",
    "Microsoft.VisualStudioCode.Insiders",
    #"mtkennerly.ludusavi", # Game Backups
    #"Nvidia.GeForceExperience",
    "Plex.Plex",
    "Prusa3D.PrusaSlicer",
    "RazerInc.RazerInstaller",
    "SlackTechnologies.Slack",
    "Valve.Steam", 
    "Yealink.YealinkUSBConnect",
    "9N4WGH0Z6VHQ", # Win11 HEVC Encoding
    "9P1HQ5TQZMGD", # Microsoft Loop
    #"XP8K0HKJFRXGCK", # oh-my-posh
    "9PLDPG46G47Z", # Xbox Insider Hub
    "9NBLGGH30XJ3" # Xbox Accessories
)

<#
Leftovers
    Battle.net Launcher https://www.blizzard.com/en-us/download/
    .\Battle.net-Setup.exe --lang=enUS --installpath="C:\Program Files (x86)\Battle.net"
    FanControl https://getfancontrol.com/
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

# import registry changes from BypassPawall.reg and skip any prompts
reg import "./BypassPawall.reg" /f

#need to install the extension manually from https://gitlab.com/magnolia1234/bypass-paywalls-chrome-clean/-/releases

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
