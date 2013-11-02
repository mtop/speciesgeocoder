#!/usr/bin/env python

#   Copyright (C) 2013 Mats Töpel.
#
#   Citation: If you use this version of the program, please cite;
#   Mats Töpel (2013) Open Laboratory Notebook. www.matstopel.se
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
import random
import sys

infiles = sys.argv[1:]

tifFiles = {}

class geoTiff(object):
	# GeoTiff object
	def __init__(self, ds):
		self.width = ds.RasterXSize
		self.height = ds.RasterYSize
		self.gt = ds.GetGeoTransform()
		self.ds = ds
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
		return "MinX: ", ds.minx(), "MaxX: ", ds.maxx(), "MinY: ", ds.miny(), "MaxY: ", ds.maxy()

	
	def random(self):	
		lon, lat = random.randrange(int(self.MINX), int(self.MAXX)), random.randrange(int(self.MINY), int(self.MAXY))
#		return self.elevation(lon, lat)

	def elevation(self, lon, lat):
		# self.MAXY + (row * self.gt[5]) together with
		# self.MINX + (col * self.gt[1]) referes to the 
		# top right corner of the tif image.
		# returns the elevation given the Lat/long input
		row = 1
		while (self.MAXY + (row * self.gt[5])) < lat:
			row += 1
			print row									# Devel.
		col = 1
		while (self.MINX + (col * self.gt[1])) < lon:
			col += 1
#		print "Elevation: ", self.ds.ReadAsArray()[col][row]
		return self.ds.ReadAsArray()[col][row]

	def test(self, lon, lat):
		row = 1
		while (self.MAXY + (row * self.gt[5])) > lat:
#			print "MaxY: ", self.MAXY
#			print "Row: ", row
#			print "Lat: ", lat
			row += 1
		print "Row: ", row
		col = 1

#		print "MinX: ", self.MINX
#		print "Col: ", col
#		print "Long: ", lon
#		print "Test: ", (self.MINX + (col * self.gt[1]))

		while (self.MINX + (col * self.gt[1])) < lon:
#			print "Test lon: ", (self.MINX + (col * self.gt[1]))
#			print "MinY: ", self.MINY
#			print "Col: ", col
#			print "Long: ", lon
			col += 1
		print "Col: ", col
#		print self.ds.ReadAsArray()[0][col][row]
#		print self.ds.ReadAsArray()[0][row][col]
#		print self.ds.ReadAsArray()[1][row][col]
#		print self.ds.ReadAsArray()[2][row][col]
#		print self.ds.ReadAsArray().shape				# Works
		print self.ds.ReadAsArray()[0:3, row, col]

	def test_2(self, col, row, i):
		print self.ds.ReadAsArray()[col][row][i]
		


def indexTiffs(infiles):
	# Create a dictionary of avaialble geotiff 
	# files with coordinate data as values.
	# "infiles" is a list of geotiff file names.
	for tif in infiles:
		if ".tif" in tif:				# Remove later on.
			my_file = gdal.Open(tif)
			tifObj = geoTiff(my_file)
			tifFiles[tif] = []
			# Extract minX
			tifFiles[tif].append(tifObj.minx())		# [0]
			# Extract maxX
			tifFiles[tif].append(tifObj.maxx())		# [1]
			# Extract minY
			tifFiles[tif].append(tifObj.miny())     # [2]
			# Extract maxY
			tifFiles[tif].append(tifObj.maxy())		# [3]
	return tifFiles						

def coordInTif(lon, lat, tifFiles):
	for tif in tifFiles:
#		print "Tif-file: ", tif
#		print "Long: ", lon
#		print "Lat: ", lat
#		print "MinX: ", tifFiles[tif][0]
#		print "MaxX: ", tifFiles[tif][1]
#		print "MinY: ", tifFiles[tif][2]
#		print "MaxY: ", tifFiles[tif][3]
#		print tifFiles[tif][2] < lat
#		print lat < tifFiles[tif][3]
#		print tifFiles[tif][0] < lon
#		print lon < tifFiles[tif][1]
#		print ""
		# Test if coordinates are found within the range of the tiff file.
		if tifFiles[tif][2] < lat and lat < tifFiles[tif][3] and tifFiles[tif][0] < lon and lon < tifFiles[tif][1]:
#			print "Correct file is: ", tif
			return tif
	


if __name__ == "__main__":
	# 57.496642,18.448362 are the coordinates for Roma, Gotland.
	# 57.6627998352, 18.346200943 are the coordinates for Visby airport.

	my_file = gdal.Open(sys.argv[1])	
	ds = geoTiff(my_file)
#	print dir(my_file)
#	print ""
#	print dir(ds)
	print "Corners: ", ds.corners()
	print "GetGeoTransform: ", my_file.GetGeoTransform()
	ds.test(float(63), float(63))							# Result: 107, 146, 36 as expected
#	ds.test_2(9559, 4366)
#	ds.test_2(2,400,3)			# Testat Max [0]: 2 [1]: 361



#	print "Value 1-1: ", ds.elevation(float(18.448362), float(57.496642))
#	print "Value 1-1: ", ds.elevation(float(-1), float(-1))						# Crash
#	print "Metadata: ", my_file.GetMetadata()					# Metadata: {}
#	print "Metadata_list: ", my_file.GetMetadata_List()			# None
#	print "As array: ", my_file.ReadAsArray()					# OK
#	print "Length of array: ", len(my_file.ReadAsArray())		# Length is 3.
#	print "GetGeoTransform: ", my_file.GetGeoTransform()		# (-180.03879301265735, 0.018939867494837094, 0.0, 83.678805953060021, 0.0, -0.018939867494837094)
#	print my_file.GetMetadataItem(1,1)							# Crash









#	lat = 57.6627998352
#	lon = 18.346200943
#
#	### Identify the correct file, given the lat/long coordinates and a set of geotiff files.
#	tifIndex = indexTiffs(infiles)
#	correct_file = coordInTif(lon, lat, tifIndex)
#
#	### Test elevation extraction given long/lat coordinates and one geotiff file.
#	if correct_file:
#		my_file = gdal.Open(correct_file)
#		ds = geoTiff(my_file)
#		print ds.elevation(float(lon), float(lat))


