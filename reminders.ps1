function Send-Reminder {
    $username = (Get-Content "E:\Code\Nonna\db\creds.txt")[0]
    $password = (Get-Content "E:\Code\Nonna\db\creds.txt")[1] | ConvertTo-SecureString -AsPlainText -Force
    
    $body = @"
    <h1>Nonna</h1>
    <p>Hi Lou, This is a reminder to update your meal plan, weekly project and weekly learning topic. You can find the file locations below:</p>
    <ul>
        <li><b>Meal Plan<b> | E:\Code\Nonna\db\meal-planner.txt</li>
        <li><b>Weekly Learning Topic<b> | E:\Code\Nonna\db\other learning.txt</li>
    </ul>
"@

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


Send-Reminder