## Rebuild Script

The `rebuild.ps1` script automates the process of reinstalling standard applications after a fresh Windows install. It saves time and effort by automatically downloading and installing commonly used applications, such as web browsers, productivity tools, and development environments.

### Usage

To use the script, follow these steps:

1. Clone or download the repository to your local machine.
2. Open a PowerShell terminal and navigate to the directory where the `rebuild.ps1` script is located.
3. Run the script by executing the following command:

    ```powershell
    .\rebuild.ps1
    ```

4. The script will prompt you to confirm the installation of each application. Press `Y` to proceed with the installation or `N` to skip it.
5. Sit back and relax while the script automatically downloads and installs the selected applications.

### Customization

The `rebuild.ps1` script can be customized to fit your specific needs. You can modify the list of applications to install by editing the script file. Simply add or remove the desired applications from the predefined list.

### Supported Applications

The script currently supports the following applications:

- Anything published to Winget
- Battle.net Launcher

Feel free to contribute to the script by improving the existing functionality.

Happy rebuilding!
