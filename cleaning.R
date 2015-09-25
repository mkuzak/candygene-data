library(ggmap)
library(dplyr)
library(countrycode)

get_elevation <- function(lat, long) {
  # GET("https://maps.googleapis.com/maps/api/elevation", path="maps/api/elevation/json", query = list(locations="lat,long"))

  url <- "https://maps.googleapis.com/"
  api_path <- "maps/api/elevation/json"
  locs = paste(lat, long, sep = ",")
  response = GET(url, path=api_path, query=list(locations=locs))
  return(content(response)$results[[1]]$elevation)
}

correct_gps <- function(lat, lon) {
  # if lat lon NA change to Nan
  if (any(is.na(c(lat, lon)))) {
    loc <- c(lat=lat, lon=lon)
    return(loc)
  }
  # check if they are within the range
  if ((lat < -90) | (lat > 90)) {
    lat <- lat / 10
  }
  if ((lon < -180) | (lon > 180)) {
    lon <- lon / 10
  }

  loc <- c(lat=lat, lon=lon)
  return(loc)
}

validate_gps <- function(lat, lon, iso3c){
  # iso3c is a country name in iso3 character format
  # if any of the coordinates or the country is NA, cannot validate
  if (any(is.na(c(lat, lon, iso3c)))) {
    return(FALSE)
  }
  
  # convert gps coordinates to address
  full_address <- ""
  tryCatch({
    full_address <- revgeocode(c(lon, lat))
    }, warning = function(w) {
      print(w)
      return(FALSE)
    }, error = function(e) {
      print(e)
      return(FALSE)
    }, finally = {
      if (full_address == "") {
        return(FALSE)
      }
    }
  )
  
  address_split <- str_split(full_address, ", ")[[1]]
  if (length(address_split) == 1) {
    country <- address_split
  } else {
    country <- address_split[length(address_split)]
  }
  print(country)
  # check if revgeo country matches provided one
  if (countrycode(country, "country.name", "iso3c") == iso3c) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

potato_df <- dplyr::tbl_df(read.csv("pp_accession2.csv", sep=";", na.strings = "NULL", stringsAsFactors = FALSE))

# correct gps coordinates
potato_df2 <- potato_df %>%
  rowwise() %>%
  mutate(gps.lat = correct_gps(GPS, GPS.2)['lat'],
         gps.lon = correct_gps(GPS, GPS.2)['lon'])

# validate gps coordinates
potato_df2%<>%
  rowwise() %>%
  mutate(gps.validated = validate_gps(gps.lat, gps.lon, COUNTRY))

# get elevation for validated coordinates if elevation is no provided
get_elevation_helper <- function(validated, lat, lon) {
  if (validated) {
    return(get_elevation(lat, lon))
  } else {
    return(NA)
  }
}

potato_df2%<>%
  rowwise() %>%
  mutate(gps.elevation = get_elevation_helper(gps.validated, gps.lat, gps.lon))

