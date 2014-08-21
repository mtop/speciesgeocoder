pkload <- function(x)
{
  if (!require(x,character.only = TRUE, quietly = T))
  {
    install.packages(x,dep=TRUE, quiet = T, repos='http://cran.us.r-project.org')
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}

pkload("optparse")

parser_object <- OptionParser(usage = "Usage: %prog [Working directory] [occurences.sgc.txt] [polygons.sgc.txt] [sampletable.sgc.txt] [speciestable.sgc.txt]", 
                              description="")
opti <- parse_args(parser_object, args = commandArgs(trailingOnly = TRUE), positional_arguments = 5)

#__ GUI STUFF
source(paste(opti$args[1],"/R/SpeciesGeoCodeR.R",sep=""))

#__ GUI STUFF
wd <- opti$args[6]
setwd(wd)


python_out <- GetPythonIn(c(opti$args[2],opti$args[3], opti$args[4], opti$args[5]))
save(python_out, file = "python_out.Rdata")

#possibly insert cutoff values here
WriteTablesSpGeo(python_out)
OutPlotSpPoly(python_out)
OutBarChartPoly(python_out)
OutBarChartSpec(python_out)
OutMapAll(python_out) 
OutMapPerSpecies(python_out)
OutMapPerPoly(python_out)

if(length(unique(python_out$identifier_in)) < 41) {
  coextab <- CoExClassH(python_out$spec_table)
  OutHeatCoEx(coextab)
}



