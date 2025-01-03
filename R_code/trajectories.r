months_max <- 9

source("set_up_trajectories.r")

cluster_of_interest <- "B1"
LeftBound = 79
xlims <- c(-11596597,16899112)
ylims <- c(-4730816,4886408)

cluster_of_interest <- "A"
LeftBound = -40 
xlims <- c(-5531246,4988384)
ylims <- c(1152559,6026207)

cluster_of_interest <- "C1"
LeftBound = 150 
xlims <- c(-10718930,12576348)
ylims <- c(-7235085,0)

cluster_of_interest <- "C2"
LeftBound = 150 
xlims <- c(-2718930,3576348)
ylims <- c(-5235085,-2300000)

n_trajectories <- 500
distance_threshold_km <- 500

set.seed(12345)
source("filter_combine_trajectories.r")

source("set_up_trajectory_map.r")

# YEAR BOUNDARIES
cluster_of_interest <- "B1"
LeftBound = 100
xlims <- c(-12596597,16899112)
ylims <- c(-4730816,4286408)

cluster_of_interest <- "A"
LeftBound = -40 
xlims <- c(-5531246,5988384)
ylims <- c(52559,6026207)

cluster_of_interest <- "C2"
LeftBound = 150 
xlims <- c(-5018930,3076348)
ylims <- c(-5235085,-2300000)
