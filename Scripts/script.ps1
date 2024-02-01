$date = Get-Date -Format "yyyyMMdd"

$db = (Get-Content "C:\Louis\Scripts\Nonna\utils\paths.txt")[0]
$logs = (Get-Content "C:\Louis\Scripts\Nonna\utils\paths.txt")[1]

$paths = @(
    "$db\gym.txt", 
    "$db\meal-planner.txt", 
    "$db\other learning.txt"
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

$apiKey = (Get-Content "C:\Louis\Scripts\Nonna\utils\secrets.txt")[3]
$topic = Get-Content "$db\other learning.txt"
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
    $username = (Get-Content "C:\Louis\Scripts\Nonna\utils\secrets.txt")[0]
    $password = (Get-Content "C:\Louis\Scripts\Nonna\utils\secrets.txt")[1] | ConvertTo-SecureString -AsPlainText -Force
    $emailAddress = (Get-Content "C:\Louis\Scripts\Nonna\utils\secrets.txt")[2]
    $gym = Get-Content "$db\gym.txt"
    $meals = Get-Content "$db\meal-planner.txt"
    $miscLearning = Get-Content "$db\other learning.txt"
    $randomiser = Get-Content "$db\questions.txt"
    # $blogLink = Get-content "$db\Brent Ozar Blog Links.txt" | Select-Object -Last 1

    $randomise = $randomiser | Sort-Object{Get-Random}
    $questions = $randomise[0..11]
    $results = foreach($question in $questions){
        "<li>$question</li>"
    }
    
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

    $learningLinks = foreach ($item in $learning){
        "<li>$item</li>"
    }

    $body = @"
    <h1>Nonna</h1>
    <p>Hi Lou, Remember that I am always watching over you. Have a great day!. Love Nonna</p>
    <h2>AZ-700 Revision</h2>
    <ul>
        $results    
    </ul>
    <h2>Learning Topic of the Week</h2>
    <ul>
        <li>$miscLearning</li>
    </ul>
    <h2>This Week's Learning Resources:</h2>
        <ul>
            $learningLinks
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

    $email = @{
        from = $username
        to = $emailAddress
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

function Send-Error {
    $username = (Get-Content "C:\Louis\Scripts\Nonna\utils\secrets.txt")[0]
    $password = (Get-Content "C:\Louis\Scripts\Nonna\utils\secrets.txt")[1] | ConvertTo-SecureString -AsPlainText -Force
    $emailAddress = (Get-Content "C:\Louis\Scripts\Nonna\utils\secrets.txt")[2]
    $Error | Out-File "$logs\errorlog_$date.txt"
    $body = @"
    <h1>Nonna | Error Occurred</h1>
    <p>Hi Lou, looks like an error occurred on my side. I'll log the error in $db\Logs\errorlog_$date.txt for you to review and fix. Sorry</p>
"@

    $err = @{
        from = $username
        to = $emailAddress
        subject = "Nonna | Error Occured"
        smtpserver = "smtp.gmail.com"
        body = $body
        port = 587
        credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
        usessl = $true
        verbose = $true
    }

    Send-MailMessage @err -BodyAsHtml
}

try {
    Send-Email -ErrorAction Stop
} catch {
    Send-Error
}