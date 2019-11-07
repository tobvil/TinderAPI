function Get-BlondeOrNot
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $PhoneNumber,

        [Parameter(Mandatory)]
        [string]
        $Key = 'e8fc31351f5541c98e5f7f66584fb329',

        [Parameter(Mandatory)]
        [string]
        $ProjectId = '44351a63-7587-4c0e-815f-8e3039cbe99f',

        [Parameter(Mandatory)]
        [string]
        $ProjectName = 'BlondeOrNot'



    )

    $tinderToken = Get-TinderToken -PhoneNumber $PhoneNumber 

    $params = @{
        Headers     = @{
            'X-Auth-Token' = $tinderToken
        }
        Method      = 'get'
        ContentType = 'application/json'
    }

    $recs = Invoke-RestMethod @params -Uri "https://api.gotinder.com/v2/recs/core"

    foreach ($rec in $recs.data.results) {
        foreach ($photo in $rec.user.photos.url) {

            $predictionParams = @{
                Uri = "https://westeurope.api.cognitive.microsoft.com/customvision/v3.0/Prediction/$ProjectId/classify/iterations/$ProjectName/url"
                Method = 'post'
                ContentType = 'application/json'
                Headers = @{
                    'Prediction-Key' = $Key
                }
                Body = @{
                    url = $photo
                } | ConvertTo-Json
            }
        
            Invoke-RestMethod @predictionParams
        }
    }
}
Get-BlondeOrNot -PhoneNumber 4560878450