# Nonna

A collection of Powershell scripts that act as PA, daily fitness schedule and study helper. An email is sent every morning with this information to help me get started and ready for the day ahead.

## Changelog:
### v1.1 | The error-handling version update!
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