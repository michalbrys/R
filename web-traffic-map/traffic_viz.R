# Load dependencies

#install.packages('jsonlite')
#install.packages('urltools')
#install.packages("leaflet")
#devtools::install_github("hrbrmstr/ipapi")
#install.packages("maptools")

library(urltools)
library(ipapi)
library(leaflet)
library(jsonlite)
library(sp)
library(maptools)

#file <- 'www.book.lot.com.json'
file <- 'www.cheeserank.com.json'

getwd()

# Import JSON / HAR file
out <- fromJSON(file, simplifyDataFrame = T)
headers <- out$log$entries$request$headers
headers_df <- do.call(rbind, lapply(headers, data.frame, stringsAsFactors=FALSE))

# Prepare hosts list
hosts <- unique(subset(headers_df, name=="Host"))
hosts$value

# Get hosts locations
locations <- geolocate(hosts$value)

# Draw first map

m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
m  # Print the map

# Draw points on map
m <- leaflet() %>% 
        addTiles() %>% 
        addCircleMarkers(locations$lon, locations$lat, 
        color = '#ff0000', popup=hosts$value)
m

# Draw points on map - dark theme 1
m <- leaflet() %>%
  setView( 21.012, 52.2297, zoom = 2) %>%
  addTiles('http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', 
           attribution='Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>') %>% 
  addCircles(locations$lon, locations$lat, popup=hosts$value, weight = 3, radius = 40, color="#ffa500", stroke = TRUE, fillOpacity = 0.8) 
m

# Prepare lines
coord1 <- data.frame(id = 1:nrow(locations), group = locations$as, lon = locations$lon, lat = locations$lat)
coord2 <- data.frame(id = 1:nrow(locations), group = locations$as, lon = 21.0122, lat = 52.2297)
coord <- rbind(coord1, coord2)

# Approach 1 - connected lines
m <- leaflet() %>% 
  addTiles('http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', 
           attribution='Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>') %>% 
  addCircles(locations$lon, locations$lat, popup=hosts$value, weight = 3, radius = 40, color="#ffa500", stroke = TRUE, fillOpacity = 0.8) %>% 
  addPolylines(data = coord, lng = ~lon, lat = ~lat, group = ~group,
               color="#ffa500")
m


##### Alternative

points_to_line <- function(data, long, lat, id_field = NULL, sort_field = NULL) {
  
  # Convert to SpatialPointsDataFrame
  coordinates(data) <- c(long, lat)
  
  # If there is a sort field...
  if (!is.null(sort_field)) {
    if (!is.null(id_field)) {
      data <- data[order(data[[id_field]], data[[sort_field]]), ]
    } else {
      data <- data[order(data[[sort_field]]), ]
    }
  }
  
  # If there is only one path...
  if (is.null(id_field)) {
    
    lines <- SpatialLines(list(Lines(list(Line(data)), "id")))
    
    return(lines)
    
    # Now, if we have multiple lines...
  } else if (!is.null(id_field)) {  
    
    # Split into a list by ID field
    paths <- sp::split(data, data[[id_field]])
    
    sp_lines <- SpatialLines(list(Lines(list(Line(paths[[1]])), "line1")))
    
    # I like for loops, what can I say...
    for (p in 2:length(paths)) {
      id <- paste0("line", as.character(p))
      l <- SpatialLines(list(Lines(list(Line(paths[[p]])), id)))
      sp_lines <- spRbind(sp_lines, l)
    }
    
    return(sp_lines)
  }
}

y <- points_to_line(coord, "lon", "lat", "id")  

# Basic map
m <- leaflet() %>% addTiles() %>% addPolylines(data = y)
m

# dark theme
m <- leaflet() %>% 
  addTiles('http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', 
           attribution='Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>') %>% 
  addCircles(locations$lon, locations$lat, popup=hosts$value, weight = 3, radius = 40, color="#ffa500", stroke = TRUE, fillOpacity = 0.8) %>% 
  addPolylines(data = y, weight = 2,
               color="#ffa500")
m

# Light theme

m <- leaflet() %>% 
  addProviderTiles("CartoDB.Positron") %>%
  addCircles(locations$lon, locations$lat, popup=hosts$value, weight = 5, radius = 50, color="#0a74ff", stroke = TRUE, fillOpacity = 0.9) %>% 
  addPolylines(data = y, weight = 3,
               color="#f94d4d")
m

