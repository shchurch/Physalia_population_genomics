
hdf <- handed_df %>% filter(cluster == cluster_of_interest) %>% 
  group_by(ID,simulation) %>% nest() %>% group_by(ID) %>% slice_sample(n=n_trajectories) %>% 
  unnest(cols = c(data)) %>% ungroup() 
udf <- unhanded_df %>% filter(cluster == cluster_of_interest) %>% 
  group_by(ID,simulation) %>% nest() %>% group_by(ID) %>% slice_sample(n=n_trajectories) %>% 
  unnest(cols = c(data)) %>% ungroup()

h_missing <- handed_df %>% filter(longitude > 9e30 | latitude > 9e30) %>% distinct(file_id,simulation)
hdf <- hdf %>% filter(longitude < 9e30, latitude < 9e30)

u_missing <- unhanded_df %>% filter(longitude > 9e30 | latitude > 9e30) %>% distinct(file_id,simulation)
udf <- udf %>% filter(longitude < 9e30, latitude < 9e30)

filter_trajectory_distance <- function(traj_df,distance_threshold_km){
  # Filter based on distance traveled threshold
  distance_threshold <- distance_threshold_km * 1000

  # Calculate the distance between the first and last timepoint for each ID and simulation
  first_last_points <- traj_df %>%
    group_by(ID, simulation) %>%
    filter(timepoint == min(timepoint) | timepoint == max(timepoint)) %>%
    ungroup() %>% arrange(timepoint) %>%
    mutate(point_type = ifelse(timepoint == min(timepoint), "start", "end"))

  # Spread the data to have start and end points in the same row
  first_last_points_wide <- first_last_points %>% 
    select(file_id,simulation,ID,latitude,longitude,point_type) %>% 
    pivot_wider(names_from = point_type, values_from = c(longitude, latitude))

  # Calculate the distance between the start and end points
  first_last_points_wide <- first_last_points_wide %>%
    mutate(distance = distHaversine(cbind(longitude_start, latitude_start), cbind(longitude_end, latitude_end)))

  # Select relevant columns
  too_short <- first_last_points_wide %>%
    filter(distance < (distance_threshold)) %>%
    select(file_id, simulation)

  return(too_short)
}

h_too_short <- filter_trajectory_distance(hdf,distance_threshold_km)
hdf <- hdf %>% anti_join(h_too_short,by=c("file_id","simulation"))

u_too_short <- filter_trajectory_distance(udf,distance_threshold_km)
udf <- udf %>% anti_join(u_too_short,by=c("file_id","simulation"))

# combine data frames
cdf <- bind_rows(hdf,udf)

# Choose one representative specimen per collection event
ssi <- sample_info %>% filter(ID %in% cdf$ID) %>% 
  mutate(lat = as.numeric(lat), lon = as.numeric(long)) %>% 
  mutate(lat = round(lat,0), lon = round(lon,0)) %>% group_by(lat,lon,date_collected) %>% slice_sample(n = 1)

cdf <- cdf %>% filter(ID %in% ssi$ID)
