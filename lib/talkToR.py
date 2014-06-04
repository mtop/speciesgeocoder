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

	if args.plot == True:
	### Go to R ###
	### Do tests of cutoff values and call R + functions
		try:
			import rpy2.robjects as ro
		except:
			sys.exit("[ Error ] rpy2 is not installed. Ploting the result will not be possible")
		
		spName_list = []
		spLong_list = []
		spLat_list = []
		polyName_list = []
		polyLong_list = []
		polyLat_list = []

		# Localities
		# Store species names, long. and lat. data in separate lists...
		for locality in localities.getLocalities():
			spName_list.append(locality[0])
			spLong_list.append(locality[1])
			spLat_list.append(locality[2])
		# ...then transform these lists into separate R objects...
		ro.r('speciesNames <- c("%s")' % spName_list)
		ro.r('spLongitudes <- c("%s")' % spLong_list)
		ro.r('spLatitudes <- c("%s")' % spLat_list)
		# ...and finally a data frame.
		ro.r('coordinates <- data.frame(identifier = speciesNames, XCOOR = spLongitudes, YCOOR = spLatitudes)')
		ro.r('png(filename="test_plot-1.png")')		# Devel.
		ro.r('plot(coordinates)')					# Devel.
		ro.r('dev.off()')							# Devel.

		# Polygons
		# Store polygon names long. and lat. data in separate lists...
		for polygon in polygons.getPolygons():
			polyName_list.append(polygon[0])
			polyLong_list.append(polygon[1])
			polyLat_list.append(polygon[2])
		# ...then transform these lists into separate R objects...
		ro.r('polygonNames <- c("%s")' % polyName_list)
		ro.r('polygonLong <- c("%s")' % polyLong_list)
		ro.r('polyLat <- c("%s")' % polyLat_list)
		# ...and finally a data frame.
		ro.r('polygons <- data.frame(identifier = polygonNames, XCOOR = polygonLong, YCOOR = polyLat)')
		ro.r('png(filename="test_plot-2.png")')     # Devel.
		ro.r('plot(polygons)')                   	# Devel.
		ro.r('dev.off()')                           # Devel.
		sys.exit()
	

if __name__ == "__main__":
	
	if args.test == True:
		if args.localities:
			from lib.testData import testLocality
			localities = MyLocalities()
			testLocality(localities, args.localities)

		if args.polygons:
			from lib.testData import testPolygons
			polygons = Polygons()
			testPolygons(polygons, args.polygons)

	else:
		if args.dev:
			import cProfile
			cProfile.run("main()")
		else:
			main()
