
For tests, (short version, long will follow)

Input-files: 
The input files must be tab-delimited .txt files with three columns each. In the point coordinates file the first column should contain the species name,
 the second the longitude coordinates (as decimal degrees, e.g. 59.8677546 for East, or -59.8677546 for West) and the third column should be latitude 
(as decimal degrees, e.g. 59.8677546 for North, or -59.8677546 for South). The polygon file should have a similar format: the first column contains the polygon identifier,
 the second one the longitude coordinates, the third one the latitude coordinates for each point.
 It is important that the coordinates of the first and the last point of each polygon are identical.
 You can easily export such a file from a polygon drawn in any GIS program (e.g. QGIS: http://www.qgis.org/en/site/).


Especially designed for R beginners, the speciesgeocoder package allows the easy production of a set of standard outputfiles directly from the 2 text input files, with the use of only 6 steps. 
If you are not familiar with R you can copy the R code (the text after “>”) from this file to the R console.

1. Create a new folder in your home directory (the working directory). 
Copy the speciesgeocoder package (speciesgeocodeR.R) and your two input files into the folder and give them characteristic names 
(here we will use “point_coordinates.txt” for our point coordinates and “polygon_coordinates.txt” for the polygon coordinates). 
If you are insecure about the format of your input files or an error occurs right away, check the paragraph on the inputfiles above or look at the example files delivered with the package.

2. Start R

3. Tell R where to find the input files and save the outputfiles. You must put the exact path of the folder in the quotation marks. 
If you use linux use / instead of \\:

>setwd(“C:\\Users\\Desktop\\speciesgeocodeR”)

4.Load the functions of the speciesgeocoder package into your R session:

>source(“speciesgeocoder.R”)

5. Execute the SpeciesGeoCoder function with the names of your two input files as arguments. Depending on the size of your dataset (especially the number of polygons) this might take a while:

>SpeciesGeoCoder(“point_coordinates.txt”,“polygon_coordinates.txt”)

6 Close R, the outputfiles are in your working directory. Tables as tab-delimited .txt files, graphs and maps as .pdf files. 

7. Done! If problems occur, try using one of the example datasets delivered with the package or going through the functions step by step as descriped below.
