function Get-TinderSMSToken
{
    $RequestSend = Invoke-RestMethod -Uri "https://api.gotinder.com/v2/auth/sms/send?auth_type=sms&locale=en" -Method "POST" -ContentType "application/json" -Body "{`"phone_number`":`"$PhoneNumber`"}"
    $SMSCode = Read-Host "Enter SMS Code"
    $RequestValidate = Invoke-RestMethod -Uri "https://api.gotinder.com/v2/auth/sms/validate?auth_type=sms&locale=en" -Method "POST" -ContentType "application/json" -Body "{`"otp_code`":`"$SMSCode`",`"phone_number`":`"$PhoneNumber`"}"
    $RefreshToken = $requestvalidate.data.refresh_token
    $RequestToken = Invoke-RestMethod -Uri "https://api.gotinder.com/v2/auth/login/sms?locale=en" -Method "POST" -ContentType "application/json" -Body "{`"refresh_token`":`"$RefreshToken`",`"phone_number`":`"$PhoneNumber`"}"
    $Script:TinderToken = $requesttoken.data.api_token
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
    $HotPrediction = $Request.predictions | Where-Object tagName -EQ 'Hot'
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
        try
        {
            $RecommendationRequest = Invoke-RestMethod -Method Post -Uri "https://api.gotinder.com/user/recs" -Headers $Headers -ContentType application/json
            $Results = $RecommendationRequest.results
        }
        catch
        {
            Write-Error "Couldn't find new recommendations" -ErrorAction Stop
        }
        foreach ($R in $Results)
        {
            $Id = $R._id
            $ImageURL = $R.photos.Url | Select-Object -First 1
            $Name = $R.name
            Get-HotOrNot -ImageURL $ImageURL
            $i++
            Write-Output "Loop Count $i"
            if ($Hot -eq $true)
            {
                do
                {
                    try
                    {
                        $LikeRequest = Invoke-RestMethod -Method Get -Uri "https://api.gotinder.com/like/$ID" -Headers $Headers -ContentType applictaion/json
                    }
                    catch
                    {
                        Write-Error "$_ - Trying again :)"
                    }
                } while (-not $LikeRequest)
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
                do
                {
                    try
                    {
                        $PassRequest = Invoke-RestMethod -Method Get -Uri "https://api.gotinder.com/pass/$ID" -Headers $Headers -ContentType applictaion/json
                    }
                    catch
                    {
                        Write-Error "$_ - Trying again :)"
                    }
                } while (-not $PassRequest)
                Write-Output "Passing on $Name `n$ImageURL"
            }
        }
    }
}
$ConfigJson = Get-Content .\Config.Json | ConvertFrom-Json
$PhoneNumber = $ConfigJson.PhoneNumber
$PredictionKey = $ConfigJson.'CustomVisionPrediction-Key'
$CustomVisionURL = $ConfigJson.CustomVisionURL
Invoke-TinderCustomVisionAPI