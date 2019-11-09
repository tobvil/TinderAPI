function Get-BlondeOrNot {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'phone')]
        [string]
        $PhoneNumber,

        [Parameter(Mandatory, ParameterSetName = 'token')]
        [string]
        $tinderToken,

        [Parameter(Mandatory)]
        [string]
        $Key,

        [Parameter(Mandatory)]
        [string]
        $Endpoint,

        [Parameter(Mandatory)]
        [int]
        $Count = 50

    )

    if ($PSCmdlet.ParameterSetName -eq 'phone') {
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

            $predictionParams = @{
                Uri         = $Endpoint
                Method      = 'post'
                ContentType = 'application/json'
                Headers     = @{
                    'Prediction-Key' = $Key
                }
                Body        = @{
                    url = $rec.user.photos[0].url
                } | ConvertTo-Json
            }
        
            $prediction = Invoke-RestMethod @predictionParams

            if ($prediction.predictions[0].tagName -eq 'blonde') {
                $id = $rec.user._id
                $like = Invoke-RestMethod @params -Uri "https://api.gotinder.com/like/$id"
                
            }

            $i++

            [PSCustomObject]@{
                Probability = $prediction.predictions[0].probability
                Tag         = $prediction.predictions[0].tagName
                Photo       = $rec.user.photos[0].url[0]
                Count       = $i
            }

            if ($i -eq $Count) {
                break
            }
        }
    }
}