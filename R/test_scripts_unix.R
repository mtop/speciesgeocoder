#dataset fernanda

setwd("C:\Users\xzizal\Desktop\GitHub\geocoder\R\example_files\Example_1_data_fernanda")

#all in one
SpeciesGeoCoder("fernanda_coords_ano.txt","test_polygons.txt")

#step by step
test <- ReadPoints("fernanda_coords_ano.txt","test_polygons3.txt")
test2 <- SpGeoCod("fernanda_coords_ano.txt","test_polygons3.txt")


#Gentianales klein
setwd("C:/Users/xzizal/Desktop/GitHub/geocoder/R/example_files/Example_2_gentianales_klein")

#all in one
SpeciesGeoCoder("speciesindataset_R.txt","realmpoly_R.txt")

#step by step
test <- ReadPoints("speciesindataset_R.txt","realmpoly_R.txt")
test2 <- SpGeoCod("speciesindataset_R.txt","realmpoly_R.txt")
test2 <- CoExClass(test2)


#Gentianales gross
setwd("C:/Users/xzizal/Desktop/GitHub/geocoder/R/example_files/Example_3_gentianales_large")


SpeciesGeoCoderlarge("allgentianales4_R.txt","realmpoly_R.txt")

test <- ReadPoints("allgentianales4_R.txt","realmpoly_R.txt")
test2 <- SpGeoCod("allgentianales4_R.txt","realmpoly_R.txt")

aa <- PipSamp(test)
bb <- SpSumH(aa)

dd <- SpSum(test)
ee <- SpPerPolH(bb)
ff <- CoExClassH(bb)

gg <- SpPerPol(test)

gg <- SpGeoCodH(test)

BarChartPoly(test2)

MapPerPoly(test2)
MapPerSpecies(test2)

OutMapPerSpecies(test2)

wwf <- readShapeSpatial("C:/Users/xzizal/Dropbox/Arbeit/Gothenburg/other_researchers/Fernanda/wwf_ecoregions/wwf_terr_ecos.shp")
