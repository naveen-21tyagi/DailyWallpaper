# Get current directory
$currentDirectory = (Get-Location).Path

# Define configuration file path
$jsonPath = $currentDirectory + "\config.json"

# Read the configuration file
$config = Get-Content -Path $jsonPath | ConvertFrom-Json

# Get the path to the current wallpaper
$currentWallpaper = $config.currentWallpaper

# Get the index of the current wallpaper in the list of images
$currentIndex = $config.images.IndexOf($currentWallpaper)

# Determine the index of the next wallpaper
if ($currentIndex -eq ($config.images.Count - 1)) {
    # If the current wallpaper is the last image, set the next wallpaper to the first image
    $nextIndex = 0
} else {
    # Otherwise, set the next wallpaper to the image after the current wallpaper
    $nextIndex = $currentIndex + 1
}

# Get the path to the next wallpaper
$nextWallpaper = $config.images[$nextIndex]

# Define the signature for the SystemParametersInfo function
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

# Define the constants for the SystemParametersInfo function
$SPI_SETDESKWALLPAPER = 0x0014
$SPIF_UPDATEINIFILE = 0x01
$SPIF_SENDCHANGE = 0x02

# Call the SystemParametersInfo function to set the desktop wallpaper
[Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $nextWallpaper, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)

# Update the current wallpaper in the configuration file
$config.currentWallpaper = $nextWallpaper
$config | ConvertTo-Json | Set-Content -Path $jsonPath
