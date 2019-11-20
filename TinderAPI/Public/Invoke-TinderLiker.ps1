function Invoke-TinderLiker {
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Id,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Photo

    )

    Begin {

        $params = @{
            Headers     = @{
                'X-Auth-Token' = $tinderToken
            }
            Method      = 'get'
            ContentType = 'application/json'
        }

    }

    Process {

        $likeRequest = Invoke-RestMethod @params -Uri "https://api.gotinder.com/like/$id"

        if ($likeRequest.likes_remaining -eq 0) {
            $date = [datetimeoffset]::FromUnixTimeMilliseconds($likeRequest.rate_limited_until)
            Write-Error "You are ratelimited untill $($date.LocalDateTime)"
        }

        [PSCustomObject]@{
            Name  = $Name
            Photo = $Photo
            Id    = $Id
        }

    }
    End {
    }
}