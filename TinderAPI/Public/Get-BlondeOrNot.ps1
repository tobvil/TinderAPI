function Get-BlondeOrNot
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $PhoneNumber,

        [Parameter(Mandatory)]
        [string]
        $Key,

        [Parameter(Mandatory)]
        [string]
        $Endpoint

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

            $predictionParams = @{
                Uri = $Endpoint
                Method = 'post'
                ContentType = 'application/json'
                Headers = @{
                    'Prediction-Key' = $Key
                }
                Body = @{
                    url = $rec.user.photos[0]
                } | ConvertTo-Json
            }
        
            $prediction = Invoke-RestMethod @predictionParams
    }
}
Get-BlondeOrNot -PhoneNumber 4560878450 -Endpoint 'https://blondeornot.cognitiveservices.azure.com/customvision/v3.0/Prediction/44351a63-7587-4c0e-815f-8e3039cbe99f/classify/iterations/Iteration1/url' -Key 'e8fc31351f5541c98e5f7f66584fb329'