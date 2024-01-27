$db = (Get-Content "C:\Louis\Scripts\Nonna\utils\paths.txt")[0]
$utils = (Get-Content "C:\Louis\Scripts\Nonna\utils\paths.txt")[2]

function Search-Learning {
    $apiKey = (Get-Content "$utils\secrets.txt")[3]
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

    Send-Email
}

function Send-Email {
    $username = (Get-Content "$utils\secrets.txt")[0]
    $password = (Get-Content "$utils\secrets.txt")[1] | ConvertTo-SecureString -AsPlainText -Force
    $emailAddress = (Get-Content "$utils\secrets.txt")[2]
    $learning = Get-Content "$db\other learning.txt"
    $learningLinks = foreach ($item in $learning){
        "<li>$item</li>"
    }
    $body = @"
    <h1>Nonna | Learning Resources for $learning</h1>
    <p>Hi Lou. I have noticed you have updated the learning db with a new topic. Here are some resources I think you would find useful</p>
    <h2>Learning Topic: $Learning</h2>
    <ul>
        $learningLinks
    </ul>
"@

    $email = @{
        from = $username
        to = $emailAddress
        subject = "Nonna | New Learning Resources based on: $learning"
        smtpserver = "smtp.gmail.com"
        body = $body
        port = 587
        credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
        usessl = $true
        verbose = $true
    }

    Send-MailMessage @email -BodyAsHtml
}

$getFileWriteTime = (Get-ChildItem '$db\other learning.txt').LastWriteTime

$fileDateHour = $getFileWriteTime.Hour
$fileDateMinute = $getFileWriteTime.Minute
$currentDate = Get-Date -Format "yyyyMMddHHmm"
$fileDate = $getFileWriteTime.ToString("yyyyMMddHHmm")
$currentDate2 = $currentDate -1

if(($fileDate -lt $currentDate) -or ($fileDate -lt $currentDate2)){
    write-output "email not sent"
} else {
    Search-Learning
}
