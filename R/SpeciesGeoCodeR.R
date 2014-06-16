# dependencies
pkload <- function(x)
{
  if (!require(x,character.only = TRUE, quietly = T))
  {
    install.packages(x,dep=TRUE, quiet = T)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}

pkload("rgeos")
pkload("maptools")
pkload("maps")
pkload("mapdata")
pkload("raster")
# pkload("utils")

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
#       cat(paste(i,"\n"))
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
#       cat(paste(i,"\n"))
    } 
    polys <- SpatialPolygons(col, proj4string = CRS("+proj=longlat +datum=WGS84"))
  }
  return(polys)
}

#reads in txt files from files name, tab delimited, 3 columns each, x = pointcoordinates, y polygon coordinates, add corrections for bad input files here.
ReadPoints<- function(x, y) {   
  res <- list()
  if(class(x) != "character" && class(x) != "data.frame"){
    stop(paste("Function not defined for class: ", class(x), sep = ""))
  }
  if(class(x) == "character"){  
    coords <- read.table(x, sep = "\t", header = T)
  }
  if(class(x) == "data.frame"){
    coords <- x
  }
    
  if(class(y) != "SpatialPolygonsDataFrame" && class(y) != "SpatialPolygons")
  {
    cat("Reading in polygon coordinates. \n")
    if(class(y) == "character"){
      polycord <- read.table(y, sep = "\t", header = T)
    }
    if(class(y) == "data.frame"){
      polycord <- y
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
    if(max(polycord[, 2]) > 180){
      warning(paste("Check polygon input coordinates. File contains longitude values outside possible range in row:",
                 rownames(polycord[polycord[,2] > 180,]),"\n", "Coordinates set to maximum: 180 \n", sep = ""))
      polycord[polycord[, 2] > 180,2] <- 180
    }
    if(min(polycord[, 2]) < -180){
      warning(paste("Check polygon input coordinates. File contains longitude values outside possible range in row: ",
                    rownames(polycord[polycord[,2] < -180,]),"\n", "Coordinates set to minimum: -180 \n", sep = ""))
      polycord[polycord[, 2] < -180,] <- -180

    }
    if(max(polycord[, 3]) > 90){
      warning(paste("Check polygon input coordinates. File contains latitude values outside possible range in row:",
                 rownames(polycord[polycord[,3] > 90,]),"\n", "Coordinates set to maximum: 90 \n", sep = ""))
      polycord[polycord[, 3] > 90,3] <- 90
    }
    if(min(polycord[, 3]) < -90){
      warning(paste("Check polygon input coordinates. File contains latitude values outside possible range in row:",
                 rownames(polycord[polycord[,3] < -90,]),"\n", "Coordinates set to minimum: -90 \n", sep = ""))
      polycord[polycord[, 3] < -90,3] <- -90
    }
    poly <- Cord2Polygon(polycord)
    cat("Done \n")
  }else{
    cat("Reading in polygon coordinates. \n")
    poly <- y
    cat("Done \n")
  }
  
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
 
  cat("Reading in point coordinates. \n")
  coordi <- coords[, c(2, 3)]
  coordi2 <- as.matrix(coordi)
  cat("Done \n")
  res <- list(identifier = coords[, 1], species_coordinates = coordi, 
              polygons = poly)
  class(res) <- "spgeoIN"
  return(res)
  
}

PipSamp <- function(x){
  if (class(x) != "spgeoIN"){
    stop(paste ("Function is only defined for class spgeoIN.\n", 
                "Use ReadPoints() to produce correct input format.", sep = ""))
  }
  occ <- SpatialPoints(x$species_coordinates[, c(1, 2)])
    
  if(class(x$polygons) == "SpatialPolygonsDataFrame")
  {
    liste <- unique(x$polygons$ECO_NAME)
    bid <- data.frame(x$identifier,rep(NA,length(x$identifier)))
    
    for(i in 1:length(liste))
    {
      b <- subset(x$polygons,x$polygons$ECO_NAME == liste[i])
      aaa <-SpatialPolygons(slot(b,"polygons"))
      proj4string(aaa) <- proj4string(occ) <- "+proj=longlat +datum=WGS84"
      rr <- over(occ,aaa)
      rr[rr>0] <- as.character(liste[i])
      if(length(which(rr != "NA")) != 0){
        bid[which(rr != "NA"),2] <- rr[which(rr != "NA")] 
      }
    }
    names(bid) <- c("identifier", "homepolygon")
    bid$homepolygon <-  as.factor(bid$homepolygon)
    class(bid) <- c("spgeodataframe", "data.frame")
    return(bid)
    
  }else{
#     liste <- levels(x$identifier)
    pp <- x$polygons#[i]
    proj4string(occ) <- proj4string(pp) <- "+proj=longlat +datum=WGS84"
    cat("Performing point in polygon test \n")
    pip <- over(occ, pp)
    cat("Done \n")
    pip <- data.frame(x$identifier, pip)
    colnames(pip) <- c("identifier", "homepolygon")
    for(i in 1:length(names(x$polygons))){
      pip$homepolygon[pip$homepolygon ==  i] <- names(x$polygons)[i] 
    }
    pip$homepolygon <- as.factor(pip$homepolygon)
    class(pip) <- c("spgeodataframe", "data.frame")
    return(pip)
  }
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
    cat("Calculating species occurences per polygon \n")
    liste <- levels(x$homepolygon)
    if(length(liste) == 0){
      spec_sum <- NULL
    }else{
      spec_sum <- data.frame(identifier = levels(x$identifier))
      for(i in 1:length(liste)){
        pp <- subset(x, x$homepolygon ==  liste[i])
      
        kk <- aggregate(pp$homepolygon, by = list(pp$identifier), length)
        names(kk) <- c("identifier", liste[i])
        spec_sum <- merge(spec_sum, kk, all = T)
        cat(paste("Calculating species occurences for polygon: ", i, "/", length(liste),": ",liste[i],"\n", sep = ""))
      }
      spec_sum[is.na(spec_sum)] <- 0
    }
    return(spec_sum)
    cat("Done \n")
}

SpSum <- function(x){
  samp <- PipSamp(x)
  SpSumH(samp)
}

SpPerPolH <- function(x){
  cat("Calculating species number per polygon. \n") 
  numpoly <- length(names(x)[-1])
  if(numpoly == 0){
    num_sp_poly <- NULL
  }else{
    pp <- x[, -1]
    pp[pp > 0] <- 1
    if (numpoly > 1){
      num_sp_poly <- data.frame(t(colSums(pp)))
    }else{
      num_sp_poly <- data.frame(sum(pp))
      names(num_sp_poly) <- names(x)[2]
    }
  }
  return(num_sp_poly)
  cat("Done")
}

SpPerPol <- function(x){
  kkk <- PipSamp(x)
  jjj <- SpSumH(kkk)
  iii <- SpPerPolH(jjj)
  return(iii)
}

CoExClassH <- function(x){
  dat <- x
  if(length(dim(dat)) == 0){
    coemat <- "NULL"
  }else{
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
      cat(paste("Calculate coexistence pattern for species: ", j, "/", spnum, " ", dat$identifier[j], "\n", sep = ""))
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
  }
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
    
    if(length(spsum) == 0)
      {
      namco <- c("identifier", names(x$polygons))
      fill <- matrix(0, nrow = length(unique(kkk$identifier)), ncol = length(names(x$polygons)))
      fill <- data.frame(fill)
      spsum <- data.frame(cbind(as.character(unique(kkk$identifier)),fill))
      names(spsum) <- namco   
      }
    
    sppol <- SpPerPolH(spsum)
    
    
    nc <- subset(kkk, is.na(kkk$homepolygon))
    identifier <- x$identifier[as.numeric(rownames(nc))]
    bb <- x$species_coordinates[as.numeric(rownames(nc)), ]
    miss <- data.frame(identifier, bb)
    names(miss) <- c("identifier","XCOOR","YCOOR")
    
    out <- list(identifier_in = x$identifier, species_coordinates_in = x$species_coordinates, polygons = x$polygons, 
                sample_table = kkk, spec_table = spsum, polygon_table = sppol, 
                not_classified_samples = miss, coexistence_classified = "NA")
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
    cleared <- data.frame()
      }
  if(is.character(testid[,1]) || is.factor(testid[,1])){
    idcleared <- id[is.na(testp) ==  outside ]
    out <- cbind(idcleared, data.frame(cleared))
  }else{
    out <- cleared
  }
  return(out)
}

WWFload <- function(){
  download.file("http://assets.worldwildlife.org/publications/15/files/original/official_teow.zip",
  "wwf_ecoregions.zip")#?1349272619")
  unzip("wwf_ecoregions.zip", exdir = "WWF_ecoregions")
  file.remove("wwf_ecoregions.zip")
  wwf <- readShapeSpatial("WWF_ecoregions\\official\\wwf_terr_ecos.shp")
  return(wwf)
}

WWFnam <- function(x) {
  indrealm <- cbind(c("Australasia", "Antarctic", 
                      "Afrotropics", "IndoMalay", 
                      "Nearctic", "Neotropics", 
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
  
  ecoregion <- sort(unique(x$ECO_NAME))
  
  pp <- list(REALMS = rea, BIOMES = biom, ECOREGIONS = ecoregion)
  return(pp)
}

WWFpick <- function(x, name, scale = c("REALM", "BIOME", "ECOREGION")){
  match.arg(scale)
  if (scale[1] ==  "REALM"){
    indrealm <- cbind(c("Australasia", "Antarctic", 
                        "Afrotropics", "IndoMalay", 
                        "Nearctic", "Neotropics", 
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
    dat <- subset(x, x$REALM %in% index)
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
    dat <- subset(x, x$BIOME %in% index)
    
  }
  if (scale[1] ==  "ECOREGION"){
    if (name[1] ==  "all"){name <- levels(x$ECO_NAME)}
    test <- name %in% levels(x$ECO_NAME)
    if (F %in% test){
      err <- name[which(test ==  F)]
      stop(paste("Wrong input value. The following ecoregions were not found. \n", 
                 "Check spelling. See WWFnam() for a list of available options. \n", err, "\n", sep = ""))
    }
    dat <- subset(x, x$ECO_NAME %in%  name)
  }
  return(dat) 
}

WWFconvert <- function(x){
  liste <- unique(x$ECO_NAME)
  len <- length(liste)
  pointlist <- data.frame(NULL)
  for(i in 1:len){
    cat(paste("Converting polygon ", i, "/", len, ": ", liste[i], "\n", sep = ""))
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

GetPythonIn <- function(inpt){
  
  coord <- read.table(inpt[1],header = T, sep = "\t")
  idi <- coord[, 1]
  coords <- coord[, c(2, 3)]
  
  polyg <- read.table(inpt[2], header = T, sep = "\t")
  poly <- Cord2Polygon(polyg)
  
  samtab <- read.table(inpt[3], header = T, sep = "\t")
  
  spectab <- read.table(inpt[4], header = T, sep = "\t")
  names(spectab)[1] <- "identifier"
  
  polytab <- SpPerPolH(spectab)
  
  nc <- subset(samtab, is.na(samtab$homepolygon))
  identifier <- idi[as.numeric(rownames(nc))]
  bb <- coords[as.numeric(rownames(nc)), ]
  noclass <- data.frame(identifier, bb)
  
  
  outo <- list(identifier_in = idi, species_coordinates_in = coords, polygons = poly, 
               sample_table = samtab, spec_table = spectab, polygon_table = polytab, 
               not_classified_samples = noclass, coexistence_classified = "NA")
  class(outo) <- "spgeoOUT"
  return(outo)  
}

ConvertPoly <- function(x){
  x <- read.table(x,sep = "\t")

  out2 <- vector()
  
  for(j in 1:dim(x)[1]){
    aa <-as.character(x[j,])
    ff <- t(aa)
    bb <- unlist(strsplit(ff[1], split = ":"))
    bb <-c(bb[1], unlist(strsplit(bb[2], split = " ")))
    
    out <- vector()
    
    for(i in 3:length(bb)){
      dd <- c(bb[1], unlist(strsplit(as.character(bb[i]), split = ",")))
      out <- rbind(out, dd)
    }
    out2 <-rbind(out2,out)
  }
  
  colnames(out2) <- c("identifier", "XCOOR", "YCOOR")
  rownames(out2) <- NULL
  out2 <- as.data.frame(out2)
  return(out2)
}

clust <- function(x, shape, scale){
  cat(paste("Clustering information on", scale, "\n", sep = " "))
  if(scale != "ECOREGION"){
    nam <- unique(data.frame(as.character(shape$ECO_NAME),shape$BIOME,as.character(shape$REALM), stringsAsFactors = F))
    names(nam) <- c("ecoregion", "biome", "realm")
    
    indrealm <- cbind(c("Australasia", "Antarctic", 
                        "Afrotropics", "IndoMalay", 
                        "Nearctic", "Neotropics", 
                        "Oceania", "Palearctic"), 
                      c("AA", "AN", "AT", "IM", "NA", "NT", "OC", "PA"))
    
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
    for(i in 1: dim(indbiome)[1])
    {
      nam$biome[nam$biome == indbiome[i,2]] <- indbiome[i,1]
    }
    for(i in 1: dim(indrealm)[1])
    {
      nam$realm[nam$realm == indrealm[i,2]] <- indrealm[i,1]
    }
    
    if(scale == "BIOME")
    {
      ppp <- as.character(x$sample_table$homepolygon)
      for(i in 1:length(nam$ecoregion))
      {
        ppp[ppp == nam$ecoregion[i]] <- nam$biome[i]
      }
    }
    if(scale == "REALM")
    {
      ppp <- as.character(x$sample_table$homepolygon)  
      for(i in 1:length(nam$ecoregion))
      {
        ppp[ppp == nam$ecoregion[i]] <- nam$realm[i]
      }
    }
    
    ppp <- as.factor(ppp)
    x$sample_table$homepolygon <-ppp
    
    x$spec_table <- SpSumH(x$sample_table)
    
    
    if(length(x$spec_table) == 0)
    {
      namco <- c("identifier", names(x$polygons))
      fill <- matrix(0, nrow = length(unique(x$sample_table)), ncol = length(names(x$polygons)))
      fill <- data.frame(fill)
      x$spec_table <- data.frame(cbind(as.character(unique(x$sample_table$identifier)),fill))
      names(x$spec_table) <- namco   
    }       
    x$polygon_table <- SpPerPolH(x$spec_table)      
  }
  cat("Done \n")
  return(x)
}

DiversityGrid <- function(x, xlim , ylim){
  res <- 1
  if(xlim[1] * xlim[2] <0){
    xwidth <- abs((xlim[2] + abs(xlim[1])) / res)
  }else{
    xwidth <- abs((abs(xlim[2]) - abs(xlim[1])) / res)
  }
  if(ylim[1] * ylim[2] <0){
    ywidth <- abs((ylim[2] + abs(ylim[1])) / res)
  }else{
    ywidth <- abs((abs(ylim[2]) - abs(ylim[1])) / res)
  }
  dimen <- xwidth * ywidth
  polyy <- data.frame()
  
  cat("Creating grid. \n")
  
  for(j in 0:(ywidth-1)){
    dimen2 <- j * (xwidth) +  (1:(xwidth))
    polyx <- data.frame()
    ylimd <- c(ylim[2] - res * j , ylim[2] - res * (j+1))
    
    for(i in 0:(xwidth-1)){
      poly <- rbind(c(xlim[1] + res * i, ylimd[2]), 
                    c(xlim[1] + res * (i+1), ylimd[2]),
                    c(xlim[1] + res * (i+1), ylimd[1]), 
                    c(xlim[1] + res * i, ylimd[1]),
                    c(xlim[1] + res * i, ylimd[2]))
      
      poly <- data.frame(cbind(as.character(rep(dimen2[i+1],5)),poly))
      polyx <- rbind(polyx,poly)
      #cat(paste(j, i, "\n"))
    }
    polyy <- rbind(polyy,polyx)
  }
  
  names(polyy) <- c("identifier","XCOOR","YCOOR")
  polyy$XCOOR <- as.numeric(as.character(polyy$XCOOR))
  polyy$YCOOR <- as.numeric(as.character(polyy$YCOOR))
  
  cat("Done.\n")
  
  cat("Converting points.\n")
  poly <- Cord2Polygon(polyy)
  cat("Done.\n")  
  
  if(class(x) == "spgeoOUT"){
    dum <- data.frame(identifier = x$identifier_in, x$species_coordinates_in)
    x <-dum
  }
  
  ini <- ReadPoints(x,poly)
  
  pp <- PipSamp(ini)
  spsum <- SpSumH(pp)
  
  pp <- spsum[, -1]
  pp[pp > 0] <- 1
  test <- data.frame((colSums(pp,na.rm = F)))
  test$identifier <- rownames(test)
  
  alle <- data.frame(identifier = unique(polyy$identifier))
  alle <- merge(alle, test, all = T)
  out <- matrix(alle[,2], ncol = xwidth, nrow = ywidth, byrow = T)
  
  
  out <- raster(out, xmn = xlim[1], xmx = xlim[2], ymn = ylim[1], ymx = ylim[2])
  projection(out)<-"+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0" 
  return(out)
}

AbundanceGrid<- function(x, xlim , ylim){
  res <- 1
  if(xlim[1] * xlim[2] <0){
    xwidth <- abs((xlim[2] + abs(xlim[1])) / res)
  }else{
    xwidth <- abs((abs(xlim[2]) - abs(xlim[1])) / res)
  }
  if(ylim[1] * ylim[2] <0){
    ywidth <- abs((ylim[2] + abs(ylim[1])) / res)
  }else{
    ywidth <- abs((abs(ylim[2]) - abs(ylim[1])) / res)
  }
  dimen <- xwidth * ywidth
  polyy <- data.frame()
  
  cat("Creating grid. \n")
  
  for(j in 0:(ywidth-1)){
    dimen2 <- j * (xwidth) +  (1:(xwidth))
    polyx <- data.frame()
    #     ylimd <- c(ylim[1] + res *j, ylim[1] + res * (j+1) )
    ylimd <- c(ylim[2] - res * j , ylim[2] - res * (j+1))
    
    for(i in 0:(xwidth-1)){
      poly <- rbind(c(xlim[1] + res * i, ylimd[2]), 
                    c(xlim[1] + res * (i+1), ylimd[2]),
                    c(xlim[1] + res * (i+1), ylimd[1]), 
                    c(xlim[1] + res * i, ylimd[1]),
                    c(xlim[1] + res * i, ylimd[2]))
      
      poly <- data.frame(cbind(as.character(rep(dimen2[i+1],5)),poly))
      polyx <- rbind(polyx,poly)
      #cat(paste(j, i, "\n"))
    }
    polyy <- rbind(polyy,polyx)
  }
  
  names(polyy) <- c("identifier","XCOOR","YCOOR")
  polyy$XCOOR <- as.numeric(as.character(polyy$XCOOR))
  polyy$YCOOR <- as.numeric(as.character(polyy$YCOOR))
  
  cat("Done.\n")
  
  cat("Converting points.\n")
  poly <- Cord2Polygon(polyy)
  cat("Done.\n")  
  
  if(class(x) == "spgeoOUT"){
    dum <- data.frame(identifier = x$identifier_in, x$species_coordinates_in)
    x <-dum
  }
  
  ini <- ReadPoints(x,poly)
  pp <- PipSamp(ini)
  
  
  sam <- aggregate(pp$identifier, by = list(pp$homepolygon), length)
  names(sam) <- c("identifier","num") 
  alle <- data.frame(identifier = unique(polyy$identifier))
  alle <- merge(alle, sam, all = T)
  out <- matrix(alle[,2], ncol = xwidth, nrow = ywidth, byrow = T)
  
  out <- raster(out, xmn = xlim[1], xmx = xlim[2], ymn = ylim[1], ymx = ylim[2])
  projection(out)<-"+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0" 
  return(out)
}

MapGrid <- function(rast){
  #   colo <- rev(heat.colors(length(getValues(rast))))
  plot(rast) #, col = colo)
  map("world", add = T)
  
}

MapDiversity <- function(x, scale = "CUSTOM", leg = "continuous", lim = "polygons", show.occ = F){
  if (!class(x) ==  "spgeoOUT"){
    stop("This function is only defined for class spgeoOUT")
  }
  
  num <- data.frame(poly = colnames(x$polygon_table),
                    spec.num = t(x$polygon_table),  
                    row.names = NULL, stringsAsFactors = F)
  num$poly <- gsub("."," ", num$poly, fixed = T)
  num$poly <- gsub("  "," ", num$poly, fixed = T)
  
  if(scale == "CUSTOM" ){
    if(class(x$polygons) == "SpatialPolygonsDataFrame" && "ECO_NAME" %in% names(x$polygons)){
      scale <- "ECOREGION"
    }else{
      x$polygons <- SpatialPolygonsDataFrame(x$polygons,data.frame(names(x$polygons), row.names = names(x$polygons)))
      names(x$polygons) <- c("ECO_NAME")
      nam <- data.frame(ECO_NAME = x$polygons$ECO_NAME)
    
      polys.df <- merge(nam, num, sort = F, by.x = "ECO_NAME", by.y = "poly", all = T)
    }    
  }
  if(scale == "REALM")
  {
    indrealm <- data.frame(string = c("Australasia", "Antarctic", 
                        "Afrotropics", "IndoMalay", 
                        "Nearctic", "Neotropics", 
                        "Oceania", "Palearctic"), 
                      REALM.ID = c("AA", "AN", "AT", "IM", "NA", "NT", "OC", "PA"))
    
    num <- merge(num,indrealm, by.x = "poly", by.y = "string")
    num <- num[,c(2,3)]
    
    nam <- data.frame(ECO_NAME = x$polygons$ECO_NAME,REALM_NAME = x$polygons$REALM)#diffrent
    
    
    polys.df <- merge(nam, num, sort = F, by.x = "REALM_NAME", by.y = "REALM.ID", all = T)
  }
  
  if(scale == "BIOME")
  {
    indbiom <- data.frame(string = c( "Tropical and Subtropical Moist Broadleaf Forests", 
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
                                      "Mediterranean Forests Woodlands and Scrub", 
                                      "Deserts and Xeric Shrublands", 
                                      "Mangroves"), BIOME.ID = c(1:14))
    
    num <- merge(num,indbiom, by.x = "poly", by.y = "string")
    num <- num[,c(2,3)]
    
    nam <- data.frame(ECO_NAME = x$polygons$ECO_NAME,BIOME_NAME = x$polygons$BIOME)#diffrent

    
    polys.df <- merge(nam, num, sort = F, by.x = "BIOME_NAME", by.y = "BIOME.ID", all = T) #
  }
  if(scale == "ECOREGION"){
    nam <- data.frame(ECO_NAME = x$polygons$ECO_NAME) 
    nam$ECO_NAME <- gsub("-"," ", nam$ECO_NAME, fixed = T)
    polys.df <- merge(nam, num, sort = F, by.x = "ECO_NAME", by.y = "poly", all = T)
  }
  
  polys.df$spec.num[is.na(polys.df$spec.num)] <- 0
  
  if(leg == "continuous"){
    colo <- data.frame(num = c(0:max(polys.df$spec.num)),
                       code = c("#FFFFFFFF", rev(heat.colors(max(polys.df$spec.num))))) 
    
  }else{
    colo <- data.frame(num = c(0,sort(unique(polys.df$spec.num))),
                       code = c("#FFFFFFFF", rev(rainbow(length(unique(polys.df$spec.num))))))
    if(colo$num[2] == 0){colo <- colo[-2,]}
  }
  
  polys.df <- merge(polys.df, colo, sort = F, by.x = "spec.num", by.y = "num", all = F)
  
  polys.df$ord <- pmatch(polys.df$ECO_NAME,nam$ECO_NAME)
  polys.df <- polys.df[order(polys.df$ord),]
  
  sp.count <-  polys.df$spec.num
  poly.col <- polys.df$code
  
  plotpoly <- spCbind(x$polygons, sp.count)
  plotpoly <- spCbind(plotpoly, poly.col)
  
  if(lim == "polygons"){
    limits <- bbox(plotpoly)
    if(limits[1,1] < -170 && limits[1,2] > 170 && max(x$species_coordinates$XCOOR) < -10){limits[1,2] <- -10}
    if(limits[1,1] < -170 && limits[1,2] > 170 && min(x$species_coordinates$XCOOR) > 0){limits[1,1] <- 0}
    limits[1,1] <-  max(limits[1,1] - abs(abs(limits[1,1])- abs(limits[1,2])) * .2, -180)
    limits[1,2] <-  min(limits[1,2] + abs(abs(limits[1,1])- abs(limits[1,2])) * .2, 180)
    limits[2,1] <-  max(limits[2,1] - abs(abs(limits[2,1])- abs(limits[2,2])) * .2, -90)
    limits[2,2] <-  min(limits[2,2] + abs(abs(limits[2,1])- abs(limits[2,2])) * .2, 90)
  }
  if(lim == "points"){
    limits <- matrix(ncol = 2, nrow = 2)
    limits[1,1] <-  max(min(x$species_coordinates_in$XCOOR) - 
                          abs(min(x$species_coordinates_in$XCOOR)- 
                                max(x$species_coordinates_in$XCOOR)) * .2, -180)
    limits[1,2] <-  min(max(x$species_coordinates_in$XCOOR) +
                          abs(abs(min(x$species_coordinates_in$XCOOR))- 
                                abs(max(x$species_coordinates_in$XCOOR))) * .2, 180)
    limits[2,1] <-  max(min(x$species_coordinates_in$YCOOR) - 
                          abs(min(x$species_coordinates_in$YCOOR)- 
                                max(x$species_coordinates_in$YCOOR)) * .2, -90)
    limits[2,2] <-  min(max(x$species_coordinates_in$YCOOR) +
                          abs(abs(min(x$species_coordinates_in$YCOOR))- 
                                abs(max(x$species_coordinates_in$YCOOR))) * .2, 90)
  }
  
  if(scale == "BIOME" | scale == "REALM") 
    {
    lin.col <- as.character(plotpoly$poly.col)
  }else{
    lin.col <- rgb(153,153,153, maxColorValue = 255, alpha = 255)
    } 
  if(length(unique(plotpoly$sp.count)) == 1){leg <- "discrete"}
  layout(matrix(c(1, 1, 1, 1, 1,  2), ncol =  6, nrow = 1))
  map("world", xlim = limits[1,], ylim = limits[2,])
  axis(1)
  axis(2)
  plot(plotpoly, col = as.character(plotpoly$poly.col), border = lin.col, add = T)
  if(show.occ == T){
  points(x$species_coordinates_in$XCOOR,x$species_coordinates_in$YCOOR)
  }
  box("plot")
  if(leg == "continuous"){
    par(mar = c(5,1,5,3))
        ifelse(max(plotpoly$sp.count) < 25, leng <- max(plotpoly$sp.count),leng <- 11)
    ticks <- round(seq(min(plotpoly$sp.count), max(plotpoly$sp.count), len = leng),0)
    scale <- (length(colo$num) - 1) / (max(plotpoly$sp.count) - min(plotpoly$sp.count))
    plot(c(0,10), c(min(plotpoly$sp.count),max(plotpoly$sp.count)), 
         type='n', bty='n', xaxt='n', xlab='', yaxt='n', ylab='')
    axis(4, ticks, las=1)
    for (i in 1:(length(colo$num))) {
      y = (i - 1)/scale + min(plotpoly$sp.count)
      rect(0, y, 10, y + 1 / scale, col= as.character(colo$code[i]), border=NA)
    }
    box("plot")
  }
  if(leg == "discrete"){
    par(mar = c(5,1,5,3))
    plot(c(0,10), c(min(colo$num),dim(colo)[1]+1), 
         type='n', bty='n', xaxt='n', xlab='', yaxt='n', ylab='', xpd = F)
    
    if(length(unique(plotpoly$sp.count)) == 1)
    {
      rect(0, (dim(colo)[1]+1)/2 -3 , 5, (dim(colo)[1]+1)/2 -1,  col= "white", border = "black")
      rect(0, (dim(colo)[1]+1)/2 +1 , 5, (dim(colo)[1]+1)/2 +3,  
           col= as.character(colo$code[unique(plotpoly$sp.count)]), border = NA)
      text(7, (dim(colo)[1]+1)/2 -2 , labels = "0")
      text(7, (dim(colo)[1]+1)/2 +2, labels = unique(plotpoly$sp.count))
    }else{    
      scale <- (length(colo$num) - 1) / (length(colo$num) - min(plotpoly$sp.count))
      for (i in 1:length(colo$num)) 
        {
        y = (i - 1)/scale + min(plotpoly$sp.count)
        rect(0, y, 5, y + 1 / scale, col= as.character(colo$code[i]), border=NA)
        text(8,y + 1 / scale / 2, colo$num[i])
        }
      rect(0,min(plotpoly$sp.count),5,length(colo$num)+ 1 / scale)
    }
  }
}

############################################################################################
#output functions
############################################################################################

WriteTablesSpGeo <- function(x, ...){
  if (class(x) ==  "spgeoOUT"){
    cat("Writing sample table: sample_classification_to_polygon.txt. \n")
    write.table(x$sample_table, file = "sample_classification_to_polygon.txt", sep = "\t", ...)
    cat("Writing species occurence table: species_occurences_per_polygon.txt. \n")
    write.table(x$spec_table, file = "species_occurences_per_polygon.txt", sep =  "\t", ...)
    cat("Writing species number per polygon table: speciesnumber_per_polygon.txt. \n")
    write.table(x$polygon_table, file = "speciesnumber_per_polygon.txt", sep = "\t", ...)
    cat("Writing table of unclassified samples: unclassified samples.txt. \n")
    write.table(x$not_classified_samples, file = "unclassified samples.txt", sep = "\t", ...)
    cat("Writing coexistence tables: species_coexistence_matrix.txt. \n")
    write.table(x$coexistence_classified, file = "species_coexistence_matrix.txt", sep = "\t", ...)
  }else{
    stop("This function is only defined for class spgeoOUT")
  }
}

PlotSpPoly <- function(x, ...){
  if (class(x) ==  "spgeoOUT") {
    num <- length(names(x$polygon_table))
    dat <- sort(x$polygon_table)
    counter <- num/10
    if (length(x$polygon_table) != 0){
      par(mar = c(10, 4, 2, 2))
      barplot(as.matrix(dat[1,]), 
              ylim = c(0, round((max(dat) + max(dat)/4), 0)), 
              ylab = "Number of Species per Polygon", las = 2, ...)
      box("plot")
    }else{
      cat("No point in any polygon")  
    }
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
  if(length(x$spec_table) == 0){
    cat("No point was found inside the given polygons")
  }else{
    if (plotout ==  FALSE){par(ask = T)}
    if (mode[1] ==  "total"){
      liste <- x$spec_table$identifier
      leng <-  length(liste)
      par(mar = c(10, 4, 3, 3))
      for(i in 1:leng){
        cat(paste("Creating barchart for species ", i, "/", leng, ": ", liste[i], "\n", sep = ""))
        spsub <- as.matrix(subset(x$spec_table, x$spec_table$identifier ==  liste[i])[, 2:dim(x$spec_table)[2]])
        if (sum(spsub) > 0){
          barplot(spsub, las = 2, ylim = c(0, (max(spsub) + max(spsub) / 10)), 
                  ylab = "Number of occurrences", ...)
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
        cat(paste("Creating barchart for species ", i, "/", leng, ": ", liste[i], "\n", sep = ""))
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
}

BarChartPoly <- function(x, plotout = F, ...){
  if (!class(x) ==  "spgeoOUT" && !class(x) ==  "spgeoH"){
    stop("This function is only defined for class spgeoOUT")
  }  
  if (plotout ==  FALSE){par(ask = T, mar = c(15, 4, 3, 3))}
  liste <- names(x$spec_table)
  leng <- length(liste)
  par(mar = c(15, 4, 3, 3))
  if(length(names(x$spec_table)) == 0){
    cat("No point fell in any polygon")
  }else{
    for(i in 2:leng){
      cat(paste("Creating barchart for polygon ", i-1, "/", leng, ": ", liste[i], "\n", sep = ""))
      subs <-subset(x$spec_table, x$spec_table[, i] > 0)
      datsubs <- subs[order(subs[, i]),]
      if(dim(subs)[1] == 0){
        plot(1:10,1:10,type = "n", xlab = "", ylab = "Number of occurences", )
        text(3,6, labels = "No species occurred in this polygon.", adj = 0)
        title(liste[i])
      }else{
       barplot(datsubs[, i], names.arg = datsubs$identifier, 
               las = 2, ylab = "Number of occurences",cex.names = .7)#, ...)
       title(liste[i])
      }
    }
  }
  par(ask = F)

}

HeatPlotCoEx <- function(x, ...){
  
  if (class(x) ==  "spgeoOUT" ){
    dat <- x$coexistence_classified
  }else{ 
    dat <- x
  }
  if(dim(dat)[1] > 40) {
    plot(c(1,10),c(1,10), type = "n", axes = F, xlab ="", ylab="")
    text(0,5, 
         label = "The Co-existence plot is only possible with less than 40 species.
         \n See species coexistence matrix for results.",adj = 0)
  }else{
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
      cat(paste("Ploting coexistence for species ", j, "/", xmax, ": ", colnames(dat)[j],"\n", sep = ""))
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
}

MapPerPoly <- function(x, scale, plotout = FALSE){
  if (!class(x) ==  "spgeoOUT"){
    stop("This function is only defined for class spgeoOUT")
  }
  dum <- x$polygons
  if(class(dum) == "SpatialPolygonsDataFrame")
    {
     if(scale == "ECOREGION"){liste1 <- liste2 <- unique(dum$ECO_NAME)}
     if(scale == "BIOME")
     {
       liste1  <- liste2 <- unique(dum$BIOME)
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
       for(i in 1: dim(indbiome)[1])
       {
         liste1[liste1 == indbiome[i,2]] <- indbiome[i,1]
       }
     }
     if(scale == "REALM")
     {
       liste1  <- liste2 <- as.character(unique(dum$REALM))
       indrealm <- cbind(c("Australasia", "Antarctic", 
                           "Afrotropics", "IndoMalay", 
                           "Nearctic", "Neotropics", 
                           "Oceania", "Palearctic"), 
                         c("AA", "AN", "AT", "IM", "NA", "NT", "OC", "PA"))
       for(i in 1: dim(indrealm)[1])
       {
         liste1[liste1 == indrealm[i,2]] <- indrealm[i,1]
       }
     }   
     len <- length(liste1)
  }else{
    len <- length(names(dum))
  }
    for(i in 1:len){
      if(class(dum) == "SpatialPolygonsDataFrame"){
        cat(paste("Creating map for polygon ", i,"/",length(liste1), ": ", liste1[i], "\n",sep = ""))
        chopo <- liste1[i]
        if(scale == "ECOREGION")
        {
          xmax <- min(max(bbox(subset(dum,dum$ECO_NAME == liste1[i]))[1, 2]) + 5, 180)
          xmin <- max(min(bbox(subset(dum,dum$ECO_NAME == liste1[i]))[1, 1]) - 5, -180)
          ymax <- min(max(bbox(subset(dum,dum$ECO_NAME == liste1[i]))[2, 2]) + 5, 90)
          ymin <- max(min(bbox(subset(dum,dum$ECO_NAME == liste1[i]))[2, 1]) - 5, -90)
        }
        if(scale == "BIOME")
        {
          xmax <- min(max(bbox(subset(dum,dum$BIOME == liste2[i]))[1, 2]) + 5, 180)
          xmin <- max(min(bbox(subset(dum,dum$BIOME == liste2[i]))[1, 1]) - 5, -180)
          ymax <- min(max(bbox(subset(dum,dum$BIOME == liste2[i]))[2, 2]) + 5, 90)
          ymin <- max(min(bbox(subset(dum,dum$BIOME == liste2[i]))[2, 1]) - 5, -90)
        }
        if(scale == "REALM")
        {
          xmax <- min(max(bbox(subset(dum,dum$REALM == liste2[i]))[1, 2]) + 5, 180)
          xmin <- max(min(bbox(subset(dum,dum$REALM == liste2[i]))[1, 1]) - 5, -180)
          ymax <- min(max(bbox(subset(dum,dum$REALM == liste2[i]))[2, 2]) + 5, 90)
          ymin <- max(min(bbox(subset(dum,dum$REALM == liste2[i]))[2, 1]) - 5, -90)
        }
          
       }else{
        cat(paste("Creating map for polygon ", i,"/",length(names(dum)), ": ", names(dum)[i], "\n",sep = ""))
        chopo <- names(dum)[i]

        xmax <- min(max(bbox(x$polygons[i])[1, 2]) + 5, 180)
        xmin <- max(min(bbox(x$polygons[i])[1, 1]) - 5, -180)
        ymax <- min(max(bbox(x$polygons[i])[2, 2]) + 5, 90)
        ymin <- max(min(bbox(x$polygons[i])[2, 1]) - 5, -90)
       }
      
        
    po <- data.frame(x$sample_table, x$species_coordinates_in)
    subpo <- subset(po, as.character(po$homepolygon) ==  as.character(chopo))
    
    subpo <- subpo[order(subpo$identifier), ]  
    
    liste <- unique(subpo$identifier)
    leng <- length(liste)

    rain <- rainbow(leng)
    ypos <- vector(length = leng)
    yled <- (ymax - ymin) * 0.025
    for(k in 1:leng){
      ypos[k]<- ymax - yled * k
    }
    
    layout(matrix(c(1, 1, 1, 1,1, 2, 2), ncol =  7, nrow = 1))
    par(mar = c(3, 3, 3, 0))
    te <-try(map("world", xlim = c(xmin, xmax), ylim = c(ymin, ymax)), silent = T)
    if(class(te) == "try-error"){map("world")}
    axis(1)
    axis(2)
    box("plot")
    title(chopo)
    if(class(dum) == "SpatialPolygonsDataFrame")
      {
        if(scale == "ECOREGION"){plot(subset(dum,dum$ECO_NAME == liste1[i]), col = "grey60", add = T)}
        if(scale == "BIOME"){plot(subset(dum,dum$BIOME == liste2[i]), col = "grey60", add = T)}
        if(scale == "REALM"){plot(subset(dum,dum$REALM == liste2[i]), col = "grey60", add = T)}
      }else{
      plot(x$polygons[i], col = "grey60", add = T)
      }
    for(j in 1:leng){
      subsub <- subset(subpo,subpo$identifier == liste[j]) 
      points(subsub[,3], subsub[,4], 
             cex = 1, pch = 3 , col = rain[j])
      }
    #legend
    cat("Adding legend \n")
    par(mar = c(3, 0, 3, 0), ask = F)
    plot(c(1, 50), c(1, 50), type = "n", axes = F)
    if(leng == 0){
      yset <- 25
      xset <- 1}
    if (leng ==  1){
      yset <- 25
      xset <- rep(4, leng)
    }
    if(leng >  1){
      yset <- rev(sort(c(seq(25, 25 + max(ceiling(leng/2) - 1, 0)), 
                         seq(24, 24 - leng/2 + 1))))
      xset <- rep(4, leng)
    }
    points(xset-2, yset, pch =  3, col = rain)
    if(leng == 0){
      text(xset, yset, labels = "No species found in this polygon", adj = 0)
    }else{
      text(xset, yset, labels =  liste, adj = 0, xpd = T)
      rect(min(xset) - 4, min(yset) -1, 50 + 1, max(yset) + 1, xpd = T)
    }
    
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
  names(dat) <- c("identifier","XCOOR","YCOOR")
  liste <- levels(dat$identifier)
    
  for(i in 1:length(liste)){
    cat(paste("Mapping species: ", i, "/", length(liste), ": ", liste[i], "\n",sep = ""))
    kk <- subset(dat, dat$identifier ==  liste[i])

    inside <- kk[!is.na(kk$homepolygon),]
    outside <- kk[is.na(kk$homepolygon),]
    
    xmax <- min(max(dat$XCOOR) + 2, 180)
    xmin <- max(min(dat$XCOOR) - 2, -180)
    ymax <- min(max(dat$YCOOR) + 2, 90)
    ymin <- max(min(dat$YCOOR) - 2, -90)
    
    map ("world", xlim = c(xmin, xmax), ylim = c(ymin, ymax))
    axis(1)
    axis(2)
    title(liste[i])
    if (moreborders == T) {plot(wrld_simpl, add = T)}
    plot(x$polygons, col = "grey60", add = T)
    
    if(length(inside) > 0){
      points(inside$XCOOR, inside$YCOOR, 
             cex = 0.7, pch = 3 , col = "blue")
    }
    if(length(outside) >0){
      points(outside$XCOOR, outside$YCOOR, 
             cex = 0.7, pch = 3 , col = "red")
    }
    box("plot")
  }
  par(ask = F)
}

MapAll <- function(x, polyg, moreborders = F, ...){
  data(wrld_simpl)
  if (class(x) ==  "spgeoOUT"){
    xmax <- min(max(x$species_coordinates_in[, 1]) + 2, 180)
    xmin <- max(min(x$species_coordinates_in[, 1]) - 2, -180)
    ymax <- min(max(x$species_coordinates_in[, 2]) + 2, 90)
    ymin <- max(min(x$species_coordinates_in[, 2]) - 2, -90)
    difx <- sqrt(xmax^2 + xmin^2)
    dify <- sqrt(ymax^2 + ymin^2)  
    if(difx > 90){
      xmax <- min(xmax +10, 180)
      xmin <- max(xmin -10,-180)
      ymax <- min(ymax +10, 90)
      ymin <- max(ymin -10,-90)
    }
    cat("Creating map of all samples. \n")
    map ("world", xlim = c(xmin, xmax), ylim = c(ymin, ymax))
    axis(1)
    axis(2)
    box("plot")
    title("All samples")
    if (moreborders ==  T) {plot(wrld_simpl, add = T)}
    cat("Adding polygons. \n")
    plot(x$polygons, col = "grey60", border = "grey40", add = T, ...)
    cat("Adding sample points \n")
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
    xmax <- min(max(x[, 2]) + 2, 180)
    xmin <- max(min(x[, 2]) - 2, -180)
    ymax <- min(max(x[, 1]) + 2, 90)
    ymin <- max(min(x[, 1]) - 2, -90)
    if (ymax > 92 || ymin < -92){
      warning("Column order must be lon-lat, not lat - lon. Please check")
    }
    map ("world", xlim = c(xmin, xmax), ylim = c(ymin, ymax))
    axis(1)
    axis(2)
    title("All samples")
    box("plot")
    if (moreborders ==  T) {plot(wrld_simpl, add = T, ...)}
    if(class(polyg == "list"))

      plot(polyg, col = "grey60", add = T, ...)

    points(x[, 2], x[, 1], 
           cex = 0.5, pch = 3 , col = "blue", ...)
    
  }
}

MapUnclassified <- function(x, moreborders = F, ...){
  if (!class(x) ==  "spgeoOUT"){
    stop("This function is only defined for class spgeoOUT")
  }
  dat <- data.frame(x$not_classified_samples)
  if (dim(dat)[1] ==  0){
    plot(c(1:20), c(1:20), type  = "n", axes = F, xlab = "", ylab = "")
    text(10, 10, labels = paste("All points fell into the polygons and were classified.\n", 
                                "No unclassified points", sep = ""))
  }else{
    xmax <- min(max(dat$XCOOR) + 2, 180)
    xmin <- max(min(dat$XCOOR) - 2, -180)
    ymax <- min(max(dat$YCOOR) + 2, 90)
    ymin <- max(min(dat$YCOOR) - 2, -90)
    
    cat("Creating map of unclassified samples. \n")
    map ("world", xlim = c(xmin, xmax), ylim = c(ymin, ymax), ...)
    axis(1)
    axis(2)
    title("Samples not classified to polygons \n")
    if (moreborders == T) {plot(wrld_simpl, add = T)}
    cat("Adding polygons \n")
    if(class(x$polygons) == "list"){
      plota <- function(x){plot(x, add = T, col = "grey60", border = "grey40")}
      lapply(x$polygons, plota)
    }else{
      plot(x$polygons, col = "grey60", border = "grey40", add = T, ...)
    }
    cat("Adding sample points \n")
    points(dat$XCOOR, dat$YCOOR, 
           cex = 0.5, pch = 3 , col = "red", ...)
    box("plot")
  }
}  

NexusOut <- function (x, verbose = F){
  cat("Writing Nexus file \n")
  if(verbose == F){
    sink("species_classification.nex")
  }
  if(verbose == T){
    sink("species_classification_verbose.nex")
  }
  
  cat("#NEXUS \n")
  cat("\n")
  cat("Begin data; \n")
  cat(paste("\tDimensions ntax=",dim(x$spec_table)[1], 
            " nchar=", dim(x$spec_table)[2] - 1,";", sep = ""))
  cat("\n")
  cat("\tFormat datatype=standard symbols=\"01\" gap=-;")
  cat("\n")
  cat("\tCHARSTATELABELS")
  cat("\n")
  if(length(x$spec_table) == 0){
    cat("No point fell in any of the polygons specified")
    sink(NULL)
  }else{
  aa <- names(x$spec_table)[-1]
  bb <- seq(1,length(aa))
  
  cat(paste("\t", bb[-length(bb)], " ",aa[-length(aa)], ",\n", sep = ""))
  cat("\t", paste(bb[length(bb)], " ", aa[length(aa)], ";\n", sep = ""))
  cat("\n")
  cat("\tMatrix\n")
  
  dd <- as.matrix(x$spec_table[,-1])
  dd[dd > 0] <- 1
  
  if(dim(dd)[2] >1)
  {
  dd <- data.frame(dd)
  dd$x <- apply(dd[, names(dd)], 1, paste, collapse = "")
  }else{
    dd <- data.frame(dd,x = dd)
  }
  ff <- gsub(" ", "_",x$spec_table[,1])
  
  if(verbose == F)
  {
    ee <- paste(ff, "\t" ,dd$x, "\n",sep = "")
    cat(ee)
  }
  if(verbose == T){
    gg <- vector()
    jj <-x$spec_table[,-1]
    for( i in 1:dim(jj)[2])
    {
      hh <- paste(dd[,i],"[", jj[,i],"]", sep = "")
      gg <- data.frame(cbind(gg, hh))
    } 
    gg$x <- apply(gg[, names(gg)], 1, paste, collapse = "")
    ee <- paste(ff, "\t", gg$x, "\n", sep = "")
    cat(ee)
  }
  cat("\t;\n")
  cat("End;")
  sink(NULL)
  }
  cat("Done")
}

OutMapAll <- function(x, ...){
  cat("Creating overview map: map_samples_overview.pdf. \n")
  pdf(file = "map_samples_overview.pdf", paper = "special", width = 10.7, height = 7.2, onefile = T, ...)
  MapAll(x, ...)
  MapUnclassified(x, ...)
  dev.off()
}

OutMapPerPoly <- function(x, ...){
  cat("Creating map per polygon: map_samples_per_polygon.pdf. \n")
  pdf(file = "map_samples_per_polygon.pdf", paper = "special", width = 10.7, height = 7.2, onefile = T)
  MapPerPoly(x,scale = scale, plotout = T)
  dev.off()
}

OutMapPerSpecies <- function(x){
  cat("Creating map per species: map_samples_per_species.pdf. \n")
  pdf(file = "map_samples_per_species.pdf",paper = "special", width = 10.7, height = 7.2, onefile = T)
  MapPerSpecies(x, plotout = T)
  dev.off()
}

OutBarChartSpec <- function(x, ...){
  cat("Creating barchart per species: barchart_per_species.pdf. \n")
  pdf(file = "barchart_per_species.pdf", paper = "special", width = 10.7, height = 7.2, onefile = T)
  BarChartSpec(x, plotout = T, mode = "percent", ...)
  dev.off()
}

OutBarChartPoly <- function(x, ...){
  cat("Creating barchart per polygon: barchart_per_polygon.pdf. \n")
  pdf(file = "barchart_per_polygon.pdf",paper = "special", width = 10.7, height = 7.2, onefile = T)
  BarChartPoly(x, plotout = T, cex.axis = .8, ...)
  dev.off()
}

OutHeatCoEx <- function(x, ...){
  cat("Creating coexistence heatplot: heatplot_coexistence.pdf. \n")
  pdf(file = "heatplot_coexistence.pdf",paper = "special", width = 10.7, height = 7.2, onefile = T)
  HeatPlotCoEx(x, ...)
  dev.off()
}

OutPlotSpPoly <- function(x, ...){
  cat("Creating species per polygon barchart: number_of_species_per_polygon.pdf. \n")
  pdf(file = "number_of_species_per_polygon.pdf",paper = "special", width = 10.7, height = 7.2, onefile = T)
  PlotSpPoly(x, ...)
  dev.off()
}

SpeciesGeoCoder <- function(x, y, coex = F, graphs = T, wwf = F, scale, ...){
  ini <- ReadPoints(x, y)
  
  outo <- SpGeoCodH(ini)

  if(wwf == T){
    
    outo <- clust(outo, shape = y,scale = scale)
  }
    
  WriteTablesSpGeo(outo)
  NexusOut(outo,...)
    
  if(graphs == T && wwf == F){
    OutPlotSpPoly(outo, ...)
    OutBarChartPoly(outo, ...)
    OutBarChartSpec(outo, ...)
    OutMapAll(outo, ...)
    OutMapPerSpecies(outo, ...)
    OutMapPerPoly(outo, ...)
  }
  if(graphs == T && wwf == T){
    OutPlotSpPoly(outo, ...)
    OutBarChartPoly(outo, ...)
    OutBarChartSpec(outo, ...)
    OutMapAll(outo, ...)
    OutMapPerSpecies(outo, ...)
    OutMapPerPoly(outo, scale = scale, ...)
  }
  
  if(coex == T)
    {
    outo <- CoExClass(outo)
    OutHeatCoEx(outo)
    }
}


