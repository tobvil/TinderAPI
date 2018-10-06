<#
.Synopsis
   Get-TinderLiker.ps1 - Used for indisciminately liking every user in an endless loop
.DESCRIPTION
   Function for liking everyone on tinder
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
        
        $RecommendationRequest = Invoke-RestMethod -Method Post -Uri "https://api.gotinder.com/user/recs" -Headers $Headers -ContentType application/json 

        $Results = $RecommendationRequest.results

        foreach ($R in $Results)
        {
    
            $Id = $R._id
        
            $PhotoURL = $R.photos.Url[0]

            $Name = $R.name
    
            $LikeRequest = Invoke-RestMethod -Method Get -Uri "https://api.gotinder.com/like/$ID" -Headers $Headers -ContentType applictaion/json
            Write-Output "Liking $Name `n$PhotoURL"

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