function Get-TinderToken
{
    $PhoneNumber = $ConfigJson.PhoneNumber
    Invoke-RestMethod -Uri "https://api.gotinder.com/v2/auth/sms/send?auth_type=sms&locale=en" -Method "POST" -ContentType "application/json" -Body "{`"phone_number`":`"$PhoneNumber`"}"
    $SMSCode = Read-Host "Enter SMS Code"
    $RequestValidate = Invoke-RestMethod -Uri "https://api.gotinder.com/v2/auth/sms/validate?auth_type=sms&locale=en" -Method "POST" -ContentType "application/json" -Body "{`"otp_code`":`"$SMSCode`",`"phone_number`":`"$PhoneNumber`"}"
    $RefreshToken = $requestvalidate.data.refresh_token
    $RequestToken = Invoke-RestMethod -Uri "https://api.gotinder.com/v2/auth/login/sms?locale=en" -Method "POST" -ContentType "application/json" -Body "{`"refresh_token`":`"$RefreshToken`",`"phone_number`":`"$PhoneNumber`"}"
    $Script:TinderToken = $requesttoken.data.api_token
}
function Invoke-TinderTextGame
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet("CockyFunny", "Intellectual", "Lame", "Cheesy", "Aggressive")]
        $PigStyle = 'Cheesy',

        [Parameter()]
        [int]$Count = '1'

    )
    Get-TinderToken
    $Headers = @{"X-Auth-Token" = "$TinderToken"}
    $Matches = Invoke-RestMethod -Method Get -Uri "https://api.gotinder.com/v2/matches?count=$Count" -Headers $Headers -ContentType 'applictaion/json' -Body $Body
    $Matches = $matches.data.matches
    $opener = switch ($PigStyle)
    {
        Aggressive {$ConfigJson.Agressive}
        Cheesy {$ConfigJson.Cheesy}
        Lame {$ConfigJson.Lame}
        Intellectual {$ConfigJson.Intellectual}
        CockyFunny {$ConfigJson.'Cocky Funny'}
    }
    $body = @{
        'message' = "$opener"
    } | ConvertTo-Json
    $body = [System.Text.Encoding]::UTF8.GetBytes($body)
    foreach ($Match in $Matches)
    {
        $MatchId = $Match._id
        $SendMessage = Invoke-RestMethod -Uri "https://api.gotinder.com/user/matches/$MatchId" -Method "POST" -Headers $Headers -Body $body -ContentType 'application/json; charset=utf-8' -SkipHeaderValidation
    }
}
$ConfigJson = Get-Content .\config.json -Encoding utf8 | ConvertFrom-Json
Invoke-TinderTextGame -PigStyle Aggressive -Count 1