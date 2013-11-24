The R function to get the python input is currently the following:
GetPythonIn(coordinates, polygon, sampletable, speciestable)

The easiest way to produce the graphical output from python-derived input is:

1. Copy the R library to your working directory

2. Start R

3. Set your working directory
>setwd(“path_of_your_working_directory”) #set your working directory

4. Load the R functions from the source file, this should also install the dependencies
>source(“speciegeocodeR.R”) 

5. Get the results from the python code, and put them in an object of the class “spgeoOUT”
>dummy <- GetPythonIn(coordinates, polygon, sampletable, speciestable) 

coordinates = a table of the input point coordinates, with 3 columns in the following order: identifier (character), YCOOR (numeric), XCOOR (numeric)
polygon = a table of the input points for the polygons with three columns in the following order: identifier (polygonname, character), XCOOR (numeric), YCOOR (numeric))
sampletable = a table with 2 columns, in the following order, with the following haeders: identifier(sample name, character), homepolygon (name of the polygon the sample was classified to, character)
speciestable = a table with ncol = n Polygons and nrow = number species; summarizing the number of occurences per species per polygon

6. Write the output tables from the spgeoOUT object
>WriteTablesSpGeo(dummy) #write tables from spgeoOUT object

7 Write the graphs from the spgeoOut object
>PlotOutSpGeo(dummy) #produce plots from spgeoOUT objects

5. Close R. The output files should now be in the working directory.
