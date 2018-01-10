# get old data
db <- dbConnect(odbc::odbc(),
                driver='SQL Server',
                server='ifw9mbmsvr008',
                database='SeabirdCatalog')

# call the observation, returning the geometry field as x and y columns.
risamp = dbGetQuery(db,"select * from observation where dataset_id = 90")
risamp_geom = dbGetQuery(db,"select observation_id,[Geometry].STY as Lat, [Geometry].STX as Long from observation where dataset_id = 90")
risamp_t = dbGetQuery(db,"select * from transect where dataset_id = 90")
#risamp_geom_t = dbGetQuery(db,"select transect_id,[Geometry].STY as Lat, [Geometry].STX as Long from transect where dataset_id = 90")

risamp = left_join(risamp, risamp_geom, by="observation_id")
rm(risamp_geom)
risamp = dplyr::select(risamp,-Geometry)

# risamp_t = left_join(risamp_t, risamp_geom_t, by="transect_id")
# rm(risamp_geom_t)
risamp_t = dplyr::select(risamp_t,-Geometry)

# identify column with coordinates
coordinates(risamp) <- ~ Long + Lat

# set the projection, assume WGS84
proj4string(risamp) <- CRS("+init=epsg:4326")

# turn back to dataframe
risamp = as.data.frame(risamp)

# export
risamp$flight_height_tx = paste(as.character(risamp$flight_height_tx)," ",sep="")
write.csv(risamp,"Z:/seabird_database/data_sent/AG_RISAMP_Jan2018/RISAMP_boat_observations_from_seabird_catalog.csv")

