# load DT library
library(data.table)
# load data
DT_r<-fread("sample_data.csv")
DT<-copy(DT_r)

# create store_id
DT[,store_id:=1]
DT<-DT[,store_id:=lapply(.SD, cumsum), .(name), .SDcols='store_id']
DT_t<-DT[,.N,name]

# filter DT
cl<-c('country','state', 'city', 'zip', 'lat', 'lng', 'name', 'store_id', 'gid')
DT<-DT[city=='New York', cl, with=FALSE]

# convert lat/lng
DT[,':='(lat=lat*pi/180,lng=lng*pi/180)]

# cross join
DT_left<-copy(DT)
setnames(DT_left, paste0(names(DT),'_l', sep=''))
DT_right<-copy(DT)
setnames(DT_right, paste0(names(DT),'_r', sep=''))
DT_j<-setkey(DT_left[,c(k=1,.SD)],k)[DT_right[,c(k=1,.SD)],allow.cartesian=TRUE][,k:=NULL]
DT_j<-DT_j[gid_l!=gid_r]

# map dist function to DT
# Haversine formula
hf_dist <- function(long1, lat1, long2, lat2) {
  R <- 6371 # Earth mean radius [km]
  delta.long <- (long2 - long1)
  delta.lat <- (lat2 - lat1)
  a <- sin(delta.lat/2)^2 + cos(lat1) * cos(lat2) * sin(delta.long/2)^2
  c <- 2 * asin(min(1,sqrt(a)))
  d = R * c
  return(d*0.62137119) # Distance in mile
}
DT_j[,dist:=hf_dist(lng_l,lat_l,lng_r,lat_r)]
