function Invoke-BlondeOrNot {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string]
        $Key,

        [Parameter(Mandatory)]
        [string]
        $Endpoint,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Photo,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Id

    )

    Process {

        $ErrorActionPreference = 'Stop'

        $predictionParams = @{
            Uri         = $Endpoint
            Method      = 'post'
            ContentType = 'application/json'
            Headers     = @{
                'Prediction-Key' = $Key
            }
            Body        = @{
                url = $Photo
            } | ConvertTo-Json
        }
        
        $prediction = Invoke-RestMethod @predictionParams

        [PSCustomObject]@{
            Probability = $prediction.predictions[0].probability
            Tag         = $prediction.predictions[0].tagName
            Name        = $Name
            Photo       = $Photo
            Id          = $id
        }
    }
}