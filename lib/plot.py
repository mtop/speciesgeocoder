#!/usr/bin/env python
# -*- coding: utf-8 -*-

#	Species locality data + polygons -> nexus file 
#
#	Copyright (C) 2014 Mats Töpel. mats.topel@bioenv.gu.se
#
#	Citation: If you use this version of the program, please cite;
#	Mats Töpel (2014) Open Laboratory Notebook. www.matstopel.se
#
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#	
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <http://www.gnu.org/licenses/>.


def prepare_plots(result, polygons):
	### Prepare the input files for R
	
	# coordinates.sgc.txt
	out1 = open("coordinates.sgc.txt", "w")
	out1.write("identifier\tXCOOR\tYCOOR\n")
	for species, polygon, longitude, latitude in result.getSampletable():
		# Note that the latitude/longitude order has shifted 
		# in order to fit the requirements of the R code.
		out1.write("%s\t%s\t%s\n" % (species.replace(" ", "_") , longitude, latitude))
	out1.close()

	# polygons.sgc.txt
	out2 = open("polygons.sgc.txt", "w")
	out2.write("identifier\tXCOOR\tYCOOR\n")
	for polygon in polygons.getPolygons():
		for coordPair in polygon[1]:
			# Note that the latitude/longitude order has shifted
			# in order to fit the requirements of the R code.
			out2.write("%s\t%s\t%s\n" % (polygon[0].replace(" ", "_"), coordPair.split(' ')[0], coordPair.split(' ')[1]))
	out2.close()

	# sampletable.sgc.txt
	out3 = open("sampletable.sgc.txt", "w")
	out3.write("identifier\thomepolygon\tXCOOR\tYCOOR\n")
	for species, polygon, longitude, latitude in result.getSampletable():
		out3.write("%s\t%s\t%s\t%s\n" % (species.replace(" ", "_"), polygon.replace(" ", "_"), longitude, latitude))
	out3.close()

	# speciestable.sgc.txt
	# Number of occurrences per polygon
	out4 = open("speciestable.sgc.txt", "w")
	# Headers 
	header = "Species\t"
	for name in result.getPolygonNames():
		header += "%s\t" % name.replace(" ", "_")
	header = header[:-1] + "\n"
	out4.write(header)
	# Species names and character matrix
	for species in result.getResult():
		string = "%s\t" % species.replace(" ", "_")
		for record in result.getResult()[species]:
			string += "%s\t" % record 
		string = string[:-1] + "\n"
		out4.write(string)
	out4.close()
