#!/usr/bin/env python
# -*- coding: utf-8 -*-

#   Copyright (C) 2014 Mats Töpel.
#
#   Citation: If you use this version of the program, please cite;
#   Mats Töpel (2014) Open Laboratory Notebook. www.matstopel.se
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys
import subprocess

class Geotiff(object):
	# GeoTiff object
	def __init__(self, tiffile):
		self.tiffile = tiffile
		try:
			from osgeo import gdal
#			import zzz							# Devel.
			my_file = gdal.Open(self.tiffile)
			self.width = my_file.RasterXSize
			self.height = my_file.RasterYSize
			self.gt = my_file.GetGeoTransform()
			self.MINX = self.gt[0]
			self.MINY = self.gt[3] + self.width*self.gt[4] + self.height*self.gt[5]
			self.MAXX = self.gt[0] + self.width*self.gt[1] + self.height*self.gt[2]
			self.MAXY = self.gt[3]
		except:
			from os.path import abspath, dirname, join
			if sys.platform.startswith('linux2'):
				binary = abspath(join(dirname(__file__), "../bin/gdalinfo_linux"))
#				sys.exit("GDAL not installed")				# For now
			if sys.platform.startswith('darwin'):
				binary = abspath(join(dirname(__file__), "../bin/gdalinfo_darwin"))
			self.out = subprocess.check_output([binary, self.tiffile])

			upper_left = self.out.split("Upper Left  (  ")[1].split(")")[0].split("\n")
			lower_left = self.out.split("Lower Left  (  ")[1].split(")")[0].split("\n")
			upper_right = self.out.split("Upper Right (  ")[1].split(")")[0].split("\n")
			lower_right = self.out.split("Lower Right (  ")[1].split(")")[0].split("\n")

			self.MINY = lower_left[0].split(",")[1]
			self.MINX = lower_left[0].split(",")[0]		# OK
			self.MAXY = upper_right[0].split(",")[1]
			self.MAXX = lower_right[0].split(",")[0]	# OK

#            minx: 17.9998611111
#            maxx: 19.0001388889
#            miny: 56.9998611111
#            maxy: 58.0001388889


	def minx(self):
		return float(self.MINX)
	
	def miny(self):
		return float(self.MINY)

	def maxx(self):
		return float(self.MAXX)

	def maxy(self):
		return float(self.MAXY)

	def corners(self):
		return "MinX: ", self.minx(), "MaxX: ", self.maxx(), "MinY: ", self.miny(), "MaxY: ", self.maxy()

	def get_elevation(self, lon, lat):
		from os.path import abspath, dirname, join
		if sys.platform.startswith('linux2'):
			binary = abspath(join(dirname(__file__), "../bin/gdallocationinfo_linux2"))
		if sys.platform.startswith('darwin'):
			binary = abspath(join(dirname(__file__), "../bin/gdallocationinfo_darwin"))
		elevation = subprocess.check_output([binary, "-valonly", "-wgs84", self.tiffile, lon, lat])
		return int(elevation)	

	
def indexTiffs(infiles):
	# Create a dictionary of avaialble geotiff 
	# files with coordinate data as values.
	# "infiles" is a list of geotiff file names.
	tifFiles = {}
	done = 0
	for tif in infiles:
		done += 1
		progress = (float(done)/len(infiles))*100
		sys.stderr.write("Indexing tiff files: {0:.0f}%     \r".format(progress))
		if ".tif" in tif:					# Remove later on.
			tifObj = Geotiff(tif)
			tifFiles[tif] = []

			# Extract minX
			tifFiles[tif].append(tifObj.minx())		# [0], Left [0]
			# Extract maxX
			tifFiles[tif].append(tifObj.maxx())		# [1], Right [0]	
			# Extract minY
			tifFiles[tif].append(tifObj.miny())     # [2], Lower [1]
			# Extract maxY
			tifFiles[tif].append(tifObj.maxy())		# [3], Upper [1]

###			print tifObj.minx()			# Devel.
###			print tifObj.maxx()			# Devel.
###			print tifObj.miny()			# Devel.
###			print tifObj.maxy()			# Devel.
#			minx: 17.9998611111  
#			maxx: 19.0001388889
#			miny: 56.9998611111
#			maxy: 58.0001388889

	sys.stderr.write("\n")
	return tifFiles						

def coordInTif(lon, lat, index):
	for tif in index:					
		# Test if coordinates are found within the range of the tiff file.
		if index[tif][2] < lat and lat < index[tif][3] and index[tif][0] < lon and lon < index[tif][1]:
			return tif
	


if __name__ == "__main__":

	my_file = gdal.Open(sys.argv[1])	
	ds = Geotiff(my_file)

	lat = 57.6627998352
	lon = 18.346200943

	print ds.elevation(float(lon), float(lat))
