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
import os
import subprocess

try:
	from osgeo import gdal
except ImportError:
	sys.stderr.write("[Error] The python module \"osgeo\" is not installed\n")
	sys.stderr.write("[--] Would you like to install it now using 'sudo easy_install GDAL' [Y/N]? ")
	answer = sys.stdin.readline()
	if answer[0].lower() == "y":
		# Try to install GDAL. This may very well fail...
		try:
			sys.stderr.write("[--] Running \'sudo easy_install GDAL\'\n")
			subprocess.check_call(["sudo", "easy_install", "GDAL"])
		except:
			sys.stderr.write("[Error] \'sudo easy_install GDAL\' failed.\n")
			sys.exit("[Error] Please visit https://pypi.python.org/pypi/GDAL/ for further installation instructions.")


class Geotiff(object):
	# GeoTiff object
	def __init__(self, tiffile):
		self.tiffile = tiffile
		# Use the python version of GDAL by default.
		self.tiffile = gdal.Open(self.tiffile)
		self.width = self.tiffile.RasterXSize
		self.height = self.tiffile.RasterYSize
		self.gt = self.tiffile.GetGeoTransform()
		self.MINX = self.gt[0]
		self.MINY = self.gt[3] + self.width*self.gt[4] + self.height*self.gt[5]
		self.MAXX = self.gt[0] + self.width*self.gt[1] + self.height*self.gt[2]
		self.MAXY = self.gt[3]

		# Legacy code.
		# Used if compiled versions of the GDAL library should be used instead of "osgeo".
#		else:
#			from os.path import abspath, dirname, join
#			# If this is not a Windows system ...
#			if not sys.platform.startswith('win32'):
#				self.out = subprocess.check_output(["gdalinfo", self.tiffile])
#
#				upper_left = self.out.split("Upper Left  (")[1].split(")")[0].split("\n")
#				lower_left = self.out.split("Lower Left  (")[1].split(")")[0].split("\n")
#				upper_right = self.out.split("Upper Right (")[1].split(")")[0].split("\n")
#				lower_right = self.out.split("Lower Right (")[1].split(")")[0].split("\n")
#	
#				self.MINY = lower_left[0].split(",")[1]
#				self.MINX = lower_left[0].split(",")[0]		# OK
#				self.MAXY = upper_right[0].split(",")[1]
#				self.MAXX = lower_right[0].split(",")[0]	# OK
#
#			else:
#				# This is a Windows system
#				# Add some code...
#				pass

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
		import struct
		# Thanks 'Luke'. http://gis.stackexchange.com/questions/46893/
		# how-do-i-get-the-pixel-value-of-a-gdal-raster-under-an-ogr-point-without-numpy
		px = int((float(lon) - self.gt[0]) / self.gt[1]) # x pixel
		py = int((float(lat) - self.gt[3]) / self.gt[5]) # y pixel
		raster_band = self.tiffile.GetRasterBand(1)	
		structval = raster_band.ReadRaster(px, py, 1, 1, buf_type=gdal.GDT_UInt16) # Assumes 16 bit int aka 'short'
		out = struct.unpack('h' , structval) # Use the 'short' format code (2 bytes) not int (4 bytes)
		elevation = out[0]
		# Legacy code.
#		else:
#			# Use preinstalled version of "gdallocationinfo" if exists...
#			elevation = subprocess.check_output(["gdallocationinfo", "-valonly", "-wgs84", self.tiffile, lon, lat])
		return int(elevation)	

		
		
# Determine if binary versions of the GDAL programs "gdallocationinfo" 
# and "gdalinfo" are found in $PATH.
def gdal_installed():
	installed = []
	program_list = ["gdallocationinfo", "gdalinfo"]
	for program in program_list:
		for path in os.environ["PATH"].split(os.pathsep):
			full_path = os.path.join(path, program)
			if os.path.isfile(full_path) and os.access(full_path, os.X_OK):
				installed.append(program)
	if "gdallocationinfo" and "gdalinfo" in installed:
		return True
	else:
		return False


	
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
