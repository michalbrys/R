# Configure connection with Google Analtics API

# install.packages("RGoogleAnalytics")
library(RGoogleAnalytics)

# Get credentials on https://goo.gl/2CGLsc
client.id <- "xxxxxxxxxxxx.apps.googleusercontent.com"
client.secret <- "zzzzzzzzzzzz"

# Authorize access to Google Analytics data
token <- Auth(client.id,client.secret)
ValidateToken(token)

# Save the token object for future sessions
save(token,file="./token_file")

# Get the Unique Pageviews by User in Content Group
query.list <- Init(start.date = "2015-01-01",
                   end.date = "2015-01-31",
                   dimensions = "ga:dimension1,ga:contentGroup1",
                   metrics = "ga:contentGroupUniqueViews1",
                   table.id = "ga:00000000")

# Create the Query Builder object
ga.query <- QueryBuilder(query.list)

# Extract the data and store it in a data-frame
ga.data <- GetReportData(ga.query, token)