# dependencies
install.packages("maptools")
install.packages("maps")
install.packages("mapdata")
install.packages("raster")

library(maptools)
library(maps)
library(mapdata)
library(raster)

data(wrld_simpl)

#produces spatialPolygons from text files, or from table, 3 columns: species, lat, long
Cord2Polygon <- function(x){ 
  if (is.character(x)){
    tt <- read.table(x, sep = "\t")
    if (dim(tt)[2] !=  3){
      stop(paste("Wrong input format: \n", 
                 "Inputobject must be a tab-delimited text file or a data.frame with three columns", 
                 sep  = ""))
    }
    if (!is.numeric(tt[, 2]) || !is.numeric(tt[, 3])){
      stop(paste("Wrong input format: \n", 
                 "Input coordinates (columns 2 and 3) must be numeric.", 
                 sep = ""))
    }
    if (!is.character(tt[, 1]) && !is.factor(tt[, 1])){
      warning("Input identifier (column 1) should be a string or a factor.")
    }  
    names(tt) <- c("identifier", "lon", "lat")
    liste <- levels(tt$identifier)
    col <- list()
    for (i in 1:length(liste)){
      pp <- subset(tt, tt$identifier == liste[i])[, c(2, 3)]
      pp <- Polygon(pp)
      po <- Polygons(list(pp), ID = liste[i])
      col[[i]] <- po
    }
    polys <- SpatialPolygons(col, proj4string = CRS("+proj=longlat +datum=WGS84"))
  }else{
    tt <- x
    if (dim(tt)[2] !=  3){
      stop(paste("Wrong input format: \n", 
                 "Inputobject must be a tab-delimited text file or a data.frame with three columns", 
                 sep  = ""))
    }
    if (!is.numeric(tt[, 2]) || !is.numeric(tt[, 3])){
      stop(paste("Wrong input format: \n", 
                 "Input coordinates (columns 2 and 3) must be numeric.", 
                 sep = ""))
    }
    if (!is.character(tt[, 1]) && !is.factor(tt[, 1])){
      warning("Input identifier (column 1) should be a string or a factor.")
    }  
    names(tt) <- c("identifier", "lon", "lat")
    liste <- levels(tt$identifier)
    col <- list()
    for(i in 1:length(liste)){
      pp <- subset(tt, tt$identifier == liste[i])[, c(2, 3)]
      pp <- Polygon(pp)
      po <- Polygons(list(pp), ID = liste[i])
      col[[i]] <- po
    } 
    polys <- SpatialPolygons(col, proj4string = CRS("+proj=longlat +datum=WGS84"))
  }
  return(polys)
}

#reads in txt files from files name, tab delimited, 3 columns each, x = pointcoordinates, y polygon coordinates, add corrections for bad input files here.
ReadPoints<- function(x, y) {   
  res <- list()
  coords <- read.table(x, sep = "\t", header = T)
  polycord <- read.table(y, sep = "\t")
  if (dim(coords)[2] !=  3){
    stop(paste("Wrong input format: \n", 
               "Inputfile for coordinates must be a tab-delimited text file with three columns", sep  = ""))
  }
  if (!is.numeric(coords[, 2]) || !is.numeric(coords[, 3])){
    stop(paste("Wrong input format: \n", 
               "Input point coordinates (columns 2 and 3) must be numeric.", sep  = ""))
  }
  if (!is.character(coords[, 1]) && !is.factor(coords[, 1])){
    warning("Coordinate identifier (column 1) should be a string or a factor.")
  } 
  if (dim(polycord)[2] !=  3){
    stop(paste("Wrong input format: \n", 
               "Inputfile for polygons must be a tab-delimited text file with three columns", sep  = ""))
  }
  if (!is.numeric(polycord[, 2]) || !is.numeric(polycord[, 3])){
    stop(paste("Wrong input format: \n", 
               "Input polygon coordinates (columns 2 and 3) must be numeric.", sep  = ""))
  }
  if (!is.character(polycord[, 1]) && !is.factor(polycord[, 1])){
    warning("Polygon identifier (column 1) should be a string or a factor.")
  } 
  poly <- Cord2Polygon(polycord)
  res <- list(identifier = coords[, 1], species_coordinates = as.matrix(coords[, c(2, 3)]), 
              polygons = poly)
  class(res) <- "spgeoIN"
  return(res)
}

PipSamp <- function(x){
  if (class(x) != "spgeoIN"){
    stop(paste ("Function is only defined for class spgeoIN.\n", 
                "Use ReadPoints() to produce correct input format.", sep = ""))
  }
  liste <- levels(x$identifier)
  occ <- SpatialPoints(x$species_coordinates[, c(1, 2)])
  pp <- x$polygons#[i]
  proj4string(occ) <- proj4string(pp) <- "+proj=longlat +datum=WGS84"
  pip <- over(occ, pp)
  pip <- data.frame(x$identifier, pip)
  colnames(pip) <- c("identifier", "homepolygon")
  for(i in 1:length(names(x$polygons))){
    pip$homepolygon[pip$homepolygon ==  i] <- names(x$polygons)[i] 
  }
  pip$homepolygon <- as.factor(pip$homepolygon)
  class(pip) <- c("spgeodataframe", "data.frame")
  return(pip)
}

PointInPolygon <- function(x, y){
  if (dim(x)[2] !=  3){
    stop(paste("Wrong input format: \n", 
               "Inputfile for coordinates must be a data.frame with three columns", sep  = ""))
  }
  if (!is.numeric(x[, 2]) || !is.numeric(x[, 3])){
    stop(paste("Wrong input format: \n", 
               "Input point coordinates (columns 2 and 3) must be numeric.", sep  = ""))
  }
  if (!is.character(x[, 1]) && !is.factor(x[, 1])){
    warning("Coordinate identifier (column 1) should be a string or a factor.")
  }
  occ <- SpatialPoints(x[, c(2, 3)])
  poly <- Cord2Polygon(y)
  proj4string(occ) <- proj4string(poly) <- "+proj=longlat +datum=WGS84"
  pip <- over(occ, poly)
  pip <- data.frame(identifier = x[, 1], homepolygon = pip)
  for(i in 1:length(names(poly))){
    pip$homepolygon[pip$homepolygon ==  i] <- names(poly)[i] 
  }
  return(pip)
}

SpSumH <- function(x){
  if (class(x)[1] == "spgeodataframe"){
    liste <- levels(x$homepolygon)
    spec_sum <- data.frame(identifier = levels(x$identifier))
    for(i in 1:length(liste)){
      pp <- subset(x, x$homepolygon ==  liste[i])
      kk <- aggregate(pp$homepolygon, by = list(pp$identifier), length)
      names(kk) <- c("identifier", liste[i])
      spec_sum <- merge(spec_sum, kk, all = T)
    }
    spec_sum[is.na(spec_sum)] <- 0
    return(spec_sum)
  }else{
    stop("This function is only defined for class spgeodataframe")
  }
}

SpSum <- function(x){
  samp <- PipSamp(x)
  SpSumH(samp)
}

SpPerPolH <- function(x){
  numpoly <- length(names(x)[-1])
  pp <- x[, -1]
  pp[pp > 0] <- 1
  if (numpoly > 1){
    num_sp_poly <- colSums(pp)
  }else{
    num_sp_poly <- sum(pp)
    names(num_sp_poly) <- names(x)[2]
  }
  return(num_sp_poly)
}

SpPerPol <- function(x){
  kkk <- PipSamp(x)
  jjj <- SpSumH(kkk)
  iii <- SpPerPolH(jjj)
  return(iii)
}

CoExClassH <- function(x){
  dat <- x
  if (!is.data.frame(x)){
    stop("Function only defined for class data.frame.")
  }
  if ("identifier" %in% names(dat) ==  F){
    if (T %in% sapply(dat, is.factor)){
      id <- sapply(dat, is.factor)
      old <- names(dat)[id == T]
      names(dat)[id == T] <- "identifier"
      warning(paste("No species identifier found in input object. \n", "Column <", old, "> was used as identifier", sep = ""))
    }
    if (T %in% sapply(dat, is.character)){
      id <- sapply(dat, character)
      old <- names(dat)[id == T]
      names(dat)[id == T] <- "identifier"
      warning(paste("No species identifier found in input object. \n", "Column <", old, "> was used as identifier", sep = ""))
    }
  }
  spnum <- length(dat$identifier)
  numpol <- length(names(dat))
  coemat <- data.frame(matrix(NA, nrow = spnum, ncol = spnum))
  for(j in 1:spnum){
    sco <- data.frame(dat$identifier)
    for(i in 2:length(names(dat))){
      if (dat[j, i] ==  0) {
        poly<- rep(0, spnum)
        sco <- cbind(sco, poly)
      }
      if (dat[j, i] > 0){
        scoh <- dat[, i]
        if (numpol > 2){
          totocc <- rowSums(dat[j, -1])  
        }else{
          totocc <- dat[j, -1]
        }
        for(k in 1 : length(scoh))
          if (scoh[k] > 0){
            scoh[k] <- dat[j, i]/totocc *100
          }else{
            scoh[k] <- 0
          }
        sco <- cbind(sco, scoh)
      }
    }
    if (numpol >2){
      coex <- rowSums(sco[, -1])
      coemat[j, ] <- coex
    }else{
      coex <- sco[, -1]
      coemat[j, ] <- coex 
    }
  }
  coemat<- cbind(dat$identifier, coemat)
  names(coemat) <- c("identifier", as.character(dat$identifier))
  return(coemat)
}

CoExClass <- function(x){
  if (class(x) ==  "spgeoOUT"){
    pp <- CoExClassH(x$spec_table)
    x$coexistence_classified <- pp
    return(x)}
  else{
    stop("Function is only defined for class SpgeoOUT. \n  See CoExClassH() for single data.frames.")
  }
}

SpGeoCodH <- function(x){
  if (class(x) ==  "spgeoIN"){
    kkk <- PipSamp(x)
    spsum <- SpSumH(kkk)
    sppol <- SpPerPolH(spsum)
    
    nc <- subset(kkk, is.na(kkk$homepolygon))
    identifier <- x$identifier[as.numeric(rownames(nc))]
    bb <- x$species_coordinates[as.numeric(rownames(nc)), ]
    miss <- data.frame(identifier, bb)
    coex <- CoExClassH(spsum) 
    
    out <- list(identifier_in = x$identifier, species_coordinates_in = x$species_coordinates, polygons = x$polygons, 
                sample_table = kkk, spec_table = spsum, polygon_table = sppol, 
                not_classified_samples = miss, coexistence_classified = coex)
    class(out) <- "spgeoOUT"
    return(out)    
  }else{
    stop("Function is only defined for class spgeoIN")  
  }
}

SpGeoCod <- function(x, y){
  ini <- ReadPoints(x, y)
  outo <- SpGeoCodH(ini)
  return(outo)
}

#format(YCOORD, XCOORD)
CropPointCountry <- function(x, y){
  if (length(dim(x)) ==  0 || dim(x)[2] != 3){
    stop(paste("Wrong input format:\n", 
               "Point input object must be 3 columns.\n", 
               "<identifier>, <XCOORD>, <YCOORD>"))
  }
  if (is.numeric(x[, 2]) ==  F || is.numeric(x[, 3]) ==  F){
    stop(paste("Wrong input format:\n", 
               "corrdinates must be numberic", 
               "column order must be: <identifier>, <XCOORD>, <YCOORD>"))
  }
  mes <- length(y)
  if ("USA" %in% y){y[which(y ==  "USA")] <- "United States"}   
  if (mes ==  1){
    if (!y %in% wrld_simpl$NAME){
      stop(paste(y, "not found in country database, check spelling."))
    }else{
      subpoly <- subset(wrld_simpl, wrld_simpl$NAME ==  y)
      psubpoly <- SpatialPolygons(slot(subpoly, "polygons"))
      subpoints <- SpatialPoints(data.frame(x[, 2], x[, 3]))
      testp <- over(subpoints, psubpoly)
      ppp <- subpoints[is.na(testp) ==  F ]
      return(ppp)
    }
  }
  if (mes > 1){
    points <- data.frame()
    for(i in 1: mes){
      if (!y[i] %in% wrld_simpl$NAME){
        warning(paste(y[i], "not found in country database, check spelling."))
      }else{
        subpoly <- subset(wrld_simpl, wrld_simpl$NAME ==  y[i])
        psubpoly <- SpatialPolygons(slot(subpoly, "polygons"))
        subpoints <- SpatialPoints(data.frame(x[, 2], x[, 3]))
        testp <- over(subpoints, psubpoly)
        ppp <- subpoints[is.na(testp) ==  F ]
        points <- rbind(points, data.frame(ppp))
      }
    }
    return(points)
  }
}

#Add point ID here
CropPointPolygon <- function(points, polygon, outside = F){
  testid<- points
  if(is.character(points[,1]) || is.factor(points[,1])){
    id <- testid[, 1]
    points <- testid[, -1]
  }
  points <- SpatialPoints(points)
  proj4string(points) <- proj4string(polygon)
  testp <- over(points, polygon)
  if (outside %in% is.na(testp)){
    cleared <- points[is.na(testp) ==  outside ]
  }else{
    cleared <- data.frame(0, 0)
    names(cleared) <- c("XCOOR", "YCOOR")
  }
  if(is.character(testid[,1]) || is.factor(testid[,1])){
    idcleared <- id[is.na(testp) ==  outside ]
    out <- cbind(idcleared, data.frame(cleared))
  }else{
    out <- cleared
  }
  return(out)
}

WWFnam <- function(x) {
  indrealm <- cbind(c("Australasia", "Antacrtic", 
                      "Afrotropis", "IndoMalay", 
                      "Neartic", "Neotropics", 
                      "Oceania", "Palearctic"), 
                    c("AA", "AN", "AT", "IM", "NA", "NT", "OC", "PA"))
  rea <- indrealm[which(indrealm[, 2] %in% x$REALM), 1]
  
  indbiome <- cbind(c( "Tropical and Subtropical Moist Broadleaf Forests", 
                       "Tropical and Subtropical Dry Broadleaf Forests", 
                       "Tropical and Subtropical Coniferous Forests", 
                       "Temperate Broadleaf and Mixed Forests", 
                       "Temperate Conifer Forests", 
                       "Boreal Forests/Taiga", 
                       "Tropical and Subtropical Grasslands and Savannas and Shrublands", 
                       "Temperate Grasslands and Savannas and Shrublands", 
                       "Flooded Grasslands and Savannas", 
                       "Montane Grasslands and Shrublands", 
                       "Tundra", 
                       "Mediterranean Forests, Woodlands and Scrub", 
                       "Deserts and Xeric Shrublands", 
                       "Mangroves"), c(1:14))
  biom <- indbiome[which(indbiome[, 2] %in% x$BIOME), 1]
  
  ecoregion <- unique(x$ECO_NAME)
  
  pp <- list(REALMS = rea, BIOMES = biom, ECOREGIONS = ecoregion)
  return(pp)
}

WWFpick <- function(x, name, scale = c("REALM", "BIOME", "ECOREGION")){
  match.arg(scale)
  if (scale[1] ==  "REALM"){
    indrealm <- cbind(c("Australasia", "Antarctic", 
                        "Afrotropics", "IndoMalay", 
                        "Neartic", "Neotropics", 
                        "Oceania", "Palearctic"), 
                      c("AA", "AN", "AT", "IM", "NA", "NT", "OC", "PA"))
    if (name[1] ==  "all"){name <- indrealm[, 1]}
    test <- name %in% indrealm
    if (F %in% test){
      err <- name[which(test ==  F)]
      stop(paste("Wrong input value. The following Realms were not found. \n", 
                 "Check spelling. See WWFnam() for a list of available options.\n", err, "\n", sep = ""))
    }
    index <- indrealm[which(indrealm[, 1] %in% name), 2]
    dat <- subset(x, x$REALM ==  index)
  }
  if (scale[1] ==  "BIOME"){
    indbiom <- cbind(c( "Tropical and Subtropical Moist Broadleaf Forests", 
                        "Tropical and Subtropical Dry Broadleaf Forests", 
                        "Tropical and Subtropical Coniferous Forests", 
                        "Temperate Broadleaf and Mixed Forests", 
                        "Temperate Conifer Forests", 
                        "Boreal Forests/Taiga", 
                        "Tropical and Subtropical Grasslands and Savannas and Shrublands", 
                        "Temperate Grasslands and Savannas and Shrublands", 
                        "Flooded Grasslands and Savannas", 
                        "Montane Grasslands and Shrublands", 
                        "Tundra", 
                        "Mediterranean Forests, Woodlands and Scrub", 
                        "Deserts and Xeric Shrublands", 
                        "Mangroves"), c(1:14))
    if (name[1] ==  "all"){name <- indbiom[, 1]}
    test <- name %in% indbiom
    if (F %in% test){
      err <- name[which(test ==  F)]
      stop(paste("Wrong input value. The following Biomes were not found. \n", 
                 "Check spelling. See WWFnam() for a list of available options. \n", err, "\n", sep = ""))
    }
    index <- which(indbiom[, 1] %in% name)
    dat <- subset(x, x$BIOME ==  index)
    
  }
  if (scale[1] ==  "ECOREGION"){
    if (name[1] ==  "all"){name <- levels(x$ECO_NAME)}
    test <- name %in% levels(x$ECO_NAME)
    if (F %in% test){
      err <- name[which(test ==  F)]
      stop(paste("Wrong input value. The following ecoregions were not found. \n", 
                 "Check spelling. See WWFnam() for a list of available options. \n", err, "\n", sep = ""))
    }
    dat <- subset(x, x$ECO_NAME ==  name)
  }
  return(dat) 
}

WWFconvert <- function(x){
  liste <- unique(x$ECO_NAME)
  len <- length(liste)
  pointlist <- data.frame(NULL)
  for(i in 1:len){
    bb <- subset(x, x$ECO_NAME ==  liste[i])
    polybb <- slot(bb, "polygons")
    out <- data.frame(NULL)
    for(j in 1:length(polybb)){
      sub <- slot(polybb[[j]], "Polygons")
      polypoints <- slot(sub[[1]], "coords")
      outh <- data.frame(rep(paste(liste[i], j, sep = "_"), length(polypoints)), polypoints)
      names(outh) <- c("identifier", "XCOOR", "YCOOR")
      out <- rbind(out, outh)
    }
    pointlist <- rbind(pointlist, out)
  }
  return(pointlist)
}

WWFpoly2point <- function(x, ...){
  sub <- WWFpick(x, ...) 
  out <- WWFconvert(sub)
  return(out)
}

GetPythonIn <- function(coordinates, polygon, sampletable, speciestable){
  
  idi <- coordinates[, 1]
  coords <- as.matrix(coordinates[, c(2, 3)])
  samtab <- as.data.frame(sampletable)
  spectab <- as.data.frame(speciestable)
  poly <- Cord2Polygon(polygon)
  polytab <- SpPerPolH(spectab)
  coex <- CoExClassH(spectab)
  
  nc <- subset(samtab, is.na(samtab$homepolygon))
  identifier <- idi[as.numeric(rownames(nc))]
  bb <- coords[as.numeric(rownames(nc)), ]
  noclass <- data.frame(identifier, bb)
  
  
  outo <- list(identifier_in = idi, species_coordinates_in = coords, polygons = poly, 
               sample_table = , spec_table = spectab, polygon_table = poltab, 
               not_classified_samples = noclass, coexistence_classified = coex)
  class(outo) <- "spgeoOUT"
  return(outo)  
}

############################################################################################
#output functions
############################################################################################

# NexusOut <- function(x){} #write this function

WriteTablesSpGeo <- function(x, ...){
  if (class(x) ==  "spgeoOUT"){
    write.table(x$sample_table, file = "sample_classification_to_polygon.txt", sep = "\t", ...)
    write.table(x$spec_table, file = "species_occurences_per_polygon.txt", sep =  "\t", ...)
    write.table(x$polygon_table, file = "speciesnumber_per_polygon.txt", sep = "\t", ...)
    write.table(x$not_classified_samples, file = "unclassified samples.txt", sep = "\t", ...)
    write.table(x$coexistence_classified, file = "species_coexistence_matrix.txt", sep = "\t", ...)
  }else{
    stop("This function is only defined for class spgeoOUT")
  }
}

PlotSpPoly <- function(x, ...){
  if (class(x) ==  "spgeoOUT") {
    num <- length(names(x$polygon_table))
    counter <- num/10
    #     if (counter < 1){
    par(mar = c(10, 4, 2, 2))
    barplot(x$polygon_table, 
            ylim = c(0, round((max(x$polygon_table) + max(x$polygon_table)/4), 0)), 
            ylab = "Number of Species per Polygon", las = 2, )# ...)
    #     }else{
    #       sets <- seq(1, (ceiling(num/10) *10)+1, by = 10)
    #       par(mar = c(10, 4, 2, 2))
    #       for(i in 1:num){
    #       barplot(x$polygon_table[sets[i], sets[i+1]], 
    #             ylim = c(0, round((max(x$polygon_table) + max(x$polygon_table)/4), 0)), 
    #             ylab = "Number of Species per Polygon", las = 2, ...)
    #       }
    #     }
  }
  else{
    stop("This function is only defined for class <spgeoOUT>")
  }
}

BarChartSpec <- function(x, mode = c("percent", "total"), plotout = F, ...){
  match.arg(mode)
  if (!class(x) ==  "spgeoOUT" && !class(x) ==  "spgeoH"){
    stop("This function is only defined for class spgeoOUT")
  }  
  if (plotout ==  FALSE){par(ask = T)}
  if (mode[1] ==  "total"){
    liste <- x$spec_table$identifier
    leng <-  length(liste)
    par(mar = c(10, 4, 3, 3))
    for(i in 1:leng){
      spsub <- as.matrix(subset(x$spec_table, x$spec_table$identifier ==  liste[i])[, 2:leng2])
      if (sum(spsub) > 0){
        barplot(spsub, las = 2, ylim = c(0, (max(spsub) + max(spsub) / 10)), 
                ylab = "Number of occurrences" , ...)
        title(liste[i])
      }
    }
  }
  if (mode[1] ==  "percent"){
    percent <- x$spec_table[, -1]
    anzpoly <-length(names(x$spec_table)[-1]) 
    if (anzpoly > 1){
      percent2  <- percent / rowSums(percent) * 100
    }else{
      percent2  <- percent / sum(percent) * 100
    }
    percent2[percent2 ==  "NaN"] <- 0
    percent2 <- data.frame(identifier = x$spec_table[, 1], percent2)
    
    liste <- x$spec_table$identifier
    leng <-  length(liste)
    leng2 <- length(colnames(percent2))
    par(mar = c(10, 4, 3, 3))
    for(i in 1:leng){
      if (anzpoly > 1){
        spsub <- as.matrix(subset(percent2, percent2$identifier ==  liste[i])[, 2:leng2])
      }else{
        spsub <- as.matrix(percent2[percent2$identifier ==  liste[i], ][, 2:leng2])
        names(spsub) <- names(x$spec_table)[-1]
      }
      if (sum(spsub) > 0){
        barplot(spsub, las = 2, ylim = c(0, (max(spsub) + max(spsub) / 10)), 
                ylab = "Percent of occurrences", names.arg = names(spsub), ...)
        title(liste[i])
      }
    }
  }  
  par(ask = F)
}

BarChartPoly <- function(x, plotout = F, ...){
  if (!class(x) ==  "spgeoOUT" && !class(x) ==  "spgeoH"){
    stop("This function is only defined for class spgeoOUT")
  }  
  if (plotout ==  FALSE){par(ask = T, mar = c(15, 4, 3, 3))}
  x$spec_table
  liste <- names(x$spec_table)
  leng <- length(liste)
  par(mar = c(15, 4, 3, 3))
  for(i in 2:leng){
    subs <-subset(x$spec_table, x$spec_table[, i] > 0)
    barplot(subs[, i], names.arg = subs$identifier, 
            las = 2, ylab = "Number of occurences", ...)
    title(liste[i])
  }
  par(ask = F)
}

HeatPlotCoEx <- function(x, ...){
  
  if (class(x) ==  "spgeoOUT" ){
    dat <- x$coexistence_classified
  }else{ 
    dat <- x
  }
  if (class(dat) !=  "data.frame"){
    stop("Wrong input format. Input must be a data.frame.")
  }
  if (dim(dat)[2] !=  (dim(dat)[1] + 1)){
    warning("Suspicous data dimensions, check input file.")
  }
  ymax <- dim(dat)[1]
  xmax <- dim(dat)[2]
  colo <- rev(heat.colors(10))
  numer <- rev(1:ymax)
  
  layout(matrix(c(rep(1, 9), 2), ncol = 1, nrow = 10))
  par(mar =  c(0, 10, 10, 0))
  plot(0, xlim = c(0, xmax - 1), ylim = c(0, ymax) , type = "n", axes = F, xlab = "", ylab = "")
  for(j in 2:xmax ){
    for(i in 1:ymax){
      if (i ==  (j - 1)){
        rect(j - 2, numer[i] - 1 , j - 1, numer[i], col = "black" )
      }else{
        ind <- round(dat[i, j]/10, 0)
        if (ind ==  0) {
          rect(j - 2, numer[i]-1, j - 1, numer[i], col = "white" )
        }else{
          rect(j - 2, numer[i]-1 , j - 1, numer[i], col = colo[ind] )
        }
      }
    }
  }
  axis(side = 3, at = seq(0.5, (xmax - 1.5)), labels = colnames(dat)[-1], las = 2, cex.axis = .7, pos = ymax)
  axis(2, at = seq(0.5, ymax), labels = rev(dat$identifier), las = 2, cex.axis = .7, pos =  0)
  title("Species co-occurrence", line = 9)
  
  par(mar = c(0.5, 10, 0, 0))
  plot(c(1, 59), c(1, 12), type = "n", axes = F, ylab  = "", xlab = "")
  text(c(13, 13), c(10, 7), c("0%", "10%"))
  text(c(20, 20), c(10, 7), c("20%", "30%"))
  text(c(27, 27), c(10, 7), c("40%", "50%"))
  text(c(34, 34), c(10, 7), c("60%", "70%"))
  text(c(41, 41), c(10, 7), c("80%", "90%"))
  text(c(48), 10, "100%")
  rect(c(9, 9, 16, 16, 23, 23, 30, 30, 37, 37, 44), c(rep(c(10.7, 7.7), 5), 10.7), 
       c(11, 11, 18, 18, 25, 25, 32, 32, 39, 39, 46), c(rep(c(8.7, 5.7), 5), 8.7), 
       col = c("white", colo))
  rect(7, 5, 51, 12)
}

Mapping <- function(x, pdataf, mode = c("dataset", "spgeoOUT"), 
                    pointmode = c("all", "classified"), 
                    scale = c("auto_extent", "extent", "world", "country"), 
                    name, xmin, xmax, ymin, ymax, ...) {
  match.arg(scale)
  match.arg(mode)
  match.arg(pointmode)
  if (scale[1] ==  "extent" && xmin < -180 ||
        scale[1] ==  "extent" && xmax > 180 || 
        scale[1] ==  "extent" && ymin < -90 || 
        scale[1] ==  "extent" && ymax > 90){
    stop("Boundary coordinates, must be between -180 and 180 for longitude and \n between -90 and 90 for lat")
  }
  if (mode[1] ==  "dataset" && class(x) ==  "spgeoOUT"){
    mode <- "spgeoOUT"
    warning("Mode was set to spgeoOUT due to input class")
  }
  if (mode[1] ==  "dataset" && class(x) !=  "SpatialPolygons"){
    stop("For mode <dataset> x must be an object of class <SpatialPolygons>.")
  }
  if (mode[1] ==  "dataset" && class(pdataf) !=  "data.frame"){
    stop("For mode <dataset> pdataf must be an object of class <data.frame>.
         Columns must be: <identifier>, <YCOOR>, <XCOOR>")
  }
  
  if (mode[1] ==  "dataset"){
    polyg <- x
    notclass <- pdataf
  }
  if (mode[1] ==  "spgeoOUT"){
    if (class(x) !=  "spgeoOUT"){
      warning("Mode <spgeoOUT> is only defined for class <spgeoOUT>. \n Use mode = <dataset> for datasets")
    }else{
      if (pointmode[1] ==  "all"){
        pdataf <- data.frame(x$identifier_in, x$species_coordinates_in)
        names(pdataf) <- c("identifier", "YCOOR", "XCOOR")
      }
      if (pointmode[1] ==  "classified"){
        sub <- subset(x$sample_table, is.na(x$sample_table[, 2]) ==  F)
        pdataf <- data.frame(identifier = x$identifier_in, x$species_coordinates_in)
        pdataf <- pdataf[rownames(sub), ]
      }
    }
    polyg <- x$polygons
    notclass <- x$not_classified_samples
  }
  data(wrld_simpl)
  dev.off()
  ma <- map("world")
  plot.new()
  additions <- wrld_simpl$NAME[which(wrld_simpl$NAME %in% ma$names ==  FALSE)]
  additionsplot <-  subset(wrld_simpl, wrld_simpl$NAME %in% additions)
  
  par(mar = c(2, 2, 2, 2), ...)
  
  if (scale[1] ==  "world"){
    map("world")
    axis(1)
    axis(2)
    box("plot")
    plot(additionsplot, add  = T)
    plot(polyg, col = "grey60", add = T)
    points(pdataf$XCOOR, pdataf$YCOOR, 
           cex = 0.7, pch = 3 , col = "red")
  }
  if (scale[1] ==  "country"){
    spell <- which((name %in% ma$name) == FALSE &&
                     (name %in% wrld_simpl$NAME) ==  FALSE)
    if (length(spell) > 0){
      cat("The following names were not found in the dataset: \n Please check spelling:\n", 
          name[spell], "\n")
    }
    len <- length(name)
    if (name %in% ma$name){
      if (len ==  1){
        pointcrop <- as.data.frame(CropPointCountry(pdataf, name))
        names(pointcrop) <- c("XCOOR", "YCOOR")
        if (name ==  "USA"){
          map("world", regions = name, xlim = c(-180, -50), ylim = c(20, 75))
          
        }else{
          map("world", regions = name)
        }
        axis(1)
        axis(2)
        box("plot")
        plot(polyg, col = "grey60", add = T)
        points(pointcrop$XCOOR, pointcrop$YCOOR, 
               cex = 0.7, pch = 3 , col = "red")
      }
      if (len > 1){
        pointcrop <- as.data.frame(CropPointCountry(pdataf, name))
        names(pointcrop) <- c("XCOOR", "YCOOR")
        map("world", regions = name)
        axis(1)
        axis(2)
        box("plot")
        plot(polyg, col = "grey60", add = T)
        points(pointcrop$XCOOR, pointcrop$YCOOR, 
               cex = 0.7, pch = 3 , col = "red")
      }
    }else{
      if (len ==  1){
        if (name ==  "Russia"){
          map("world", regions = "USSR", xlim = c(20, 180), type =  "n")
          plot(subset(wrld_simpl, wrld_simpl$NAME ==  name), add = T)
        }else{
          pointcrop <- as.data.frame(CropPointCountry(pdataf, name))
          names(pointcrop) <- c("XCOOR", "YCOOR")
          plot(subset(wrld_simpl, wrld_simpl$NAME ==  name))
        }
        axis(1)
        axis(2)
        box("plot")
        plot(polyg, col = "grey60", add = T)
        points(pointcrop$XCOOR, pointcrop$YCOOR, 
               cex = 0.7, pch = 3 , col = "red")
      }
    }
    if (len > 1){
      pointcrop <- as.data.frame(CropPointCountry(pdataf, name))
      names(pointcrop) <- c("XCOOR", "YCOOR")
      plot(subset(wrld_simpl, wrld_simpl$NAME ==  name))
      plot(polyg, col = "grey60", add = T)
      points(pointcrop$XCOOR, pointcrop$YCOOR, 
             cex = 0.7, pch = 3 , col = "red")
    }
  }
  if (scale[1] ==  "extent"){
    map("world", xlim = c(xmin, xmax), ylim = c(ymin, ymax))
    axis(1)
    axis(2)
    box("plot")
    plot(polyg, col = "grey60", add = T)
    points(pdataf$XCOOR, pdataf$YCOOR, 
           cex = 0.7, pch = 3 , col = "red")
  }
  if (scale[1] ==  "auto_extent"){
    xmax <- max(bbox(polyg)[1, 2], max(notclass$XCOOR))
    xmin <- min(bbox(polyg)[1, 1], min(notclass$XCOOR))
    ymax <- max(bbox(polyg)[2, 2], max(notclass$YCOOR))
    ymin <- min(bbox(polyg)[2, 1], min(notclass$YCOOR))
    
    map("world", xlim = c(xmin, xmax), ylim = c(ymin, ymax))
    axis(1)
    axis(2)
    box("plot")
    plot(polyg, col = "grey60", add = T)
    points(pdataf$XCOOR, pdataf$YCOOR, 
           cex = 0.7, pch = 3 , col = "red")
  }
  }

MapPerPoly <- function(x, plotout = FALSE){
  if (!class(x) ==  "spgeoOUT"){
    stop("This function is only defined for class spgeoOUT")
  }
  for(i in 1:length(names(x$polygons))){
    chopo <- names(x$polygons)[i]
    xmax <- max(bbox(x$polygons[i])[1, 2]) + 5
    xmin <- min(bbox(x$polygons[i])[1, 1]) - 5
    ymax <- max(bbox(x$polygons[i])[2, 2]) + 5
    ymin <- min(bbox(x$polygons[i])[2, 1]) - 5
    
    po <- data.frame(x$sample_table, x$species_coordinates_in)
    subpo <- subset(po, po$homepolygon ==  chopo)
    
    subpo <- subpo[order(subpo$identifier), ]  
    colorh <- unique(subpo$identifier)
    lcolorh <- length(colorh)
    rain <- rainbow(lcolorh)
    for(j in 1:length(subpo$identifier)){
      subpo$color[j] <- which(colorh ==  subpo$identifier[j])
    }
    
    ypos <- vector(length = lcolorh)
    yled <- (ymax - ymin) * 0.025
    for(k in 1:lcolorh){
      ypos[k]<- ymax - yled * k
    }
    
    layout(matrix(c(1, 1, 1, 2, 2), ncol =  5, nrow = 1))
    par(mar = c(3, 3, 3, 0))
    map("world", xlim = c(xmin, xmax), ylim = c(ymin, ymax))
    axis(1)
    axis(2)
    box("plot")
    title(chopo)
    plot(x$polygons[i], col = "grey60", add = T)
    points(subpo$XCOOR, subpo$YCOOR, 
           cex = 0.7, pch = 3 , col = rain[subpo$color])
    #legend
    par(mar = c(3, 0, 3, 0), ask = F)
    plot(c(1, 50), c(1, 50), type = "n", axes = F)
    if (lcolorh ==  1){
      yset <- 25
    }else{
      yset <- rev(sort(c(seq(25, 25 + max(ceiling(lcolorh/2) - 1, 0)), 
                         seq(24, 24 - lcolorh/2 + 1))))
    }
    xset <- rep(4, lcolorh)
    points(xset-2, yset, pch =  3, col = rain)
    text(xset, yset, labels =  colorh, adj = 0, xpd = T)
    rect(min(xset) - 4, min(yset) -1, 50 + 1, max(yset) + 1, xpd = T)
    
    if (plotout ==  FALSE){par(ask = T)}
  }
  par(ask = F)
}

MapPerSpecies <- function(x, moreborders = F, plotout = FALSE, ...){
  if (!class(x) ==  "spgeoOUT"){
    stop("This function is only defined for class spgeoOUT")
  }
  layout(matrix(c(1, 1, 1, 1), ncol = 1, nrow = 1))
  if (plotout ==  FALSE){par(ask = T)}
  dat <- data.frame(x$sample_table, x$species_coordinates_in)
  liste <- levels(dat$identifier)
  
  
  for(i in 1:length(liste)){
    kk <- subset(dat, dat$identifier ==  liste[i])
    inside <- CropPointPolygon(data.frame(XCOOR = kk$XCOOR, YCOOR = kk$YCOOR), x$polygons, 
                               outside = F)
    outside <- CropPointPolygon(data.frame(XCOOR = kk$XCOOR, YCOOR = kk$YCOOR), x$polygons, 
                                outside = T)
    xmax <- max(dat$XCOOR) + 2
    xmin <- min(dat$XCOOR) - 2
    ymax <- max(dat$YCOOR) + 2
    ymin <- min(dat$YCOOR) - 2
    
    map ("world", xlim = c(xmin, xmax), ylim = c(ymin, ymax))
    axis(1)
    axis(2)
    box("plot")
    title(liste[i])
    if (moreborders == T) {plot(wrld_simpl, add = T)}
    plot(x$polygons, col = "grey60", add = T)
    points(inside$XCOOR, inside$YCOOR, 
           cex = 0.7, pch = 3 , col = "blue")
    points(outside$XCOOR, outside$YCOOR, 
           cex = 0.7, pch = 3 , col = "red")
  }
  par(ask = F)
}

MapAll <- function(x, polyg, moreborders = F, ...){
  data(wrld_simpl)
  if (class(x) ==  "spgeoOUT"){
    xmax <- max(x$species_coordinates_in[, 2]) + 2
    xmin <- min(x$species_coordinates_in[, 2]) - 2
    ymax <- max(x$species_coordinates_in[, 1]) + 2
    ymin <- min(x$species_coordinates_in[, 1]) - 2
    
    map ("world", xlim = c(xmin, xmax), ylim = c(ymin, ymax))
    axis(1)
    axis(2)
    box("plot")
    title("All samples")
    if (moreborders ==  T) {plot(wrld_simpl, add = T)}
    plot(x$polygons, col = "grey60", add = T, ...)
    points(x$species_coordinates_in[, 1], x$species_coordinates_in[, 2], 
           cex = 0.7, pch = 3 , col = "blue", ...)
  }
  if (class(x) ==  "matrix" || class(x) ==  "data.frame"){
    if (!is.numeric(x[, 1]) || !is.numeric(x[, 2])){
      stop(paste("Wrong input format:\n", 
                 "Point input must be a <matrix> or <data.frame> with 2 columns.\n", 
                 "Column order must be lon - lat.", sep = ""))
    }
    if (class(polyg) !=  "SpatialPolygons"){
      warning("To plot polygons, polyg must be of class <SpatialPolygons>.")
    }
    x <- as.data.frame(x)
    nums <- sapply(x, is.numeric)
    x<- x[, nums]
    xmax <- max(x[, 2]) + 2
    xmin <- min(x[, 2]) - 2
    ymax <- max(x[, 1]) + 2
    ymin <- min(x[, 1]) - 2
    if (ymax > 92 || ymin < -92){
      warning("Column order must be lon-lat, not lat - lon. Please check")
    }
    map ("world", xlim = c(xmin, xmax), ylim = c(ymin, ymax))
    axis(1)
    axis(2)
    title("All samples")
    box("plot")
    if (moreborders ==  T) {plot(wrld_simpl, add = T, ...)}
    plot(polyg, col = "grey60", add = T, ...)
    points(x[, 2], x[, 1], 
           cex = 0.7, pch = 3 , col = "blue", ...)
    
  }
}

MapUnclassified <- function(x, moreborders = F, ...){
  if (!class(x) ==  "spgeoOUT"){
    stop("This function is only defined for class spgeoOUT")
  }
  dat <- data.frame(x$not_classified_samples)
  if (length(dat) ==  0){
    plot(c(1:20), c(1:20), type  = "n", axes = F, xlab = "", ylab = "")
    text(10, 10, labels = paste("All points fell into the polygons and were classified.\n", 
                                "No unclassified points", sep = ""))
  }else{
    xmax <- max(dat$XCOOR) + 2
    xmin <- min(dat$XCOOR) - 2
    ymax <- max(dat$YCOOR) + 2
    ymin <- min(dat$YCOOR) - 2
    
    map ("world", xlim = c(xmin, xmax), ylim = c(ymin, ymax), ...)
    axis(1)
    axis(2)
    box("plot")
    title("Samples not classified to polygons")
    if (moreborders == T) {plot(wrld_simpl, add = T)}
    plot(x$polygons, col = "grey60", add = T, ...)
    points(dat$XCOOR, dat$YCOOR, 
           cex = 0.7, pch = 3 , col = "red", ...)
  }
}  

OutMapAll <- function(x, ...){
  pdf(file = "map_samples_overview.pdf", paper = "a4r", onefile = T, ...)
  MapAll(x, ...)
  MapUnclassified(x, ...)
  dev.off()
}

OutMapPerPoly <- function(x){
  pdf(file = "map_samples_per_polygon.pdf", paper = "a4r", onefile = T)
  MapPerPoly(x, plotout = T)
  dev.off()
}

OutMapPerSpecies <- function(x){
  pdf(file = "map_samples_per_species.pdf", paper = "a4r", onefile = T)
  MapPerSpecies(x, plotout = T)
  dev.off()
}

OutBarChartSpec <- function(x, ...){
  pdf(file = "barchart_per_species.pdf", paper = "a4r", onefile = T)
  BarChartSpec(x, plotout = T, mode = "percent", ...)
  dev.off()
}

OutBarChartPoly <- function(x, ...){
  pdf(file = "barchart_per_polygon.pdf", paper = "a4r", onefile = T)
  BarChartPoly(x, plotout = T, cex.names = .8, cex.axis = .8, ...)
  dev.off()
}

OutHeatCoEx <- function(x, ...){
  pdf(file = "heatplot_coexistence.pdf", paper = "a4r", onefile = T)
  HeatPlotCoEx(x, ...)
  dev.off()
}

OutPlotSpPoly <- function(x, ...){
  pdf(file = "number_of_species_per_polygon.pdf", paper = "a4r", onefile = T)
  PlotSpPoly(x, ...)
  dev.off()
}

PlotOutSpGeo <- function(x, ...){
  OutPlotSpPoly(x, ...)
  OutBarChartPoly(x, ...)
  OutBarChartSpec(x, ...)
  OutMapAll(x, ...)
  OutMapPerPoly(x, ...)
  OutMapPerSpecies(x, ...)
  OutHeatCoEx(x, ...)
}

SpeciesGeoCoder <- function(x, y, ...){
  ini <- ReadPoints(x, y, ...)
  outo <- SpGeoCodH(ini, ...)
  
  WriteTablesSpGeo(outo, ...)
  PlotOutSpGeo(outo, ...)
}
