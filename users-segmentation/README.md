# Users segmentation
Website users segmentation using Google Analytics and R (k-means algorithm).

## How to start?
Clone this repository and run `users-segmentation.R` in RStudio.
This file contains complete example.

## Getting data from Google Analytics API to RStudio
Basic example is based on sample dataset downloaded from GitHub.

If you want to make analysis on your Google Analytics data:
* Download data via `ga-connection.R` file
* Remember to configure your connection
  * Get credentials on https://goo.gl/2CGLsc
  * Set Google Analytics table id in format: ga:00000000
    * *The unique table ID of the form ga:XXXX, where XXXX is the Analytics view (profile) ID for which the query will retrieve the data.*
