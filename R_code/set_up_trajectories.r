library(ncdf4)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrastr)

theme_set(theme_classic())

library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(geosphere)

sample_info <- read.delim("../data/sample_ids.tsv",header=T,stringsAsFactors=F) %>%
  mutate(year = gsub(".*/(.*)","\\1",date_collected), month = as.numeric(gsub("(.*)/.*/.*","\\1",date_collected))) %>% 
  separate(lat_long,into=c("lat","long"),sep=", ") %>%
  filter(status != "excluded")
assignments <- read.delim("../data/subset.txt",header=F,sep=" ")
names(assignments) <- c("ID","cluster")
sample_info <- left_join(sample_info,assignments,by="ID")

colors <- c("#E78AC3","#00008B","#800000","#DAA520","#006400","#DAA520","#DC143C","#FC8D62","#452a00","#686f80","#66C2A5","#B3B3B3")
names(colors) <- c("Central Pacific","E Indian","Gulf of California","Gulf of Mexico","NE Atlantic","NW Atlantic","NW Pacific","SE Pacific","SW Atlantic","SW Pacific","W Indian")

shapes <- c(15,16,17,25,22,23,8,3,
            10,23,8,4,15,3,16,17,25,22,
            7,12,10,
            10,5)
names(shapes) <- c("Texas","Florida","Bermuda","Northeast US","Azores","Canary Islands","Spain","Ireland",
  "Central Pacific","Hawai'i","NW Hawaiian Islands","Guam","Japan","Queensland","New South Wales","Western Australia","South Africa","Uruguay",
  "Chile","Tasmania","Tasman Sea",
  "Mexico","New Zealand")


ocean_levels <- c("Gulf of Mexico","NW Atlantic","NE Atlantic","SW Atlantic","W Indian","E Indian","SW Pacific","NW Pacific","Central Pacific","Gulf of California","SE Pacific")
sample_info$ocean <- factor(sample_info$ocean,levels=ocean_levels)

read_trajectory <- function(filename,months_max) {
  # Open NetCDF file
  nc <- nc_open(filename)
 
  # Read longitude and latitude
  lon <- ncvar_get(nc, "lon")
  lat <- ncvar_get(nc, "lat")
 
  # Close the file
  nc_close(nc)
 
  # Create data frame
  timepoints <- rep(1:nrow(lon), ncol(lon))
  simulations <- rep(1:ncol(lon), each = nrow(lon))
  lon <- as.vector(lon)
  lat <- as.vector(lat)

  df <- data.frame(timepoint = timepoints, simulation = simulations, latitude = lat, longitude = lon) %>% filter(timepoint < (366 * (months_max / 12)))

  # Return data
  return(df)
}

# List all filenames in the directory
filenames <- list.files(path = "../results/trajectories/VarDriftExpHanded", pattern = "*.nc", full.names = TRUE)

# Extract the first couple of characters (numbers preceding the letter 's')
file_ids <- sub("^(\\d+)s.*", "\\1", basename(filenames))

# Loop over filenames to create a list of dataframes
dataframes_list <- lapply(filenames, read_trajectory, months_max = months_max)
names(dataframes_list) <- file_ids

file_id_location <- read.delim("../results/trajectories/file_ids.tsv",header=T,sep="\t") %>% mutate(across(everything(), as.character))
si <- left_join(file_id_location,sample_info,by="ID")

# get trajctories for specimens with handedness data
handed_df <- bind_rows(dataframes_list, .id = "file_id") %>% left_join(.,si,by="file_id")

# get trajectories for other specimens
filenames <- list.files(path = "../results/trajectories/VarDriftExp2hands", pattern = "*.nc", full.names = TRUE)
dataframes_list <- lapply(filenames, read_trajectory, months_max = months_max)
file_ids <- sub("^(\\d+)s.*", "\\1", basename(filenames))
names(dataframes_list) <- file_ids

hand_ids <- sub(".*_(.*).nc", "\\1", basename(filenames))
left_dataframes <- dataframes_list[which(hand_ids == "left")] %>% lapply(.,function(x){x %>% filter(simulation <= 500)}) %>% bind_rows(., .id = "file_id") 
right_dataframes <- dataframes_list[which(hand_ids == "right")] %>% lapply(.,function(x){x %>% filter(simulation > 500)}) %>% bind_rows(., .id = "file_id") 

unhanded_df <- bind_rows(left_dataframes,right_dataframes) %>% left_join(.,si,by="file_id")
