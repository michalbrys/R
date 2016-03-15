# Load data into R
# You can download data from Google Analytics API or download sample dataset
# source('ga-connection.R')

# Download and preview sample dataset
download.file(url="https://raw.githubusercontent.com/michalbrys/R/master/users-segmentation/sample-users.csv","sample-users.csv", method="curl")
ga.data <- read.csv(file="sample-users.csv", header=T, row.names = 1)
head(ga.data)

# K-Means Cluster Analysis

# Clustering users in 3 groups
fit <- kmeans(ga.data, 3)

# Get cluster means 
aggregate(ga.data,by=list(fit$cluster),FUN=mean)

# Append  and preview cluster assignment
clustered_users <- data.frame(ga.data, fit$cluster)
head(clustered_users)

# Visualize results in 3D chart

#install.packages("plotly")
library(plotly)

plot_ly(df, x = clustered_users$beginner_pv, y = clustered_users$intermediate_pv, z = clustered_users$advanced_pv, type = "scatter3d", mode = "markers", color=factor(clustered_users$fit.cluster))

# Write results to file
write.csv(clustered_users, "clustered-users.csv", row.names=T)
