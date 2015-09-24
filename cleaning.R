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

validate.gps <- function(lat, lon, iso3c) {
  # check if they are within the range
  if ((lat < -90) | (lat > 90)) {
    lat <- lat / 10
  }
  if ((lon < -180) | (long > 180)) {
    lon <- lon / 10
  }
  # check if location within provided country
  print(lat)
  print(lon)
  address <- revgeocode(c(lon, lat))
  print(address)
  country.name <- str_split(address, ", ")[[1]][length(str_split(address, ", ")[[1]])]
  if (countrycode(country.name, "country.name", "iso3c") != iso3c) {
    loc <- c(lat=NA, lon=NA)
  } else {
    loc <- c(lat=lat, lon=lon)
  }
  return(loc)
}
# check if GPS (lat) is in range -90 to 90
# check if GPS.2 (lon) is in range -180 to 180
# if it's outside, divide by 10



# check if the location is within the country in COUNTRY field


as.numeric(str_sub(gps1, 1, -2))

potato_df2 <- potato_df %>%
  rowwise() %>%
  mutate(div = floor(abs(GPS*100 / as.numeric(str_sub(GPS.1, 1, -2)))))


potato_df <- dplyr::tbl_df(read.csv("pp_accession2.csv", sep=";", na.strings = "NULL", stringsAsFactors = FALSE))

vars <- c("Genbank", "Genbank.ID", "Species.code", "Species", "gps.lat", "gps.lon", "Place", "Province", "Country",
         "Description", "Date.of.collection", "Elevation", "Ploidy")

# correct gps coordinates

# add column 'location.source', for cases where no lat long information
# do geocode to get coordinates based on the address Place + 

place = if (is.na(potato_df[2, ]$Place)) "" else potato_df[2, ]$Place
province = if (is.na(potato_df[2, ]$Province)) "" else potato_df[2, ]$Province
country = if (is.na(potato_df[2, ]$COUNTRY) )"" else potato_df[2, ]$COUNTRY
address = paste(place, province, country, sep=", ")

geocode(address, source="google")

library(httr)
GET("https://maps.googleapis.com/maps/api/elevation/json?locations=-15.9166,-68.6333")

validate.gps(-4.000, -79.250, "ECU")
validate.gps(-140.666, -73.250, "PER")
validate.gps(189.166, -997.166, "MEX")