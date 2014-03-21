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

import argparse
import sys
from lib.exceptions import *
import subprocess

parser = argparse.ArgumentParser(prog="speciesgeocoder")
locality_group = parser.add_mutually_exclusive_group(required=True)
polygon_group = parser.add_mutually_exclusive_group(required=True)
polygon_group.add_argument("-p", "--polygons", help="Set path to file containing polygon coordinates")
polygon_group.add_argument("-s", "--shape", help="Set path to shape file containing polygons")
locality_group.add_argument("-l", "--localities", help="Set path to file containing species locality data")
locality_group.add_argument("-g", "--gbif", help="Set path to file containing species locality data downloaded from GBIF")
parser.add_argument("-t", "--tif", help="Set path to geotiff file(s)", nargs="*")
parser.add_argument("--plot", help="Produce graphical output illustrating coexistance, distribution etc.", action="store_true", default="False")
#parser.add_argument("-o", "--out", help="Name of optional output file. Output is sent to STDOUT by default")
parser.add_argument("-v", "--verbose", action="store_true", help="Report how many times a species is found in each polygon")
parser.add_argument("-b", "--binomial", action="store_true", help="Treats first two words in species names as genus name and species epithet. Use with care as this option is LIKELY TO LEAD TO ERRONEOUS RESULTS if names in input data are not in binomial form.")
parser.add_argument("-n", "--number", help="Set the minimum number of occurrences (localities) needed for considering a species to be present in a polygon", nargs="*")
parser.add_argument("--test", help="Test if the input data is in the right format", action="store_true")
parser.add_argument("--dev", help="Be extra verbose", action="store_true")
args = parser.parse_args()


class Polygons(object):
	# Object that contains all polygons.
	def __init__(self):
		self.polygonFile = args.polygons # [0]
		self.polygonNames = []
		for polygon in self.getPolygons():
			self.setPolygonNames(polygon[0])

	def getPolygons(self):
		try:
			f = open(self.polygonFile, "rU")
			lines = f.readlines()
		except IOError:
			sys.exit("[ Error ] No such file \'%s\'" % self.polygonFile)

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
						low = splitline[2].split("-")[0].rstrip("\n")
						high = splitline[2].split("-")[1].rstrip("\n")
					if ">" in splitline[2]:
						low = splitline[2].split(">")[1].rstrip("\n")
					if "<" in splitline[2]:
						high = splitline[2].split("<")[1].rstrip("\n")
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
		self.progress = 0
		for name in self.getLocalities():
			self.setSpeciesNames(name[0])

	def getLocalities(self):
		try:
			f = open(self.localityFile, "rU")
			lines = f.readlines()
		except IOError:
			sys.exit("[ Error ] No such file \'%s\'" % self.localityFile)
		for line in lines:
			if not line:
				break
			# Determine the Lat/Long column order
			if line[0] == "#":
				strings = ["Latitude", "latitude", "Lat.", "lat.", "Lat", "lat"]
				# Dev-note: Test for other delimiters than \t
				if line.split("\t")[1] not in strings:
					self.order = "long-lat"
				else:
					self.order = "lat-long"
				continue
			splitline = line.split("\t")

			if args.binomial:
				species = self.getBinomialName(splitline[0])
			else:
				species = splitline[0].strip()
			self.setSpeciesNames(species)
			try:
				latitude = splitline[1]
				longitude = splitline[2]
			except IndexError:
				sys.exit('[ Error ] The locality data file is not in tab delimited text format')
			yield species.replace("  ", " "), latitude, longitude
	
	def getCoOrder(self):
		return self.order

	def setSpeciesNames(self, name):
		if name not in self.speciesNames:
			self.speciesNames.append(name)

	def getSpeciesNames(self):
		return self.speciesNames

	def getLocalityFileName(self):
		return self.localityFile

	def getQuant(self):
		nr = 0
		for i in self.getLocalities():
			nr += 1
		return nr

class GbifLocalities(Localities):
	# Object that contains the locality data in the form
	# that is delivered from http://data.gbif.org 
	def __init__(self):
		self.gbifFile = args.gbif
		self.speciesNames = []
		for name in self.getLocalities():
			self.setSpeciesNames(name[0])

	def getLocalities(self):
		try:
			f = open(self.gbifFile, "rU")
			lines = f.readlines()
		except IOError:
			sys.exit("[ Error ] No such file \'%s\'" % self.polygonFile)

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
	# and alos described at http://geospatialpython.com/2011/01/point-in-polygon.html
	try:
		x = float(x)
	except:
		sys.stderr.write("[ Warning ] \'%s\' is not a number\n" % x)
	try:
		y = float(y)
	except:
		sys.stderr.write("[ Warning ] \'%s\' is not a number\n" % y)
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

	def getSpeciesNames(self):
		speciesNames = []
		for key in self.result:
			speciesNames.append(key)
		return speciesNames

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
				# If a minimum number of occurenses are required...
				if args.number:
					string = self.minOccurence(i, string)
				else:	
					string = self.verbose(i, string)
			else:
				string += "0"
		return string

	def minOccurence(self, occurences, string):
		if int(occurences) > int(args.number[0]):
			return self.verbose(occurences, string)
		else:
			string += "0" + "[" + str(occurences) + "]"
			return string

	def verbose(self, i, string):
		if args.verbose:
			string += "1" + "[" + str(i) + "]"
		else:
			string += "1"
		return string


def elevationTest(lat, lon, polygon, index):
	from lib.readGeoTiff import coordInTif	
	from lib.readGeoTiff import Geotiff
	if polygon[2] is None and polygon[3] is None:
		return True
	# Identify the correct tif file 
	correct_file = coordInTif(float(lon), float(lat), index)
	# The following two lines of code can be usefull if one 
	# wants to disregard the elevation limits if no elevation 
	# data is available for a particular area.

#	if not correct_file and polygon[2] == None:
#		return True	
	if correct_file:


		new_tiff = Geotiff(correct_file)
		elevation = new_tiff.get_elevation(lon.rstrip("\n"), lat.rstrip("\n"))

		if not polygon[2]:
			low = -1000					# A really low elevation.
		else:
			low = int(polygon[2])
		if not polygon[3]:
			high = 10000					# A really high elevation.
		else:
			high = int(polygon[3])
		return (low < elevation and elevation < high)
	else:
		# Notify the user that no elevation data is available for a locality.
		sys.stderr.write("[ Warning ] No elevation data available for locality %s, %s\n" % (lon.rstrip("\n"), lat.rstrip("\n")))
	
def main():
	# Create list to store the geotif objects in.
	done = 0
	polygons = Polygons()
	result = Result(polygons)
	# Index the geotiff files if appropriate.
	if args.tif:
		from lib.readGeoTiff import indexTiffs
		try:
			index = indexTiffs(args.tif)
		except AttributeError:
			sys.exit("[ Error ] No such file \'%s\'" % args.tif[0])
			
	# Read the locality data and test if the coordinates
	# are located in any of the polygons.
	# For each locality record ...
	if args.localities:
		localities = MyLocalities()
		numLoc = localities.getQuant()
		result.setSpeciesNames(localities)
		for locality in localities.getLocalities():
			# Print progress report to STDERR (Thanks Martin Zackrisson for code snippet)
			done += 1
			progress = (done/float(numLoc))*100
			sys.stderr.write("Point in polygon test: {0:.0f}%     \r".format(progress))
			# ... and for each polygon ...
			for polygon in polygons.getPolygons():
				# ... test if the locality record is found in the polygon.
				if localities.getCoOrder() == "lat-long":
					# locality[0] = species name, locality[1] = latitude, locality[2] =  longitude
					if pointInPolygon(polygon[1], locality[2], locality[1]) == True:

						# Test if elevation files are available.
						if args.tif:
							if elevationTest(locality[1], locality[2], polygon, index) == True:
								# Store the result
								result.setResult(locality[0], polygon[0])		
						else:
							# Store the result
							result.setResult(locality[0], polygon[0])
				else:
					# locality[0] = species name, locality[1] = longitude, locality[2] =  latitude
					if pointInPolygon(polygon[1], locality[1], locality[2]) == True:
						if args.tif:
							if elevationTest(locality[2], locality[1], polygon, index) == True:
								result.setResult(locality[0], polygon[0])
	
	if args.gbif:
		gbifData = GbifLocalities()
		result.setSpeciesNames(gbifData)
		# For each GBIF locality record ...
		for locality in gbifData.getLocalities():
#			done += 1

#			progress = (done/float(self.getQuant()))*100
#			sys.stderr.write("Progress: {0:.0f}%     \r".format(progress))

#			localities.getProgress(done)
			# ... and for each polygon ...
			for polygon in polygons.getPolygons():
				# ... test if the locality record is found in the polygon.
				if pointInPolygon(polygon[1], locality[2], locality[1]) == True:
					result.setResult(locality[0], polygon[0])
					
					# Test if elevation files are available.
					if args.tif:
						if elevationTest(locality[1], locality[2], polygon, index) == True:
							# Store the result
							result.setResult(locality[0], polygon[0])
						else:
							# Store the result
							result.setResult(locality[0], polygon[0])
						
	sys.stderr.write("\n")
	result.printNexus()

#	if args.plot == True:
#	### Go to R ###
#	### Do tests of cutoff values and call R + functions
#	### import rpy2
#		try:
#			import rpy2.robjects as ro
#		except:
#			sys.exit("[ Error ] rpy2 is not installed. Ploting the result will not be possible")
#		
#		# Write data to files that R can read.
#		for line in readlines():
#	
#		ro.r('source("R/SpeciesGeoCodeR.R")')






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
