geocoder
========
Short description:
Species locality data + polygons -> nexus file.

Longer description:
geocoder.py is a program written in Python that takes one file
containing polygons, and one file with species locality data
as input. The program then tests if a species have been recorded
inside any of the polygons. The result is presented as a nexus-
file with "0" indicating absence, and "1" indicating pressence
in a polygon.

Input:  See the example files localities.txt and polygons.txt.
Output:See the example file ivesioids_out.nex.

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

# Downloading locality data (30 m. resolution)
Download instructions: http://gdem.ersdac.jspacesystems.or.jp/feature.jsp
Download site: http://gdem.ersdac.jspacesystems.or.jp/search.jsp


