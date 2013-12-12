#dataset fernanda

setwd("C:\\Users\\xzizal\\Desktop\\GitHub\\geocoder\\R\\example_files\\Example_1_data_fernanda")

#all in one
SpeciesGeoCoder("input_point_coordinates.txt","input_polygon_points.txt")

#step by step
test <- ReadPoints("input_point_coordinates.txt","input_polygon_points.txt")
test2 <- SpGeoCod("input_point_coordinates.txt","input_polygon_points.txt")
test2 <- CoExClass(test2)

#Gentianales klein
setwd("C:\\Users\\xzizal\\Desktop\\GitHub\\geocoder\\R\\example_files\\Example_2_gentianales_klein")

#all in one
SpeciesGeoCoder("speciesindataset_R.txt","realmpoly_R.txt")

#step by step
test <- ReadPoints("speciesindataset_R.txt","realmpoly_R.txt")
test2 <- SpGeoCod("speciesindataset_R.txt","realmpoly_R.txt")
test2 <- CoExClass(test2)

#Gentianales gross
setwd("C:\\Users\\xzizal\\Desktop\\GitHub\\geocoder\\R\\example_files\\Example_3_gentianales_large")

SpeciesGeoCoderlarge("allgentianales4_R.txt","realmpoly_R.txt")
SpeciesGeoCoder("allgentianales4_R.txt","realmpoly_R.txt")


test <- ReadPoints("allgentianales4_R.txt","realmpoly_R.txt")
test2 <- SpGeoCod("allgentianales4_R.txt","realmpoly_R.txt")
test2 <- CoExClass(test2)

WriteTablesSpGeo(test2) #write result into tab-delimited .txt files, as tables

OutPlotSpPoly(test2) #no cutoff; barchart on species numbers per polygon#

OutBarChartPoly(test2) # cutoff = 45 polygons per species (layout); cutoff should maybe be calculated for each polygon seperately!; barchart of species abundance per polygon

OutBarChartSpec(test2) # cutoff = 45 species in the polygon (layout); cutoff should maybe be calculated for each species seperately; barchart of species distribution on different polygons

OutMapAll(test2) # no cutoff, maps all samples and all polygons for overview

OutMapPerSpecies(test2) #cutoff = 370 species ?? polygons (filesize), maps polygons per species

OutMapPerPoly(test2) #cutoff = 55 species in the polygon, maps species per polygon 

OutHeatCoEx(test2)

MapPerPoly <- function(x, plotout = FALSE){
  if (!class(x) ==  "spgeoOUT"){
    stop("This function is only defined for class spgeoOUT")
  }
  for(i in 1:length(names(x$polygons))){
    cat(paste("Creating map for polygon", i,"/",length(names(x$polygons)), ": ", names(x$polygons)[i], "\n",sep = ""))
    chopo <- names(x$polygons)[i]
    xmax <- min(max(bbox(x$polygons[i])[1, 2]) + 5,180)
    xmin <- max(min(bbox(x$polygons[i])[1, 1]) - 5, -180)
    ymax <- min(max(bbox(x$polygons[i])[2, 2]) + 5, 90)
    ymin <- max(min(bbox(x$polygons[i])[2, 1]) - 5,-90)
    
    
    po <- data.frame(x$sample_table, x$species_coordinates_in)
    subpo <- subset(po, po$homepolygon ==  chopo)
    
    subpo <- subpo[order(subpo$identifier), ]  
    colorh <- unique(subpo$identifier)
    lcolorh <- length(colorh)
    rain <- rainbow(lcolorh)
    cat("1")
    for(j in 1:length(subpo$identifier)){
      subpo$color[j] <- which(colorh ==  subpo$identifier[j])
      cat(paste("Setting color for sample", j, "/", length(subpo$identifier), "\n",sep = ""))
    }
    
    ypos <- vector(length = lcolorh)
    yled <- (ymax - ymin) * 0.025
    cat("2")
    for(k in 1:lcolorh){
      ypos[k]<- ymax - yled * k
    }
    
    layout(matrix(c(1, 1, 1, 2, 2), ncol =  5, nrow = 1))
    par(mar = c(3, 3, 3, 0))
    cat("creating map")
    map("world", xlim = c(xmin, xmax), ylim = c(ymin, ymax))
    axis(1)
    axis(2)
    box("plot")
    title(chopo)
    cat("adding polygons")
    plot(x$polygons[i], col = "grey60", add = T)
    
    liste <- unique(subpo$identifier)
    leng <- length(liste)
    for(j in 1:leng){
      subsub <- subset(subpo,subo$identifier == liste[j]) 
      points(subsub[,3]), subsub[,4], 
      cex = 0.7, pch = 3 , col = rain[subpo$color])
cat(paste("plotting species", j, "/", leng,"\n", sep = ""))
    }
#points(subpo[,3], subpo[,4], 
#       cex = 0.7, pch = 3 , col = rain[subpo$color])
#legend
par(mar = c(3, 0, 3, 0), ask = F)
plot(c(1, 50), c(1, 50), type = "n", axes = F)
if(lcolorh == 0){
  yset <- 25
  xset <- 1}
if (lcolorh ==  1){
  yset <- 25
  xset <- rep(4, lcolorh)
}
if(lcolorh >  1){
  yset <- rev(sort(c(seq(25, 25 + max(ceiling(lcolorh/2) - 1, 0)), 
                     seq(24, 24 - lcolorh/2 + 1))))
  xset <- rep(4, lcolorh)
}
points(xset-2, yset, pch =  3, col = rain)
if(lcolorh == 0){
  text(xset, yset, labels = "No species found in this polygon", adj = 0)
}else{
  text(xset, yset, labels =  colorh, adj = 0, xpd = T)
  rect(min(xset) - 4, min(yset) -1, 50 + 1, max(yset) + 1, xpd = T)
}

if (plotout ==  FALSE){par(ask = T)}
  }
par(ask = F)
}
