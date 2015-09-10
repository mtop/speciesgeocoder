# SpeciesGeoCoder

SpeciesGeoCoder is an open-source software package written in Python and R, that utilise the GDAL library (http://www.gdal.org/) for fast analysis of geoTIFF files, which allows for the easy and fast coding of species into user-defined operational units. These units may be of any size and be purely spatial (i.e., polygons) such as political units (countries, states), conservation areas, realms, biomes, ecoregions, islands, biodiversity hotspots, and areas of endemism; but they may also be defined as a combination of several criteria, including altitudinal ranges. This flexibility allows scoring species into complex categories, such as those encountered in topographically and ecologically heterogeneous landscapes. The various outputs of SpeciesGeoCoder include quantitative biodiversity statistics, global and local distribution maps, and Nexus files that can be directly used in many phylogeny-based applications for ancestral state reconstruction, investigations on biome evolution, and diversification rate analyses. 

Input:  See the example files localities.txt and polygons.txt.

Output: See the example file ivesioids_out.nex.

# Installing and running

### For the impatient 
Download the latest version from https://github.com/mtop/speciesgeocoder/releases
```bash
unzip speciesgeocoder-x.x.x.zip
cd speciesgeocoder-x.x.x
./geocoder.py -l example_data/localities.csv -p example_data/polygons.txt -t example_data/*.tif
```

## Dependencies
The following package is required for SpeciesGeoCoder to run:

* argparse (Module included in python v2.7. Available at https://pypi.python.org/pypi/argparse)

The following packages are optional and will depend on which kind of analyses you will do:
* osgeo (The GDAL library available at https://pypi.python.org/pypi/GDAL/). Required for altitudinal coding
* R (Available from http://www.r-project.org/). Required if you want to use the plot functions or do stochastic mapping
* R-packages: rgeos, maptools, maps, mapdata, raster, optparse, ape, geiger, phytools (R will prompt you for the missing packages)

# Installing on Mac OSX

Download the latest version from https://github.com/mtop/speciesgeocoder/releases

1. Unzip the file by double-clicking on it.
2. Open a terminal window and use the command "cd" to move into the directory "speciesgeocoder-x.x.x" (where "x.x.x" will indicate the version number of the latest release; tips: instead of writing the path, you can just 'drag' the folder to your terminal window)
3. Copy and paste the following command into your terminal window to make sure everything works as expected:

```bash
./geocoder.py -l example_data/localities.csv -p example_data/polygons.txt -t example_data/*.tif
```

# Installing on Windows

1. Download and install the Latest Python 2 Release from https://www.python.org/downloads/windows/
2. Direct your browser to http://www.lfd.uci.edu/~gohlke/pythonlibs/ and then download and install GDAL for python 2.7
3. Download and install R from http://cran.r-project.org/bin/windows/base/

In addition, you'll also have to add the R executables to your PATH (in order for SpeciesGeoCoder to find it).

1. Find the directory that the R program is installed in (e.g "C:\Program Files\R\R-3.1.1")
2. From the desktop, right-click My Computer and click Properties.
3. In the System Properties window, click on the Advanced tab.
4. In the Advanced section, click the Environment Variables button.
5. Click the Environment Variables button, highlight the Path variable in the Systems Variable section and click the Edit button. 
6. Add ";C:\Program Files\R\R-3.1.1\bin" (if that is where the R executables are found, don't forget the preceding ";" character) to the end of line and click "Ok".

Change permissions to the R "library" directory in the following way: (this is nessesary as SpeciesGeoCoder will have to automatically install additional R packages).

1. Right click on "C:\Program Files\R\R-3.1.1\library" and select properties -> Security.
2. Click "Edit".
3. In "Group our user names" select your name.
4. Mark the "Full control" checkbox.
5. Click "Ok".

# Installing on GNU/Linux

Download the latest version from https://github.com/mtop/speciesgeocoder/releases

```bash
unzip speciesgeocoder-x.x.x.zip
cd speciesgeocoder-x.x.x
./geocoder.py -l example_data/localities.csv -p example_data/polygons.txt -t example_data/*.tif
````

Optionally you can make a symbolic link from a directory in your PATH to the file "speciesgeocoder" in the "speciesgeocoder-x.x.x" directory. 


# Installing and running the development version

```bash
git clone git@github.com:mtop/speciesgeocoder.git
cd speciesgeocoder/
./geocoder.py -l example_data/localities.csv -p example_data/polygons.txt -t example_data/*.tif
```
