### This is a Readme for Mats on which functions must be called for the graphical and .txt file output via R

setwd("path of the working directory") # Where the source file is and the output should go
|
source("speciesgeocodeR.R") # I could not figure out how to avoid the explicit use of these two functions
|
dummy <- GetPythonIn(coordinates, polygon, sampletable, speciestable)  # Gather data from python into format / class expected by other functions 

Rcoordinates.txt =	a table of the input point coordinates, with three tab 
					delimited columns in the following order: 
					identifier (character) 
					YCOOR (numeric)
					XCOOR (numeric)

Rpolygons.txt = 	a table of the input points for the polygons with three 
					tab delimitedcolumns in the following order: 
					identifier (polygonname, character)
					XCOOR (numeric) 
					YCOOR (numeric)

Rsampletable.txt = 	a table with two tab delimited columns, in the following 
					order, and the following haeders: 
					identifier(sample name, character)
					homepolygon (name of the polygon the sample was classified to, character)

Rspeciestable.txt = a table (tab delimited) with ncol = n Polygons and nrow = number species; 
					summarizing the number of occurences per species per polygon. 
					I could not exactly figure out how these files must be seperated, probably a comma.
|
dummy <- CoExClass(dummy)	# cutoff = 500 species in dataset;calculates coexistence matrix
							# MT: If less that 500 species in dataset, run this function.
|
WriteTablesSpGeo(dummy) # write result into tab-delimited .txt files, as tables
|
OutPlotSpPoly(dummy) 	# no cutoff; barchart on species numbers per polygon
|
OutBarChartPoly(dummy) 	# cutoff = 45 polygons per species.
						# cutoff should maybe be calculated for each polygon seperately!
						# barchart of species abundance per polygon
						# MT: If one species exists in more than 45 polygons, DON'T run this.
|
OutBarChartSpec(dummy) 	# cutoff = 45 species in the polygon.
						# cutoff should maybe be calculated for each species seperately.
						# barchart of species distribution on different polygons.
						# MT: If one species exists in more than 45 polygons, DON'T run this.
|
OutMapAll(dummy) 		# no cutoff, maps all samples and all polygons for overview
|
OutMapPerSpecies(dummy) # polygons, maps polygons per species
						# One PDF file with one page per species.
|
OutMapPerPoly(dummy) 	# cutoff = 55 species in the polygon, maps species per polygon 
						# One PDF file with one page per polygon.
						# If more that 55 species in a polygon Don't run this.
|
OutHeatCoEx(dummy) 		# cutoff = 40 species; creates the heatplot for the coexistence matrix
						# If more that 40 species in the analysis, Don't run this.
