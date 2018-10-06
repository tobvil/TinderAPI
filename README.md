# TinderAPI
Powershell functions used to communicate with Tinder API.

Note: Not yet working with Facebook authentication.

# TinderCustomVisionAPI
Build a classifier and use Azure Cognitive Services AI to automatically like or pass users, based on how you train your model.

1. Download config.json and Invoke-TinderCustomVisionAPI, and place them in the same directory.

2. Follow MS guidance on how to buld your classifier: 
   https://docs.microsoft.com/en-us/azure/cognitive-services/custom-vision-service/getting-started-build-a-classifier

3. Upload 5 images of ugly girls and tag the images "Not", and upload 5 images of hot girls and tag them "Hot"

4. Input your PhoneNumber you use with Tinder in config.json file.

5. Input Prediction-Key and Image URL in config.json file. 
   https://docs.microsoft.com/en-us/azure/cognitive-services/custom-vision-service/use-prediction-api

6. From Powershell simply run .\Invoke-TinderCustomVisonAPI.ps1 - You'll be prompted to enter the code you recieved on your phone from tinder.

7. After a couple of minutes, end the script by pressing "CTRL + C" and go back to https://customvision.ai under predictions and tag the new images to make the predictions more precise. 