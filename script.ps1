# Check if each txt file exists
$db = ".\db"
$logs = ".\Logs"

$paths = @(
    "C:\Louis\Scripts\Nonna\db\gym.txt", 
    "C:\Louis\Scripts\Nonna\db\meal-planner.txt", 
    "C:\Louis\Scripts\Nonna\db\other learning.txt"
)

Write-Host "Checking if db exists..."

if(!(Test-Path $db)){
    Write-Host "Creating db directory..."
    New-Item -ItemType Directory -Path $db
} else {
    Write-host "DB Directory already exists"
}

foreach($path in $paths){
    if(!(Test-Path $path)){
        write-Host "Creating db files..." 
        New-Item -Path $path
    }
}

if(!(Test-Path $logs)){
    Write-Host "Creating Log repository..."
    New-Item -ItemType Directory -Path $logs
} else {
    Write-Host "Log repository present"
}

# Call Brent Ozar Blog Web Scraper script
# powershell.exe -File ".\scraper.ps1"

$apiKey = Get-Content "C:\Louis\Scripts\Nonna\db\\secrets.txt"
$topic = Get-Content "C:\Louis\Scripts\Nonna\db\other learning.txt"
$endpoint = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&channelType=any&q=$topic&key=$apiKey"
$res = Invoke-RestMethod $endpoint
$items = $res.items
$learning = foreach($item in $items){
    $titles = $item.snippet.title
    $urls = $item.id.videoId
    $table = @{ $titles = $urls }
    foreach($thing in $table){
        $keys = $thing.Keys
        $values = $thing.Values
        "$keys | <a href = 'https://www.youtube.com/watch?v=$values'>https://www.youtube.com/watch?v=$values</a>"
    }
}

# collect data and put in an email function Randomise {
Function Randomise { 
    param (
        [array] $db
    )

    return $db | Sort-Object{Get-Random}
}
function Pull-Data-From-DB {
    param (
        [array]$data
    )

    return $data
}

# Send email
function Send-Email {
    $username = (Get-Content "C:\Louis\Scripts\Nonna\db\creds.txt")[0]
    $password = (Get-Content "C:\Louis\Scripts\Nonna\db\creds.txt")[1] | ConvertTo-SecureString -AsPlainText -Force
    $gym = Get-Content "C:\Louis\Scripts\Nonna\db\gym.txt"
    $meals = Get-Content "C:\Louis\Scripts\Nonna\db\meal-planner.txt"
    $miscLearning = Get-Content "C:\Louis\Scripts\Nonna\db\other learning.txt"
    # $blogLink = Get-content "C:\Louis\Scripts\Nonna\db\Brent Ozar Blog Links.txt" | Select-Object -Last 1

    $mealPlanner = Randomise -db $meals
    $exercises = Randomise -db $gym

    $mealplan = Pull-Data-From-DB -data $mealPlanner
    $lunch = $mealplan[0]
    $dinner = $mealplan[1]

    $day = (Get-Date).DayOfWeek
    
    if($day -eq "Tuesday" -or $day -eq "Thursday"){
        $array = $exercises[0..7]
        $gymExercises = foreach($exercise in $array){
            "<li>$exercise</li>"
        }
    } else {
        $gymExercises = "<h3>No Gym Today<h3>"
    }

    if($day -eq "Monday"){
        $learningLinks = foreach ($item in $learning){
            "<li>$item</li>"
        }
        $body = @"
        <h1>Nonna</h1>
        <p>Hi Lou, Remember that I am always watching over you. Have a great day!. Love Nonna</p>
        <h2>Learning Topic of the Week</h2>
        <ul>
            <li>$miscLearning</li>
        </ul>
        <h2>This Week's Learning Resources:</h2>
            <ul>
                <li>$learningLinks</li>
            </ul>
        <h2>Today's Gym Session</h2>
        <hr>
        <ul>
            $gymexercises
        </ul>
        <h2>Today's Meal Plan</h2>
        <hr>
        <h3>Lunch: $Lunch</h3>
        <h3>Dinner: $dinner </h3>
"@
    } else {
        $body = @"
        <h1>Nonna</h1>
        <p>Hi Lou, Remember that I am always watching over you. Have a great day!. Love Nonna</p>
        <h2>Learning Topic of the Week</h2>
        <ul>
            <li>$miscLearning</li>
        </ul>
        <h2>Today's Gym Session</h2>
        <hr>
        <ul>
            $gymexercises
        </ul>
        <h2>Today's Meal Plan</h2>
        <hr>
        <h3>Lunch: $Lunch</h3>
        <h3>Dinner: $dinner </h3>
"@
        }

    $email = @{
        from = $username
        to = "louisruocco1@gmail.com"
        subject = "Nonna"
        smtpserver = "smtp.gmail.com"
        body = $body
        port = 587
        credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
        usessl = $true
        verbose = $true
    }

    Send-MailMessage @email -BodyAsHtml
}


Send-Email