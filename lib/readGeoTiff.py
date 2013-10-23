#!/usr/bin/env python

from osgeo import gdal
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
		print "Elevation: ", self.ds.ReadAsArray()[col][row]
		return self.ds.ReadAsArray()[col][row]
		


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
#	lat = 57.496642
#	lon = 18.448362
	lat = 57.6627998352
	lon = 18.346200943

	### Identify the correct file, given the lat/long coordinates and a set of geotiff files.
	tifIndex = indexTiffs(infiles)
#	print tifIndex
	correct_file = coordInTif(lon, lat, tifIndex)

	### Test elevation extraction given long/lat coordinates and one geotiff file.
	if correct_file:
		my_file = gdal.Open(correct_file)
		ds = geoTiff(my_file)
		print ds.elevation(float(lon), float(lat))


