<#
.Synopsis
   Get-TinderToken-ps1 - Gets the personal token used to communicate with the Tinder API
.DESCRIPTION
   Function for fething the token used to access Tinder API
.EXAMPLE
   Get-TinderToken -PhoneNumber 4588888888

.NOTES
   Written by Tobias Vilhelmsen
#>
function Get-TinderToken
{

    [cmdletbinding()]
    Param
    (
        #Phone number used for Tinder Account. Put county code before number
        [Parameter(Mandatory = $true)]
        [string]
        $PhoneNumber
    )
        
    $RequestSend = Invoke-WebRequest -Uri "https://api.gotinder.com/v2/auth/sms/send?auth_type=sms&locale=en" -Method "POST" -ContentType "application/json" -Body "{`"phone_number`":`"$PhoneNumber`"}"

    $SMSCode = Read-Host "Enter SMS Code"

    $RequestValidate = Invoke-WebRequest -Uri "https://api.gotinder.com/v2/auth/sms/validate?auth_type=sms&locale=en" -Method "POST" -ContentType "application/json" -Body "{`"otp_code`":`"$SMSCode`",`"phone_number`":`"$PhoneNumber`"}"

    $RequestValidate = $RequestValidate | Convertfrom-Json

    $RefreshToken = $RequestValidate.data.refresh_token

    $RequestToken = Invoke-WebRequest -Uri "https://api.gotinder.com/v2/auth/login/sms?locale=en" -Method "POST" -ContentType "application/json" -Body "{`"refresh_token`":`"$RefreshToken`",`"phone_number`":`"$PhoneNumber`"}"

    $RequestToken = $RequestToken | ConvertFrom-Json

    $TinderToken = $RequestToken.data.api_token

    Return $TinderToken
}