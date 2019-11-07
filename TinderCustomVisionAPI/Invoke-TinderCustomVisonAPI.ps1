
function Get-HotOrNot
{
    $Headers = @{"Prediction-Key" = "$PredictionKey"}
    foreach ($Image in $ImageURL)
    {
        $Body = @{"Url" = "$Image"} | ConvertTo-Json
        $Request = Invoke-RestMethod -Method Post -Uri "$CustomVisionURL" -Headers $Headers -Body $Body -ContentType application/json
        $i++
        [PSObject[]]$HotPrediction += $Request.predictions | Where-Object tagName -EQ 'Hot'
        $HotPrediction | Add-Member -NotePropertyName 'ImageURL' -NotePropertyValue $Image -ErrorAction SilentlyContinue
    }
    $script:ImageAverage = $HotPrediction.probability | Measure-Object -Average -Maximum
    $script:BestImage = $HotPrediction | Where-Object probability -EQ $ImageAverage.Maximum | Select-Object -ExpandProperty ImageURL
    if ($ImageAverage.Average -gt 0.5)
    {
        $Script:Hot = $True
    }
    else
    {
        $Script:Hot = $False
    }
}
function Invoke-TinderCustomVisionAPI
{
    Get-TinderToken
    $Headers = @{"X-Auth-Token" = "$TinderToken"}
    while ($True)
    {
        try
        {
            $RecommendationRequest = Invoke-RestMethod -Method Post -Uri "https://api.gotinder.com/user/recs" -Headers $Headers -ContentType application/json
            $Results = $RecommendationRequest.results
        }
        catch
        {
            Write-Error "Couldn't find new recommendations" -ErrorAction Stop
        }
        foreach ($R in $Results)
        {
            $Id = $R._id
            $Script:ImageURL = $R.photos.Url
            $Name = $R.name
            Get-HotOrNot
            if ($Hot -eq $true)
            {
                do
                {
                    try
                    {
                        $LikeRequest = Invoke-RestMethod -Method Get -Uri "https://api.gotinder.com/like/$ID" -Headers $Headers -ContentType applictaion/json
                    }
                    catch
                    {
                        Write-Error "$_ - Trying again :)"
                    }
                } while (-not $LikeRequest)
                if ($LikeRequest.match -eq 'True')
                {
                    Write-Output "Yaaay you matched with $Name `n$BestImage`nScore: "$ImageAverage.Average""
                }
                else
                {
                    Write-Output "Liking $Name `n$BestImage`nScore: "$ImageAverage.Average""
                }
            }
            elseif ($Hot -eq $false)
            {
                do
                {
                    try
                    {
                        $PassRequest = Invoke-RestMethod -Method Get -Uri "https://api.gotinder.com/pass/$ID" -Headers $Headers -ContentType applictaion/json
                    }
                    catch
                    {
                        Write-Error "$_ - Trying again :)"
                    }
                } while (-not $PassRequest)
                Write-Output "Passing on $Name `n$BestImage`nScore: "$ImageAverage.Average""
            }
            $i++
            Write-Output "Loop Count $i`n"
        }
    }
}
$ConfigJson = Get-Content .\Config.Json | ConvertFrom-Json
$PhoneNumber = $ConfigJson.PhoneNumber
$PredictionKey = $ConfigJson.'CustomVisionPrediction-Key'
$CustomVisionURL = $ConfigJson.CustomVisionURL
Invoke-TinderCustomVisionAPI