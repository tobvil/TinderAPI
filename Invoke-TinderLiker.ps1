function Get-TinderToken
{
    $RequestSend = Invoke-RestMethod -Uri "https://api.gotinder.com/v2/auth/sms/send?auth_type=sms&locale=en" -Method "POST" -ContentType "application/json" -Body "{`"phone_number`":`"$PhoneNumber`"}"
    $SMSCode = Read-Host "Enter SMS Code"
    $RequestValidate = Invoke-RestMethod -Uri "https://api.gotinder.com/v2/auth/sms/validate?auth_type=sms&locale=en" -Method "POST" -ContentType "application/json" -Body "{`"otp_code`":`"$SMSCode`",`"phone_number`":`"$PhoneNumber`"}"
    $RefreshToken = $requestvalidate.data.refresh_token
    $RequestToken = Invoke-RestMethod -Uri "https://api.gotinder.com/v2/auth/login/sms?locale=en" -Method "POST" -ContentType "application/json" -Body "{`"refresh_token`":`"$RefreshToken`",`"phone_number`":`"$PhoneNumber`"}"
    $Script:TinderToken = $requesttoken.data.api_token
}
function Invoke-TinderLiker
{
    Get-TinderToken
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
            $i++
            Write-Output "Like Count $i`n"
        }
    }
}
$PhoneNumber = Read-Host "Enter country code + phone number e.g. 4588888888"
Invoke-TinderLiker