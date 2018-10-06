function Get-TinderSMSToken
{
    $RequestSend = Invoke-WebRequest -Uri "https://api.gotinder.com/v2/auth/sms/send?auth_type=sms&locale=en" -Method "POST" -ContentType "application/json" -Body "{`"phone_number`":`"$PhoneNumber`"}"
    $SMSCode = Read-Host "Enter SMS Code"
    $RequestValidate = Invoke-WebRequest -Uri "https://api.gotinder.com/v2/auth/sms/validate?auth_type=sms&locale=en" -Method "POST" -ContentType "application/json" -Body "{`"otp_code`":`"$SMSCode`",`"phone_number`":`"$PhoneNumber`"}"
    $RequestValidate = $RequestValidate | Convertfrom-Json
    $RefreshToken = $RequestValidate.data.refresh_token
    $RequestToken = Invoke-WebRequest -Uri "https://api.gotinder.com/v2/auth/login/sms?locale=en" -Method "POST" -ContentType "application/json" -Body "{`"refresh_token`":`"$RefreshToken`",`"phone_number`":`"$PhoneNumber`"}"
    $RequestToken = $RequestToken | ConvertFrom-Json
    $Script:TinderToken = $RequestToken.data.api_token
}

function Get-HotOrNot
{
    [cmdletbinding()]
    Param
    ( 
        [Parameter(Mandatory = $true)]
        [string]
        $ImageURL
    )

    $Headers = @{"Prediction-Key" = "$PredictionKey"}
    $Body = @{"Url" = "$ImageURL"} | ConvertTo-Json
    $Request = Invoke-RestMethod -Method Post -Uri "$CustomVisionURL" -Headers $Headers -Body $Body -ContentType application/json
    $HotPrediction = $Request.predictions | Where tagName -EQ 'Hot'
    if ($HotPrediction.probability -gt 0.5)
    {
        $Script:Hot = $True
    }
    else
    {
        $Script:Hot = $False
    }
}
function Invoke-TinderCustomVisionAPI
{
    Get-TinderSMSToken
    $Headers = @{"X-Auth-Token" = "$TinderToken"}
    while ($True)
    {
        $RecommendationRequest = Invoke-RestMethod -Method Post -Uri "https://api.gotinder.com/user/recs" -Headers $Headers -ContentType application/json 
        $Results = $RecommendationRequest.results
        foreach ($R in $Results)
        {
            $Id = $R._id
            $ImageURL = $R.photos.Url[0]
            $Name = $R.name
            Get-HotOrNot -ImageURL $ImageURL
            $i++
            Write-Output "Loop Count $i"
            if ($Hot -eq $true)
            {
                $LikeRequest = Invoke-RestMethod -Method Get -Uri "https://api.gotinder.com/like/$ID" -Headers $Headers -ContentType applictaion/json
                if ($LikeRequest.match -eq 'True')
                {
                    Write-Output "Yaaay you matched with $Name `n$ImageURL"
                }
                else
                {
                    Write-Output "Liking $Name `n$ImageURL"
                }
            }
            elseif ($Hot -eq $false)
            {
                $PassRequest = Invoke-RestMethod -Method Get -Uri "https://api.gotinder.com/pass/$ID" -Headers $Headers -ContentType application/json
                Write-Output "Passing on $Name `n$PhotoURL"
        
            }
        }
    }
}
$ConfigJson = Get-Content .\Config.Json | ConvertFrom-Json
$PhoneNumber = $ConfigJson.PhoneNumber
$PredictionKey = $ConfigJson.'CustomVisionPrediction-Key'
$CustomVisionURL = $ConfigJson.CustomVisionURL
Invoke-TinderCustomVisionAPI