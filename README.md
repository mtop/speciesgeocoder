# SpeciesGeoCoder

SpeciesGeoCoder is an open-source software package written in Python and R, that utilise the GDAL library (http://www.gdal.org/) for fast analysis of geoTIFF files, which allows for the easy and fast coding of species into user-defined operational units. These units may be of any size and be purely spatial (i.e., polygons) such as political units (countries, states), conservation areas, realms, biomes, ecoregions, islands, biodiversity hotspots, and areas of endemism; but they may also be defined as a combination of several criteria, including altitudinal ranges. This flexibility allows scoring species into complex categories, such as those encountered in topographically and ecologically heterogeneous landscapes. The various outputs of SpeciesGeoCoder include quantitative biodiversity statistics, global and local distribution maps, and Nexus files that can be directly used in many phylogeny-based applications for ancestral state reconstruction, investigations on biome evolution, and diversification rate analyses. 

Input:  See the example files localities.txt and polygons.txt.

Output: See the example file ivesioids_out.nex.

================================================================
The program provides a number of options that can be viewed by 
using the "--help" option.

```
topel@Slartibartfasts:~/git/speciesgeocoder-master$ ./geocoder.py -h
usage: speciesgeocoder [-h] -p POLYGONS (-l LOCALITIES | -g GBIF)
                       [-t [TIF [TIF ...]]] [--plot] [--stochastic_mapping]
                       [--tree TREE] [--m_out M_OUT] [--n_rep N_REP]
                       [--map_model {ER,SYM,ARD}]
                       [--max_run_time MAX_RUN_TIME] [--trait TRAIT] [-v] [-b]
                       [-n [NUMBER [NUMBER ...]]] [--test]
                       [--dir_output DIR_OUTPUT]

optional arguments:
  -h, --help            show this help message and exit
  -p POLYGONS, --polygons POLYGONS
                        Set path to file containing polygon coordinates
  -l LOCALITIES, --localities LOCALITIES
                        Set path to file containing species locality data
  -g GBIF, --gbif GBIF  Set path to file containing species locality data
                        downloaded from GBIF
  -t [TIF [TIF ...]], --tif [TIF [TIF ...]]
                        Set path to geotiff file(s)
  --plot                Produce graphical output illustrating coexistance,
                        distribution etc.
  -v, --verbose         Report how many times a species is found in each
                        polygon
  -b, --binomial        Treats first two words in species names as genus name
                        and species epithet. Use with care as this option is
                        LIKELY TO LEAD TO ERRONEOUS RESULTS if names in input
                        data are not in binomial form.
  -n [NUMBER [NUMBER ...]], --number [NUMBER [NUMBER ...]]
                        Set the minimum number of occurrences (localities)
                        needed for considering a species to be present in a
                        polygon
  --test                Test if the input data is in the right format
  --dir_output DIR_OUTPUT
                        Output directory for R plots

Stochastic_mapping:
  --stochastic_mapping  Do stochastic mapping
  --tree TREE           Set path to NEXUS tree file
  --m_out M_OUT         Name of the output file from the stochastic mapping
                        analysis
  --n_rep N_REP         Number of stochastic maps
  --map_model {ER,SYM,ARD}
                        Transition model
  --max_run_time MAX_RUN_TIME
                        Max run time for 1 stochastic map (in seconds).
  --trait TRAIT         Trait >0 indicates the number of the character to be
                        analyzed
```
