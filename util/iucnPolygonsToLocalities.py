#!/usr/bin/env python
# -*- coding: utf-8 -*-

#       Extracts polygon edges and species names from shapefiles such as the once 
#		available at http://www.iucnredlist.org/technical-documents/spatial-data.
#		Outputs Species name, latitude and logitude sepparated by tabs to STDOUT.
#
#		Usage: iucnPolygonsToLocalities.py SHAPEFILE.shp > out.txt
#
#
#       Citation: If you use this version of the program, please cite;
#       
#		Mats Töpel, Alexander Zizka, Maria Fernanda Calio, Ruud Scharn, 
#		Daniele Silvestro, Alexandre Antonelli (2016) 
#		SpeciesGeoCoder: Fast categorization of species occurrences for 
#		analyses of biodiversity, biogeography, ecology and evolution. 
#		Systematic Biology. doi: 10.1093/sysbio/syw064
#
#
#       Copyright (C) 2016 Mats Töpel. mats.topel@marine.gu.se
#
#       This program is free software: you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation, either version 3 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys
try:
	import shapefile
except ImportError:
	sys.stderr.write('[Error] The python module \"shapefile\" is not installed. Try installing it with "sudo easy_install pyshp"\n')


infile = sys.argv[1]
shapeFile = shapefile.Reader(infile)
numRecords = shapeFile.numRecords
shapes = shapeFile.shapes()	# Each individual polygon


def PolygonsToLocalities():
	nbr = 0
	for nbr in range(numRecords):
		# Name
		name =  shapeFile.record(nbr)[1]
		# Coordinates
		raw_polygon = shapeFile.shapes()[nbr].points

		# Format the locality data correctly
		for edge in raw_polygon:
			lat = str(edge[0])
			lon = str(edge[1])
			result = name + "\t" + lat + "\t" + lon
			print result
		nbr += 1

if __name__ == "__main__":
	PolygonsToLocalities()
