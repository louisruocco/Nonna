# Check if each txt file exists
$db = ".\db"

$paths = @(
    ".\db\gym.txt", 
    ".\db\meal-planner.txt", 
    ".\db\az-104.txt", 
    ".\db\other learning.txt"
)

Write-Host "Checking if db exists..."

if(!(Test-Path $db)){
    Write-Host "Creating db directory..."
    New-Item -ItemType Directory -Path $db
} else {
    Write-host "DB Directory already exists"
}

write-Host "Creating db files..." 

foreach($path in $paths){
    if(!(Test-Path $path)){
        New-Item -Path $path
    }
}

# Add data to relevant txt file