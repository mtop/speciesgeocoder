pkload <- function(x)
{
  if (!require(x,character.only = TRUE, quietly = T))
  {
    install.packages(x,dep=TRUE, quiet = T)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}

pkload("optparse")

parser_object <- OptionParser(usage = "Usage: %prog [Working directory] [occurences.sgc.txt] [polygons.sgc.txt] [sampletable.sgc.txt] [speciestable.sgc.txt]", 
                              description="")
opti <- parse_args(parser_object, args = commandArgs(trailingOnly = TRUE), positional_arguments = 5)

wd <- opti$args[1]
setwd(wd)

source("SpeciesGeoCodeR.R")

python_out <- GetPythonIn(c(opti$args[2],opti$args[3], opti$args[4], opti$args[5]))

#possibly insert cutoff values here
WriteTablesSpGeo(python_out)
NexusOut(python_out)
OutPlotSpPoly(python_out)
OutBarChartPoly(python_out)
OutBarChartSpec(python_out)
OutMapAll(python_out) 

if(dim(python_out$sample_table)[1] == dim(python$species_coordinates_in)){
  OutMapPerSpecies(lala)
  OutMapPerPoly(lala)
}else{
  warning("SpeciesGeocoder maps currently do not support overlapping polygons. No maps created."
}
