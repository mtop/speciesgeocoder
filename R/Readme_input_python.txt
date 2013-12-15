#This is a Readme for Mats on which functions must be called for the graphical and .txt file output via R

setwd("path of the working directory") #where the source file is and the output should go
|
source("speciesgeocodeR.R") #I could not figure out how to avoid the explicit use of these two functions
|
dummy <- GetPythonIn(coordinates, polygon, sampletable, speciestable)  #gather data from python into format / class expected by other functions coordinates = a table of the input point coordinates, with 3 tab delimited columns in the following order: identifier (character), YCOOR (numeric), XCOOR (numeric)
polygon = a table of the input points for the polygons with three tab delimitedcolumns in the following order: identifier (polygonname, character), XCOOR (numeric), YCOOR (numeric))
sampletable = a table with 2 tab delimited columns, in the following order, with the following haeders: identifier(sample name, character), homepolygon (name of the polygon the sample was classified to, character)
speciestable = a table (tab delimited) with ncol = n Polygons and nrow = number species; summarizing the number of occurences per species per polygon. I could not exactly figure out how these files must be seperated, probably a comma.
|
dummy <- CoExClass(dummy)	#cutoff = 500 species in dataset;calculates coexistence matrix
|
WriteTablesSpGeo(dummy) #write result into tab-delimited .txt files, as tables
|
OutPlotSpPoly(dummy) no cutoff; barchart on species numbers per polygon#
|
OutBarChartPoly(dummy) # cutoff = 45 polygons per species; cutoff should maybe be calculated for each polygon seperately!; barchart of species abundance per polygon
|
OutBarChartSpec(dummy) # cutoff = 45 species in the polygon; cutoff should maybe be calculated for each species seperately; barchart of species distribution on different polygons
|
OutMapAll(dummy) # no cutoff, maps all samples and all polygons for overview
|
OutMapPerSpecies(dummy) #cutoff = 370 species ?? polygons, maps polygons per species
|
OutMapPerPoly(dummy) #cutoff = 55 species in the polygon, maps species per polygon 
|
OutHeatCoEx(dummy) # cutoff = 40 species; creates the heatplot for the coexistence matrix
