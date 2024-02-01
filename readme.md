# Nonna

A collection of Powershell scripts that act as PA, daily fitness schedule and study helper. An email is sent every morning with this information to help me get started and ready for the day ahead.

## Changelog:
### v1.21
#### New Feature | Study Randomiser
- Added the study randomiser back in to help me study for AZ-700
- This randomises questions in a new db and spits out the first 10 in the email body to help me with my active recall

### v1.2
#### New Feature | Learning Worker Script:
- The new "Learning" script will check for changes in the "other learning" txt file within 1 minute of it being pinged, if it detects any, it will ping the Youtube API with 5 new videos based on the updated value in that txt file"
    - **Script must be set to run every minute in Task Scheduler for this feature to work as intended**
#### Other Changes and Fixes in this Update:
- Changed the default body to send youtube video links every day of the week instead of just Monday
- Fixed issues with updating scripts on the backend

### v1.1
- Added some error logging/handling internally as there was none present, making fixing errors difficult
- More to come in this version update shortly! 

### v1.0
- Current Features:
    - Randomised, user-defined gym and fitness schedule
    - Randomised, user-defined daily meal plan
    - A study helper
        - The Youtube API is queried with whatever is defined in the "other learning.txt" file 
        - 5 videos are then returned, with their titles and links to go and watch them if they are of interest
    - A reminder script sent every Sunday to remind me to update the meal plan and other learning 


## Upcoming Features:
- News and Sport Web Scraper
- Randomise list of other learning topics, pick one and return 5 videos from the Youtube API based on that topic
    - Split up the learning topics into broader topics, then scrape certain websites based on that broader topic
    - e.g.
        -  A SQL topic would scrape the learn SQL page and Brent Ozar's Blogs for links and additional learning material on the sub topic