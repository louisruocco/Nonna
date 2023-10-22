# Check if each txt file exists
$db = ".\db"

$paths = @(
    "C:\Scripts\Nonna\db\gym.txt", 
    "C:\Scripts\Nonna\db\meal-planner.txt", 
    "C:\Scripts\Nonna\db\other learning.txt"
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

# collect data and put in an email 
function Randomise {    
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
    $username = (Get-Content "C:\Scripts\Nonna\db\creds.txt")[0]
    $password = (Get-Content "C:\Scripts\Nonna\db\creds.txt")[1] | ConvertTo-SecureString -AsPlainText -Force
    $date = Get-Date
    $gym = Get-Content "C:\Scripts\Nonna\db\gym.txt"
    $meals = Get-Content "C:\Scripts\Nonna\db\meal-planner.txt"
    $miscLearning = Get-Content "C:\Scripts\Nonna\db\other learning.txt"

    $az104Notes = Randomise -db $az104[0..11]
    $mealPlanner = Randomise -db $meals
    $exercises = Randomise -db $gym

    $notes = Pull-Data-From-DB -data $az104Notes
    $mealplan = Pull-Data-From-DB -data $mealPlanner

    $notes = foreach($note in $notes){
        "<li>$note</li>"
    }

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

    $body = @"
    <h1>Nonna Alert: $date</h1>
    <p>Hi Lou, Here's your agenda for today. Remember that I am always watching over you. Have a great day!. Love Nonna</p>
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
        to = "louisruocco1@gmail.com"
        subject = "Nonna Alert: $date"
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