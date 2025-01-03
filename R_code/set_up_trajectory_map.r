world <- ne_countries(scale = "medium", returnclass = "sf") %>% st_set_crs(4326)
robinson = paste("+proj=robin +lon_0=",LeftBound," +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",sep="")
world2 = world %>% st_break_antimeridian(lon_0 = LeftBound) %>% st_transform(crs = robinson)

transpoint = st_as_sf(as.data.frame(cdf),coords=c("longitude","latitude"),crs=4326)
dtran = st_transform(transpoint,robinson)

coords <- st_coordinates(dtran$geometry)
trans_cdf <- cdf %>% mutate(long = as.numeric(coords[, "X"]),
                          lat = as.numeric(coords[, "Y"]))


si <- sample_info %>% filter(cluster == cluster_of_interest)
transsample = st_as_sf(as.data.frame(si),coords=c("long","lat"),crs=4326)
stran = st_transform(transsample,robinson)
scoords <- st_coordinates(stran$geometry)
trans_si <- si %>% mutate(long = as.numeric(scoords[, "X"]),
                          lat = as.numeric(scoords[, "Y"]))


g2 <- ggplot() + 
  geom_sf(data = world2, fill = "#edeaea", colour = NA) + 
  coord_sf(xlim = xlims, ylim = ylims) +
  scale_alpha_continuous(range = c(1, 0.001)) + 
  xlab("") + ylab("") + theme(legend.position = "none") +
  rasterise(
    geom_path(data = trans_cdf, 
               aes(x = long, y = lat, color = timepoint, alpha = timepoint, group = interaction(file_id,simulation)), 
               linejoin = "round", lineend = "butt", linewidth = 0.1),
    dpi = 300, dev = "ragg") +
  scale_color_gradient(high = "white", low = "dodgerblue2") +
  ggnewscale::new_scale_color() +
  geom_point(data = trans_si,
             aes(x = long, y = lat, shape = location, color = ocean), size = 2.25, stroke = 1, fill = "white") + 
  scale_shape_manual(values = shapes) +
  scale_color_manual(values = colors)

png(paste0("../figures/panels/",cluster_of_interest,"_",months_max,"_trajectories.png"),width=2500,height=1250,res=600)
print(g2)
dev.off()
