#!/usr/bin/env python

from osgeo import gdal
from os import listdir

tifFiles = {}

class geoTiff(object):
	# GeoTiff object
	def __init__(self, ds):
		self.width = ds.RasterXSize
		self.height = ds.RasterYSize
		self.gt = ds.GetGeoTransform()
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

	def elevation(self, lat, lon):
		row = 1
		print (self.MAXY + (row * self.gt[5]))			# Devel.
		while (self.MAXY + (row * self.gt[5])) < lat:
			row += 1
		col = 1
		print (self.MAXX + (col * self.gt[1]))			# Devel.
		while (self.MAXX + (col * self.gt[1])) < lon:
			col += 1
#		row = (lat - self.MAXY)*self.gt[4]
#		col = (lon - self.MAXX)*self.gt[1]
		print row, col

#	def inArea(self, lat, lon):
#		if self.minx < lat and self.maxx > lat and self.maxy > lon and self.miny < lon:

#			return False
		

def listTiffs():
	# Create a dictionary of avaialble geotiff 
	# files with coordinate data as values.
	pwd = "."		# Or use a flagg to define different dir.
	print listdir(pwd)					# Devel.
	for tif in listdir(pwd):
		if ".tif" in tif:
			my_file = gdal.Open(tif)
#			ds = tiff(my_file)
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
			# Extract minY

	return tifFiles						

def coordInTif(lat, lon):
	for tif in tifFiles:
		# Test if coordinates are found within the range of the tiff file.
		if tifFiles[tif][2] > lat and lat < tifFiles[tif][3] and tifFiles[tif][0] < lon and lon > tifFiles[tif][1]:
			return tif
		else:
			return None
	


if __name__ == "__main__":
#	print listTiffs()
	my_file = gdal.Open('ASTGTM2_N07W082_num.tif')
	ds = geoTiff(my_file)
	ds.elevation(float(-1.5), float(-81.0))
#	print ds.minx()
#	print ds.miny()
#	print ds.maxx()
#	print ds.maxy()
