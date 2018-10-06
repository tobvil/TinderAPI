<#
.Synopsis
   Get-TinderLiker.ps1 - Used for indisciminately liking every user in an endless loop
.DESCRIPTION
   Function for liking everyone on tinder. Get tinder token by using Get-TinderToken.ps1
.EXAMPLE
   Invoke-TinderLiker -TinderToken 123456-123416-123461-123412
.NOTES
   Written by Tobias Vilhelmsen
#>
function Invoke-TinderLiker
{

    [cmdletbinding()]
    Param
    (

        #Input tinder token you got from Get-TinderToken.ps1
        [Parameter()]
        $TinderToken
    )

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
            throw
        }

        foreach ($R in $Results)
        {
    
            $Id = $R._id
        
            $PhotoURL = $R.photos.Url[0]

            $Name = $R.name
    
            $LikeRequest = Invoke-RestMethod -Method Get -Uri "https://api.gotinder.com/like/$ID" -Headers $Headers -ContentType applictaion/json -ErrorAction SilentlyContinue
            
            $i++
            Write-Host “Like Count $i”

            if ($LikeRequest.match -eq 'True')
            {
                Write-Output "Yaaay you matched with $Name `n$PhotoURL"
            }
            else
            {
                Write-Output "Liking $Name `n$PhotoURL"
            }
        }
    }
}