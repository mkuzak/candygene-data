library(ggmap)
library(dplyr)
library(countrycode)
library(stringr)
library(httr)

DDMM2DD <- function(ddmm){
  pattern <- '[0-9]{4}[NS]'
  if (is.na(str_match(ddmm, pattern))){
    return(NaN)
  }
  degs <- as.integer(str_sub(ddmm, 1,2))
  mins <- as.integer(str_sub(ddmm, 3,4))
  direction <- str_sub(ddmm, 5,5)
  dd <- degs + mins / 60
  if (direction == "S") {
    dd <- - dd
  }
  return(dd)
}


DDDMM2DD <- function(dddmm){
  pattern <- '[0-9]{5}[EW]'
  if (is.na(str_match(dddmm, pattern))){
    return(NaN)
  }
  degs <- as.integer(str_sub(dddmm, 1,3))
  mins <- as.integer(str_sub(dddmm, 4,5))
  direction <- str_sub(dddmm, 6,6)
  dd <- degs + mins / 60
  if (direction == "W") {
    dd <- - dd
  }
  return(dd)
}

get_elevation <- function(lat, lon) {
  if (any(is.na(c(lat, lon)))){
    return(NaN)
  }
  print(c(lat, lon))
  # GET("https://maps.googleapis.com/maps/api/elevation", path="maps/api/elevation/json", query = list(locations="lat,long"))
  url <- "https://maps.googleapis.com/"
  api_path <- "maps/api/elevation/json"
  locs = paste(lat, lon, sep = ",")
  
  # google elevation API has limit of 10 requests per second
  while (TRUE) {
    response = GET(url, path=api_path, query=list(locations=locs))
    status <- content(response)$status
    print(status)
    if (status == "OK"){
      break
    } else {
     Sys.sleep(1) 
    }
  }
  elevation <- as.numeric(content(response)$results[[1]]$elevation)
  print(elevation)
  return(elevation)
}

potato_df <- dplyr::tbl_df(read.csv("pp_accession2.csv", sep=";", na.strings = "NULL", stringsAsFactors = FALSE))

# correct gps coordinates
potato_df%<>%
  rowwise() %>%
  mutate(gps.lat = DDMM2DD(GPS.1), gps.lon = DDDMM2DD(GPS.3))

# fetch elevation with google api
potato_df %<>%
  rowwise() %>%
  mutate(gps.elevation = get_elevation(gps.lat, gps.lon))
