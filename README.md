geocoder
========

SpeciesGeoCoder is an open-source software package written in Python and R, that utilise the GDAL library (http://www.gdal.org/) for fast analysis of geoTIFF files, which allows for the easy and fast coding of species into user-defined operational units. These units may be of any size and be purely spatial (i.e., polygons) such as political units (countries, states), conservation areas, realms, biomes, ecoregions, islands, biodiversity hotspots, and areas of endemism; but they may also be defined as a combination of several criteria, including altitudinal ranges. This flexibility allows scoring species into complex categories, such as those encountered in topographically and ecologically heterogeneous landscapes. The various outputs of SpeciesGeoCoder include quantitative biodiversity statistics, global and local distribution maps, and Nexus files that can be directly used in many phylogeny-based applications for ancestral state reconstruction, investigations on biome evolution, and diversification rate analyses. 

Input:  See the example files localities.txt and polygons.txt.
Output: See the example file ivesioids_out.nex.

================================================================
The program provides a number of options that can be viewed by 
running it with the "--help" option.

mats@Slartibartfasts:~/git/geocoder$ geocoder.py --help
usage: geocoder.py [-h] [-p POLYGONS] [-l LOCALITIES] [-g GBIF]
                   [-t [TIF [TIF ...]]] [-v] [-b] [-n [NUMBER [NUMBER ...]]]
                   [--test]

optional arguments:
  -h, --help            show this help message and exit
  -p POLYGONS, --polygons POLYGONS
                        Path to file containing polygon coordinates
  -l LOCALITIES, --localities LOCALITIES
                        Path to file containing species locality data
  -g GBIF, --gbif GBIF  Path to file containing species locality data
                        downloaded from GBIF
  -t [TIF [TIF ...]], --tif [TIF [TIF ...]]
                        Path to geotiff file(s)
  -v, --verbose         Also report the number of times a species is found in
                        a particular polygon
  -b, --binomial        Treats first two words in species names as genus name
                        and species epithet. Use with care as this option is
                        LIKELY TO LEAD TO ERRONEOUS RESULTS if names in input
                        data are not in binomial form.
  -n [NUMBER [NUMBER ...]], --number [NUMBER [NUMBER ...]]
                        Minimum number of occurences in a polygon. The number
                        of excluded localities will be reported by default
  --test                Test if the imput data is in the right format
