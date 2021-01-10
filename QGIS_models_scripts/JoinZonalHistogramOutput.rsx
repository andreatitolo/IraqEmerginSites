##IraqEmergingSites=group
##InputPolygons=multiple vector
##JoinedPolygons= output vector
##load_vector_using_rgdal

library(dplyr)
library(janitor)
library(magrittr)

SpatialPolygons = InputPolygons[[1]]

df_list = lapply( InputPolygons , function(x) `@`(x , "data") )
binded_pct = bind_cols(adorn_percentages(df_list))
binded_pct = select(binded_pct,-contains(c("fid", "NODAT", "site_name")))
binded_pct = mutate_if(binded_pct, is.numeric, ~.*100)
sites_pct = bind_cols(select(df_list[[1]], "site_name"),binded_pct)
sites_pct = adorn_rounding(sites_pct,digits = 0)
sites_pct = mutate_if(sites_pct,is.numeric, as.integer)
sites_pct = set_colnames(sites_pct,gsub("X", "", colnames(sites_pct)))
SpatialPolygons@data = sites_pct
JoinedPolygons = SpatialPolygons