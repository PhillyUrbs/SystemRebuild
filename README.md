## Rebuild Script

The `rebuild.ps1` script automates the process of reinstalling standard applications and configuring settings after a fresh Windows install. It saves time and effort by automatically downloading and installing commonly used applications, as well as applying specific system configurations.

### Usage

To use the script, follow these steps:

1. Clone or download the repository to your local machine.
2. Open a PowerShell terminal with administrative privileges and navigate to the directory where the `rebuild.ps1` script is located.
3. Run the script by executing the following command:

    ```powershell
    .\rebuild.ps1
    ```

4. The script will automatically download and install the applications, and apply the configurations.

### Customization

The `rebuild.ps1` script can be customized to fit your specific needs. You can modify the list of applications to install by editing the script file. Simply add or remove the desired applications from the predefined list.

### Supported Applications

The script currently installs the following applications using `winget`:

- Bitwarden
- Discord
- EA Desktop
- Epic Games Launcher
- Git
- GOG Galaxy
- Microsoft Bing Wallpaper
- Microsoft Office
- Microsoft PowerShell
- Visual Studio Code Insiders
- Plex
- PrusaSlicer
- FanControl
- Razer Installer
- Steam
- Yealink USB Connect
- NVIDIA Control Panel
- Xbox Insider Hub
- Xbox Accessories
- Windows App

### Additional Configurations

The script also performs the following additional configurations:

- Downloads and installs the Battle.net launcher silently.
- Enables Windows hotpatching.
- Creates registry entries to install the BypassPaywall extension for Edge.
- Sets the Windows App environment to SH.
- Removes Razer Game Manager Service as a dependent service of Razer Synapse Service (commented out).
- Sets the power configuration to Ultimate Performance for desktops and Balanced for laptops.

### Notes

- Ensure `winget` is installed and configured on your system.
- Some applications may require additional configuration after installation.
- Uncomment and modify the additional configuration sections as needed.

Feel free to contribute to the script by improving the existing functionality.

Happy rebuilding!
