function Invoke-TinderMassLiker {
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

    while (!($i -eq $count)) {

        $recs = Invoke-RestMethod @params -Uri 'https://api.gotinder.com/v2/recs/core'

        foreach ($rec in $recs.data.results) {

            $likeRequest = Invoke-RestMethod @params -Uri "https://api.gotinder.com/like/$($rec.user._id)"

            if ($likeRequest.likes_remaining -eq 0) {
                $date = [datetimeoffset]::FromUnixTimeMilliseconds($likeRequest.rate_limited_until)
                Write-Error "You are ratelimited untill $($date.LocalDateTime)"
            }

            $i++

            $percentComplete = ($i / $count) * 100
            Write-Progress -Activity "Liking $($rec.user.name)" -Status "Liked $i of $count : $percentComplete%" -PercentComplete $percentComplete

            [PSCustomObject]@{
                Name     = $rec.user.name
                Bio      = $rec.user.bio
                City     = $rec.user.city.name
                Job      = $rec.user.jobs[0].title.name
                School   = $rec.user.schools[0].name
                Distance = $rec.distance_mi
                Birthday = $rec.user.birth_date
                Photo    = $rec.user.photos.url | Select-Object -First 1
                Count    = $i
            }

            if ($i -eq $Count) {
                break
            }
        }
    }
}