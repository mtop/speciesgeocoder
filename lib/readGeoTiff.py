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

from osgeo import gdal
import sys
import subprocess

class Geotiff(object):
	# GeoTiff object
	def __init__(self, tiffile):
		self.tiffile = tiffile
		my_file = gdal.Open(self.tiffile)
		self.width = my_file.RasterXSize
		self.height = my_file.RasterYSize
		self.gt = my_file.GetGeoTransform()
		self.MINX = self.gt[0]
		self.MINY = self.gt[3] + self.width*self.gt[4] + self.height*self.gt[5]
		self.MAXX = self.gt[0] + self.width*self.gt[1] + self.height*self.gt[2]
		self.MAXY = self.gt[3]

	def minx(self):
		return self.MINX
	
	def miny(self):
		return self.MINY

	def maxx(self):
		return self.MAXX

	def maxy(self):
		return self.MAXY

	def corners(self):
		return "MinX: ", self.minx(), "MaxX: ", self.maxx(), "MinY: ", self.miny(), "MaxY: ", self.maxy()

	def get_elevation(self, lon, lat):
		if sys.platform.startswith('linux2'):
			binary = "bin/gdallocationinfo_linux2"
		if sys.platform.startswith('darwin'):
			binary = "bin/gdallocationinfo_darwin"
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
			tifFiles[tif].append(tifObj.minx())		# [0]
			# Extract maxX
			tifFiles[tif].append(tifObj.maxx())		# [1]
			# Extract minY
			tifFiles[tif].append(tifObj.miny())     	# [2]
			# Extract maxY
			tifFiles[tif].append(tifObj.maxy())		# [3]
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
