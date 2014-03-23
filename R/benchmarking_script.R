source("speciesgeocodeR.R")

repli  <- 1

benchmGraphsOff <- function(x,y,z){
  nn <- data.frame(t(replicate(repli, system.time(SpeciesGeoCoder(x, y, graphs = F)))[3,]))
  rownames(nn)<- z
  write.table(nn, "bm_graph_off_nexus.txt", sep ="\t", append = T)
}

benchmGraphsON <- function(x,y,z){
  nn <- data.frame(t(replicate(repli, system.time(SpeciesGeoCoder(x, y, graphs = T)))[3,]))
  rownames(nn)<-  z
  write.table(nn, "bm_graph_on.txt", sep ="\t", append = T)
}

occnum <- c("datapoints10_R.txt","datapoints100_R.txt","datapoints1000_R.txt","datapoints10000_R.txt",
            "datapoints100000_R.txt","datapoints1000000_R.txt", "datapoints10000000_R.txt")
polnum <- c("polygons_R_10.txt", "polygons_R_100.txt", "polygons_R_1000.txt", "polygons_R_10000.txt")
edgenum <- c("polygonedges_R_4.txt", "polygonedges_R_40.txt", "polygonedges_R_400.txt", "polygonedges_R_4000.txt", "polygonedges_R_40000.txt")

#with graphics turned off
for(j in 1:length(polnum))
{
  for(i in 1: length(occnum))
    {
    benchmGraphsOff (occnum[i],
                     polnum[j], paste("occurences",occnum[i],"polygons",polnum[j], sep = "_"))
   }
}

for(j in 1:length(edgenum))
{
  for(i in 1: length(occnum))
  {
    benchmGraphsOff (occnum[i],
                     edgenum[j], paste("occurences",occnum[i],"edges",edgenum[j], sep = "_"))
  }
}
# 
# #with graphics turned on
# for(j in 1:length(polnum))
# {
#   for(i in 1: length(occnum))
#   {
#     benchmGraphsOn (paste("/usr/local/db/speciesgeocoder/preformancetests/", occnum[i],sep = ""),
#                     polnum[j], paste("occurences",occnum[i],"polygons",polnum[j], sep = "_"))
#   }
# }
# 
# for(j in 1:length(edgenum))
# {
#   for(i in 1: length(occnum))
#   {
#     benchmGraphsOn (paste("/usr/local/db/speciesgeocoder/preformancetests/", occnum[i],sep = ""),
#                     edgenum[j], paste("occurences",occnum[i],"polygons",polnum[j], sep = "_"))
#   }
