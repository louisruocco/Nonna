$url = Invoke-WebRequest 'https://www.brentozar.com/archive/category/development/t-sql/'
$res = $url.ParsedHtml.getElementsByTagName('div') |Where-Object { $_.className -eq 'w-grid-list' }
$links = $res | ForEach-Object { $_.getElementsByTagName('a') }
$random = $links.href -replace '#comments', '' -replace 'https://www.brentozar.com/archive/author/brento/', '' -replace 'https://www.brentozar.com/archive/category/videos/', '' -replace 'https://www.brentozar.com/archive/category/development/t-sql/', '' | Select-Object -Unique

$db = (Get-Content ".\utils\paths.txt")[0]
$logs = (Get-Content ".\utils\paths.txt")[1]

$path = "$db\Brent Ozar Blog Links.txt"
Function DB-Check {
    if(!(test-path $path)){
        New-Item $path
    }
}

function Check-Link {
    param (
        [string]$link, 
        [string]$links
    )
    $check = Select-String -Path $path -Pattern $link
    if($check -ne $links[0]){
        Add-Content -Path $path -Value $link
    }
}
function Randomise {
    $links = $random | Sort-Object {Get-Random}
    $link = $links[0]
    Check-Link -link $link -links $Links
}

try {
    Randomise
    DB-Check
}
catch {
    Get-Date -Format "ddMMyyyy"
    write-host $Error | Out-File -FilePath "$logs\errorlog_$date.txt"
}