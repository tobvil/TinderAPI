function Invoke-TinderLiker {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $PhoneNumber,

        [Parameter()]
        [int]
        $Count = 100

    )
    $ErrorActionPreference = 'Stop'

    if (!($tinderToken)) {
    $tinderToken = Get-TinderToken -PhoneNumber $PhoneNumber 
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

        $recs = Invoke-RestMethod @params -Uri "https://api.gotinder.com/v2/recs/core"

        foreach ($rec in $recs.data.results) {

            $id = $rec.user._id
            $likeRequest = Invoke-RestMethod @params -Uri "https://api.gotinder.com/like/$id"

            if ($likeRequest.likes_remaining -eq 0) {
                $date = [datetimeoffset]::FromUnixTimeMilliseconds($likeRequest.rate_limited_until)
                Write-Error "You are ratelimited untill $($date.LocalDateTime)"
            }

            $i++

            [PSCustomObject]@{
                Name     = $rec.user.name
                Bio      = $rec.user.bio
                City     = $rec.user.city.name
                Job      = $rec.user.jobs[0].title.name
                School   = $rec.user.schools[0].name
                Distance = $rec.distance_mi
                Birthday = $rec.user.birth_date
                Photos   = $rec.user.photos.url
                Count    = $i
            }

            if ($i -eq $Count) {
                break
            }
        }
    } 
}