function Get-TinderMatches {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $PhoneNumber

    )

    $ErrorActionPreference = 'Stop'

    if (!($tinderToken)) {
        Get-TinderToken -PhoneNumber $PhoneNumber 
    }

    $params = @{
        Headers     = @{
            'X-Auth-Token' = $tinderToken
        }
        Method      = 'get'
        ContentType = 'application/json'
        Uri = 'https://api.gotinder.com/v2/matches?count=100'
    }

    while ($true) {

        $matches = Invoke-RestMethod @params

        $matches.data.matches

        if (!($matches.data.next_page_token)) {
            break
        }
        
        $params.Uri = 'https://api.gotinder.com/v2/matches?count=100&page_token=' + $matches.data.next_page_token
    }
}