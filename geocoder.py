#!/usr/bin/env python
# -*- coding: utf-8 -*-

#	geocoder.py is a program written in Python that takes one file 
#	containing polygons, and one file with species locality data 
#	as input. The program then tests if a species have been recorded 
#	inside any of the polygons. The result is presented as a nexus- 
#	file with "0" indicating absence, and "1" indicating presence of
#	a species in a polygon.
#
# 	Input:	See the example files localities.txt and polygons.txt. 
# 	Output: 	See the example file ivesioids_out.nex.

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

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--polygons", help="Path to file containing polygon coordinates")
parser.add_argument("-l", "--localities", help="Path to file containing species locality data")
parser.add_argument("-g", "--gbif", help="Path to file containing species locality data downloaded from GBIF")
parser.add_argument("-o", "--out", help="Name of optional output file. Output is sent to STDOUT by default")
parser.add_argument("-v", "--verbose", action="store_true", help="Also report the number of times a species is found in a particular polygon")
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
			if not line:
				break
			splitline = line.split(':')
			name = splitline[0]
			self.setPolygonNames(name)
			polygon = self.prepare_poly(splitline[1])
			yield name, polygon

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
	# Object that contains the locality data
	# read from a tab-delimited *.csv file.
	def __init__(self):
		self.localityFile = args.localities # [0]
		self.speciesNames = []
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
			species = splitline[0]  # + ' ' + splitline[2]
			self.setSpeciesNames(species)
			latitude = splitline[1]
			longitude = splitline[2]
			yield species, latitude, longitude
	
	def getCoOrder(self):
		return self.order

	def setSpeciesNames(self, name):
		if name not in self.speciesNames:
			self.speciesNames.append(name)

	def getSpeciesNames(self):
		return self.speciesNames

class GbifLocalities(object):
	# Object that contains the locality data in the form
	# that is delivered from http://data.gbif.org 
	def __init__(self):
		self.gbifFile = args.gbif
		self.speciesNames = []
		for name in self.getLocalities():
			self.setSpeciesNames(name)	# [1]

	def getLocalities(self):
		f = open(self.gbifFile)
		lines = f.readlines()
		for line in lines:
			if line.split("\t")[5] and line.split("\t")[6]:
				if line.split("\t")[5] == "Latitude":
					continue
			else:
				species = line.split("\t")[3]
				latitude = line.split("\t")[5]
				longitude = line.split("\t")[6]
				yield species, latitude, longitude

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

	x = float(x)
	y = float(y)
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
		for name in self.getResult():
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

class MyResult(Result): #, localities, polygons):
	def __init__(self, localities, polygons):
		self.speciesNames = localities.getSpeciesNames()
		self.polygonNames =  polygons.getPolygonNames()
#		self.result = {}

class GbifResult(Result):
	def __init__(self, gbifData, polygons):
		self.speciesNames = gbifData.getSpeciesNames()
#		self.result = {}


def main():
	# Read the locality data and test if the coordinates 
	# are located in any of the polygons.
	polygons = Polygons()
#	result = Result(polygons, localities)
	result = Result(polygons)
	# For each locality record ...
	if args.localities:
		localities = Localities()
		result.setSpeciesNames(localities)
#		localities = Localities()
		for locality in localities.getLocalities():
			# ... and for each polygon ...
			for polygon in polygons.getPolygons():
				# ... test if the locality record is found in the polygon.
				if localities.getCoOrder() == "lat-long":
					# locality[0] = species name, locality[1] = latitude, locality[2] =  longitude
					if pointInPolygon(polygon[1], locality[2], locality[1]) == True:
#						print result.getSpeciesNames()
						result.setResult(locality[0], polygon[0])
				else:
					# locality[0] = species name, locality[1] = longitude, locality[2] =  latitude
					if pointInPolygon(polygon[1], locality[1], locality[2]) == True:
						result.setResult(locality[0], polygon[0])
	
	if args.gbif:
#		gbifData = GbifLocalities()
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
#	polygons = Polygons()
#	for i in polygons.getPolygonNames():
#		print i
