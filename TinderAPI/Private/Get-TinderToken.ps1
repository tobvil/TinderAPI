function Get-TinderToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $PhoneNumber
    )
    $ErrorActionPreference = 'Stop'

    $sendParams = @{
        Uri         = 'https://api.gotinder.com/v2/auth/sms/send?auth_type=sms'
        Method      = 'post'
        ContentType = 'application/json'
        Body        = @{
            phone_number = $PhoneNumber
        } | ConvertTo-Json
    }

    $null = Invoke-RestMethod @sendParams

    $smsCode = Read-Host "Enter SMS Code"

    $validateParams = @{
        Uri         = 'https://api.gotinder.com/v2/auth/sms/validate?auth_type=sms'
        Method      = 'post'
        ContentType = 'application/json'
        Body        = @{
            otp_code     = $smsCode
            phone_number = $PhoneNumber
        } | ConvertTo-Json
    }

    $validate = Invoke-RestMethod @validateParams

    $loginParams = @{
        Uri         = 'https://api.gotinder.com/v2/auth/login/sms'
        Method      = 'post'
        ContentType = 'application/json'
        Body        = @{
            refresh_token = $validate.data.refresh_token
            phone_number  = $PhoneNumber
        } | ConvertTo-Json
    }

    $login = Invoke-RestMethod @loginParams

    $login.data.api_token
}