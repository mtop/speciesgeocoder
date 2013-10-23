#!/usr/bin/env python
# -*- coding: utf-8 -*-

#	geocoder.py is a program written in Python that takes one file 
#	containing polygons, and one file with species locality data 
#	as input. The program then tests if a species have been recorded 
#	inside any of the polygons. The result is presented as a nexus- 
#	file with "0" indicating absence, and "1" indicating presence of
#	a species in a polygon.
###
# 	Input localities (e.g exported in tab delimited cvs format. Lines starting with "#" are ignored):
#	
#	#Species name	Lat.	Longitude	Comment
#	Ivesia aperta	39.82	-120.4	CHSC35943
#	Ivesia aperta	39.81	-120.39	CHSC88602
#	Ivesia aperta	39.53	-120.37	
#	...
#
#	Input polygons:
#
#	polygon_USA_Long_Lat: -132.1875,49.61071 -80.15625,50.513427 -79.101562,23.885838 -132.1875,24.846565 -132.1875,49.61071
#	polygon_EU: 24.287109,72.118943 7.587891,68.323557 -14.384766,55.760092 -14.033203,34.428056 -5.068359,36.007635 10.224609,38.525248 20.947266,33.991954 40.634766,60.744845 24.287109,72.118943
#	
#	Also see the example files localities.csv and polygons.txt. 
#			
# 	Output: 	See the example file ivesioids_out.nex.
#
###
#
#	Dependencies:	python-argparse
#					python-gdal
#					gdal-bin
#
###
#
#	Copyright (C) 2013 Mats Töpel. 
#
#	Citation: If you use this version of the program, please cite;
#	Mats Töpel (2013) Open Laboratory Notebook. www.matstopel.se
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

### TODO ###
#
# Check that in-data is in the right format.
# Remove "_" characters from species names. - DONE
# Add option to only regard "Genus" and "species epithet" parts of species names. - DONE
#
############

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--polygons", help="Path to file containing polygon coordinates")
parser.add_argument("-l", "--localities", help="Path to file containing species locality data")
parser.add_argument("-g", "--gbif", help="Path to file containing species locality data downloaded from GBIF")
parser.add_argument("-t", "--tif", help="Path to geotiff file(s)", nargs="*")
#parser.add_argument("-o", "--out", help="Name of optional output file. Output is sent to STDOUT by default")
parser.add_argument("-v", "--verbose", action="store_true", help="Also report the number of times a species is found in a particular polygon")
parser.add_argument("-b", "--binomial", action="store_true", help="Treats first two words in species names as genus name and species epithet. Use with care as this option is LIKELY TO LEAD TO ERRONEOUS RESULTS if names in input data are not in binomial form.")
args = parser.parse_args()


class Polygons(object):
	# Object that contains all polygons.
	def __init__(self):
		self.polygonFile = args.polygons # [0]
		self.polygonNames = []
		for polygon in self.getPolygons():
			self.setPolygonNames(polygon[0])

	def getPolygons(self):
		f = open(self.polygonFile)
		lines = f.readlines()
		for line in lines:
			low = None
			high = None
			if not line:
				break
			splitline = line.split(':')
			name = splitline[0]
			self.setPolygonNames(name)
			polygon = self.prepare_poly(splitline[1])
			# Check if polygon has elevation restrictions
			try:
				if splitline[2]:
					if "-" in splitline[2]:
						low = splitline[2].split("-")[0]
						high = splitline[2].split("-")[1]
#						print "##################"
#						print name, "has the elevation restrictions", splitline[2]
#						print "Min: ", low
#						print "Max: ", high
					if ">" in splitline[2]:
						low = splitline[2].split(">")[1]
#						print "##################"
#						print name, "has the elevation restrictions", splitline[2]
#						print "Min: ", low.rstrip("\n")
#						print "Max: Unlimited\n"
					if "<" in splitline[2]:
						high = splitline[2].split("<")[1]
#						print "##################"
#						print name, "has the elevation restrictions", splitline[2]
#						print "Min: Unlimited"
#						print "Max: ", high
			except:
				low = None
				hight = None
			yield name, polygon, low, high

	def setPolygonNames(self, name):
		if name not in self.polygonNames:
			self.polygonNames.append(name)

	def getPolygonNames(self):
		return self.polygonNames

	def prepare_poly(self, poly):
		poly = poly.split(' ')
		poly_2 = []
		for node in list(poly):
			if not node:
				pass
			else:
				mod = ('%s') % node
				poly_2.append(mod.rstrip('\n'))
		return poly_2
									
class Localities(object):
	def getBinomialName(self, speciesName):
		# Returns a string including only the genus name and species epithet.
		n = speciesName.split()
		name = n[0]
		try:
			if n[1]:
				name = str(name + " " + n[1])
		except:
			pass
		return name

class MyLocalities(Localities):
	# Object that contains the locality data
	# read from a tab-delimited *.csv file.
	def __init__(self):
		self.localityFile = args.localities # [0]
		self.speciesNames = []
		self.order = ""
		for name in self.getLocalities():
			self.setSpeciesNames(name[0])

	def getLocalities(self):
		f = open(self.localityFile)
		lines = f.readlines()
		for line in lines:
			if not line:
				break
			# Determine the Lat/Long column order
			if line[0] == "#":
				strings = ["Latitude", "latitude", "Lat.", "lat.", "Lat", "lat"]
				if line.split("\t")[1] not in strings:
					self.order = "long-lat"
				else:
					self.order = "lat-long"
				continue
			splitline = line.split("\t")

			if args.binomial:
				species = self.getBinomialName(splitline[0])
			else:
				species = splitline[0]  # + ' ' + splitline[2]
			self.setSpeciesNames(species)
			latitude = splitline[1]
			longitude = splitline[2]
			yield species.replace("  ", " "), latitude, longitude
	
	def getCoOrder(self):
		return self.order

	def setSpeciesNames(self, name):
		if name not in self.speciesNames:
			self.speciesNames.append(name)

	def getSpeciesNames(self):
		return self.speciesNames

class GbifLocalities(Localities):
	# Object that contains the locality data in the form
	# that is delivered from http://data.gbif.org 
	def __init__(self):
		self.gbifFile = args.gbif
		self.speciesNames = []
		for name in self.getLocalities():
			self.setSpeciesNames(name[0])	# [1]

	def getLocalities(self):
		f = open(self.gbifFile)
		lines = f.readlines()
		for line in lines:
			# Make sure the record has both lat. and long. data.
			if len(line.split("\t")[5]) > 0 and len(line.split("\t")[6]) > 0:
				if line.split("\t")[5] == "Latitude":
					continue
			try:
				float(line.split("\t")[5])
				float(line.split("\t")[6])
			except:
				continue
			if args.binomial:
				species = self.getBinomialName(line.split("\t")[3])
			else:
				species = line.split("\t")[3]
			latitude = line.split("\t")[5]
			longitude = line.split("\t")[6]
			yield species.replace("  ", " "), latitude, longitude

	def setSpeciesNames(self, name):
		if name not in self.speciesNames:
			self.speciesNames.append(name)
	
	def getSpeciesNames(self):
		return self.speciesNames



def pointInPolygon(poly, x, y):
	# Returns "True" if a point is inside a given polygon. 
	# Othewise returns "False". The polygon is a list of 
	# Longitude/Latitude (x,y) pairs.
	# Code modified from  http://www.ariel.com.au/a/python-point-int-poly.html

#	print "In pIp: Here we go!"			# Devel.
	
	try:
		x = float(x)
	except:
		print "x is not a number"
	try:
		y = float(y)
	except:
		print "y is not a number"
	n = len(poly)
	inside = False
	p1x,p1y = poly[0].split(',')
	p1x = float(p1x)
	p1y = float(p1y)
	for i in range(n+1):
		p2x = float('%s' % poly[i % n].split(',')[0])
		p2y = float('%s' % poly[i % n].split(',')[1])
		if y > min(p1y,p2y):
			if y <= max(p1y,p2y):
				if x <= max(p1x,p2x):
					if p1y != p2y:
						xinters = (y-p1y)*(p2x-p1x)/(p2y-p1y)+p1x
					if p1x == p2x or x <= xinters:
						inside = not inside
		p1x,p1y = p2x,p2y
	return inside


class Result(object):
	def __init__(self, polygons):
		self.polygonNames =  polygons.getPolygonNames()
	
	def setSpeciesNames(self, dataObject):
		# Create a dictionary where each key corresponds to 
		# a speceis names, and the values are initially lists
		# of zeros of the same length as the number of polygons. 
		self.initialList = []
		for i in range(len(self.polygonNames)):
			self.initialList.append(0)
		try:
			if self.result:
				pass
		except:
			self.result = {}

		for name in dataObject.getSpeciesNames():
			if name not in self.result:
				self.result[name] = self.initialList
			else:
				continue
#		print self.result		# Devel.


	def getSpeciesNames(self):
		speciesNames = []
		for key in self.result:
			speciesNames.append(key)
		return speciesNames

#	def setSpeciesNames(self, ):
#		self.speciesNames = localities.getSpeciesNames()

	def getPolygonNames(self):
		return self.polygonNames

	def setResult(self, speciesName, polygonName):
		list = self.result[speciesName]
		newList = []
		index = 0
		for i in list:
			if index == self.polygonNumber(polygonName):
				newVal = i+1
				newList.append(newVal)
				index += 1
			else:
				newList.append(i)
				index += 1
		self.result[speciesName] = newList

	def getResult(self):
		return self.result

	def polygonNumber(self, polygonName):
		return self.polygonNames.index(polygonName)

	def printNexus(self):
		# Print the results to stdOut in NEXUS format.
		# Use a redirect to store in file.
		print "#NEXUS\n"
		print "Begin data;"
		print "\tDimensions ntax=%s nchar=%s;" % (len(self.getSpeciesNames()), len(self.getPolygonNames()))
		print "\tFormat datatype=standard symbols=\"01\" gap=-;"
		print "\tCHARSTATELABELS"
		# Print the names of the polygons
		for i in range(len(self.getPolygonNames())):
			if i+1 < len(self.getPolygonNames()):
				print "\t%s %s"	% (i+1, self.getPolygonNames()[i]) + ','
			if i+1 == len(self.getPolygonNames()):
				print "\t%s %s" % (i+1, self.getPolygonNames()[i]) + ';'
		print "\n"
		print "\tMatrix"
		# Print the species names and character matrix
		for name in sorted(self.getResult()):
			print name.replace(" ","_"), '\t\t', self.resultToStr(self.result[name])
		print '\t;'
		print 'End;'


	def resultToStr(self, resultList):
		string = ''
		for i in resultList:
			if i > 0:
				if args.verbose:
					string += "1" + "[" + str(i) + "]"
				else:
					string += "1"
			else:
				string += "0"
		return string



def elevationTest(lat, lon, polygon, index):
	from lib.readGeoTiff import coordInTif
	from lib.readGeoTiff import geoTiff
	from osgeo import gdal
#	print lon, lat
#	print "In elevationTest"
#	print polygon[0]
#	print type(polygon[2]), type(polygon[3])
	if polygon[2] is None and polygon[3] is None:
#		print "In elevationTest: ", polygon[0], "has no elevation limit"
		return True
	# Identify the correct tif file 
	correct_file = coordInTif(float(lon), float(lat), index)
#	print "Correct file: ", correct_file
	# The following two lines of code can be usefull if one 
	# wants to disregard the elevation limits if no elevation 
	# data is available for a particular area.
#	print polygon[2]
#	if not correct_file and polygon[2] == None:
#		return True	

	if correct_file:
		my_file = gdal.Open(correct_file)
		ds = geoTiff(my_file)
		elevation = int(ds.elevation(float(lon), float(lat)))
		if not polygon[2]:
			low = -1000				# A really low elevation.
		else:
			low = int(polygon[2])
		if not polygon[3]:
			high = -1000			# A really low elevation.
		else:
			high = int(polygon[3])
#		print polygon[0]
#		print "Elevation:   ", elevation, type(elevation)
#		print "Low bound    ", low, type(low)
#		print "High bound   ", high, type(high)
#		if (low < elevation and elevation < high):
#			print "Match"
#		else:
#			print "No match"
		return (low < elevation and elevation < high)
#		if low < elevation and elevation < high:
#			return True
#		print "Elevation: 	", elevation
#		print "Low bound	", low
#		print "High bound	", high

#	print "Imported lib.readGeoTiff"
#	print "Lat: 	", lat
#	print "Long:	", lon

	


def main():
	# Read the locality data and test if the coordinates 
	# are located in any of the polygons.
	polygons = Polygons()
	result = Result(polygons)
	# Index the geotiff files if appropriate.
	if args.tif:
		from lib.readGeoTiff import indexTiffs
		index = indexTiffs(args.tif)
#		print "New index has been created"				# Devel.
	# For each locality record ...
	if args.localities:
#		print "In Main: args.localities are in place."
		localities = MyLocalities()
		result.setSpeciesNames(localities)
		for locality in localities.getLocalities():
#			print "In Main: Found a locality data point."
			# ... and for each polygon ...
			for polygon in polygons.getPolygons():
#				print "In main", polygon[0]						# Devel.
				# ... test if the locality record is found in the polygon.
				if localities.getCoOrder() == "lat-long":
#					print "In Main: Correct order of coordinates was found."
					# locality[0] = species name, locality[1] = latitude, locality[2] =  longitude
					if pointInPolygon(polygon[1], locality[2], locality[1]) == True:
#						print "In main, Point was found in polygon", polygon[0]

###################### OK, so the point is in the polygon

						# Test if elevation files are available.
#						print ((polygon[2] or polygon[3]) and args.tif)				# Devel.
#						if (polygon[2] or polygon[3]) and args.tif:
#						print "In Main: Available TIFFs: ", args.tif
						if args.tif:
#							print "In Main: We have found Tiffs"
#							print "Elevation restrictions and Tiff files found", polygon[0]		# Devel.
							if elevationTest(locality[1], locality[2], polygon, index) == True:
#								print "####################################"		# Devel.
#								print polygon[0], "has elevation restrictions"		# Devel.
								# Store the result
								result.setResult(locality[0], polygon[0])		
		#				else:
		#					# Store the result
		#					result.setResult(locality[0], polygon[0])
				else:
					print "In Main: Reversed order of coordinated found!"
###					# locality[0] = species name, locality[1] = longitude, locality[2] =  latitude
###					if pointInPolygon(polygon[1], locality[1], locality[2]) == True:
###						if args.tif:
###							if elevationTest(locality[2], locality[1], polygon, index) == True:
###								result.setResult(locality[0], polygon[0])
	
	if args.gbif:
		gbifData = GbifLocalities()
		result.setSpeciesNames(gbifData)
		# For each GBIF locality record ...
		for locality in gbifData.getLocalities():
			# ... and for each polygon ...
			for polygon in polygons.getPolygons():
				# ... test if the locality record is found in the polygon.
				if pointInPolygon(polygon[1], locality[2], locality[1]) == True:
					result.setResult(locality[0], polygon[0])

	result.printNexus()


if __name__ == "__main__":
	main()
