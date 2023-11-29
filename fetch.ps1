# Create BingWallpapers folder in the current directory
New-Item -ItemType Directory -Name "BingWallpapers"

# Get current directory
$currentDirectory = (Get-Location).Path

# Define the URL for Bing Image Archive API
$apiUrl = "bing.com/HPImageArchive.aspx?format=js&idx=0&n=8&mkt=en-IN"

# Send a request to the API and convert the response to a PowerShell object
$response = Invoke-RestMethod -Uri $apiUrl

# Loop through each image in the response
foreach ($image in $response.images) {
    # Define the URL for the image
    $imageUrl = "bing.com" + $image.url

    # Define the path where the image will be saved
    $imagePath = $currentDirectory+ "\BingWallpapers\" + $image.startdate + ".jpg"

    # Download the image
    Invoke-WebRequest -Uri $imageUrl -OutFile $imagePath
}

# Define the path of stored images directory
$imagesPath = $currentDirectory+ "\BingWallpapers\"

# Get the list of images in the directory
$images = Get-ChildItem -Path $imagesPath -Filter "*.jpg"

# Sort the images by name in descending order
$sortedImages = $images | Sort-Object Name -Descending

# Get the path to the first image
$firstImagePath = $sortedImages[0].FullName

# Create an object to store the sorted list of images and the current wallpaper
$config = @{
    "images" = $sortedImages.FullName
    "currentWallpaper" = $firstImagePath
}

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
[Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $firstImagePath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)

# Convert the object to a JSON string
$json = $config | ConvertTo-Json

# Define configuration file path
$jsonPath = $currentDirectory + "\config.json"

# Write the JSON string to the configuration file
$json | Set-Content -Path $jsonPath
