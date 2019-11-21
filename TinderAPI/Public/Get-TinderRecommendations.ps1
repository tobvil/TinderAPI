function Get-TinderRecommendations {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $PhoneNumber,

        [Parameter()]
        [int]
        $Count = 10

    )

    $ErrorActionPreference = 'Stop'

    if (!($tinderToken)) {
        if (!($PhoneNumber)) {
            $PhoneNumber = Read-Host 'Enter phone number for authentication'
            
            Get-TinderToken -PhoneNumber $PhoneNumber 
        }
        Get-TinderToken -PhoneNumber $PhoneNumber 
    }

    $params = @{
        Headers     = @{
            'X-Auth-Token' = $tinderToken
        }
        Method      = 'get'
        ContentType = 'application/json'
    }

    $i = 0

    while ($true) {
        if ($i -eq $count) {
            break
        }

        $recs = Invoke-RestMethod @params -Uri 'https://api.gotinder.com/v2/recs/core'

        foreach ($rec in $recs.data.results) {

            $id = $rec.user._id

            $i++

            [PSCustomObject]@{
                Name     = $rec.user.name
                Bio      = $rec.user.bio
                City     = $rec.user.city.name
                Job      = $rec.user.jobs[0].title.name
                School   = $rec.user.schools[0].name
                Distance = $rec.distance_mi
                Birthday = $rec.user.birth_date
                Photo    = $rec.user.photos.url | Select-Object -First 1
                Id       = $id
            }

            if ($i -eq $Count) {
                break
            }
        }
    }
}