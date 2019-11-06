function Invoke-TinderLiker {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $PhoneNumber
    )

    $tinderToken = Get-TinderToken -PhoneNumber $PhoneNumber 
    
    $params = @{
        Headers     = @{
            'X-Auth-Token' = $tinderToken
        }
        Method      = 'post'
        ContentType = 'application/json'
    }

    $recs = Invoke-RestMethod @params -Uri "https://api.gotinder.com/user/recs"

    foreach ($result in $recs.results) {
        $id = $result._id
        $LikeRequest = Invoke-RestMethod @params -Uri "https://api.gotinder.com/like/$id"
        Write-Output "Liking $($result.name) $($result.photos[0].url)"
    }  
}