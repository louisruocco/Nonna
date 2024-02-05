$db = (Get-Content "C:\Louis\Scripts\Nonna\utils\paths.txt")[0]

function Send-Email {
    $username = (Get-Content "C:\Louis\Scripts\Nonna\utils\secrets.txt")[0]
    $password = (Get-Content "C:\Louis\Scripts\Nonna\utils\secrets.txt")[1] | ConvertTo-SecureString -AsPlainText -Force
    $emailAddress = (Get-Content "C:\Louis\Scripts\Nonna\utils\secrets.txt")[2]
    $randomiser = Get-Content "$db\questions.txt"

    $randomise = $randomiser | Sort-Object{Get-Random}
    $questions = $randomise[0..11]
    $results = foreach($question in $questions){
        "<li>$question</li>"
    }

    $body = @"
    <h1>Nonna | AZ-700 Revision Questions</h1>
    <p>Hi Lou, here are some questions for you to revise and remember for your AZ-700 exam. Good luck and study hard!</p>
    <h3>Questions</h3>
    <ul>
        $results    
    </ul>
"@

    $email = @{
        from = $username
        to = $emailAddress
        subject = "Nonna | AZ-700 Revision Questions"
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
    <p>Hi Lou, looks like an error occurred on my side. I'll log the error in $db\Logs\randomiser_errorlog_$date.txt for you to review and fix. Sorry</p>
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