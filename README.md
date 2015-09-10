### What is SpeciesGeoCoder?

SpeciesGeoCoder is a free software package for coding species occurrences into user-defined units for e.g. biogeographic analyses. The background and goals of the package are described in the following pre-print: http://biorxiv.org/content/early/2014/09/17/009274

### Which versions are available?

1. The one available here and written in Python 
1. A web interface that allows the analysis of data online: https://portal.bils.se/tools/speciesgeocoder
1. A similar package written solely in R: https://cran.rstudio.com/web/packages/speciesgeocodeR/

### More details

SpeciesGeoCoder utilises the GDAL library (http://www.gdal.org/) for fast analysis of geoTIFF files, which allows for the easy and fast coding of species into user-defined operational units. These units may be of any size and be purely spatial (i.e., polygons) such as political units (countries, states), conservation areas, realms, biomes, ecoregions, islands, biodiversity hotspots, and areas of endemism; but they may also be defined as a combination of several criteria, including altitudinal ranges. This flexibility allows scoring species into complex categories, such as those encountered in topographically and ecologically heterogeneous landscapes. The various outputs of SpeciesGeoCoder include quantitative biodiversity statistics, global and local distribution maps, and Nexus files that can be directly used in many phylogeny-based applications for ancestral state reconstruction, investigations on biome evolution, and diversification rate analyses. 

## For the impatient 
Download the latest version from https://github.com/mtop/speciesgeocoder/releases
```bash
unzip speciesgeocoder-x.x.x.zip
cd speciesgeocoder-x.x.x
./geocoder.py -l example_data/localities.csv -p example_data/polygons.txt -t example_data/*.tif
```

For further instructions on how to install and run the program, please see the [wiki.](https://github.com/mtop/speciesgeocoder/wiki)


