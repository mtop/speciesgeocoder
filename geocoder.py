#!/usr/bin/env python

#
# Input:	See the example files.
#

from optparse import OptionParser

# Figure out the options and arguments
def input(option, opt_str, value, parser):
	assert value is None
	value = []
	for arg in parser.rargs:
		# Stop on --foo like option
		if arg[:2] == "--" and len(arg) > 2:
			break
		# Stop on -a
		if arg[:1] == "-" and len(arg) > 1:
			break
		value.append(arg)
	del parser.rargs[:len(value)]
	setattr(parser.values, option.dest, value)

usage = "\n  %prog -p [Polygon_file] -l [Locality_data_file] -o [Optional_output_file]"
opts=OptionParser(usage=usage, version="%prog v.0.2")

opts.add_option("--polygons", "-p", dest="polygons", action="callback",
callback=input, help="Path to file containing polygon coordinates")

opts.add_option("--localities", "-l", dest="localities", action="callback",
callback=input, help="Path to file containig species locality data")

opts.add_option("--out", "-o", dest="output", action="callback",
callback=input, default=[None], help="Name of optional outputfile. Output is otherwise sent to STDOUT by default")

options, arguments = opts.parse_args()


class Polygons(object):
	# Object that contains all polygons.
	def __init__(self):
		self.polygonFile = options.polygons[0]
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
	# Object that contains the locality data,
	def __init__(self):
		self.localityFile = options.localities[0]
		self.speciesNames = []
		for name in self.getLocalities():
			self.setSpeciesNames(name[1])

	def getLocalities(self):
		f = open(self.localityFile)
		lines = f.readlines()
		for line in lines:
			if not line:
				break
			# Skip comments in the file
			if line[0] == "#":
				continue
			splitline = line.split()
			numbers = splitline[0]
			species = splitline[1] + ' ' + splitline[2]
			self.setSpeciesNames(species)
			longitude = splitline[3]
			latitude = splitline[4]
			yield numbers, species, longitude, latitude

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
	def __init__(self, polygons, localities):
		self.polygonNames =  polygons.getPolygonNames()
		self.speciesNames = localities.getSpeciesNames()
		# Create a dictionary where each key corresponds to 
		# a speceis names, and the values are initially lists
		# of zeros of the same length as the number of polygons. 
		self.emptyList = []
		for i in range(len(self.polygonNames)):
			self.emptyList.append(0)
		self.result = {}
		for name in self.speciesNames:
			self.result[name] = self.emptyList

	def getSpeciesNames(self):
		return self.speciesNames

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
			print name.replace(" ","_"), '\t', self.resultToStr(self.result[name])
		print '\t;'
		print 'End;'


	def resultToStr(self, resultList):
		string = ''
		for i in resultList:
			if i > 0:
				string += "1"
			else:
				string += "0"
		return string


def main():
	# Read the locality data and test if the coordinates 
	# are located in any of the polygons.
	polygons = Polygons()
	localities = Localities()
	result = Result(polygons, localities)
	# For each locality record ...
	for locality in localities.getLocalities():
		# ... and for each polygon ...
		for polygon in polygons.getPolygons():
			# ... test if the locality record is found in the polygon.
			# polygon[1] = species name, locality[2] = longitude, locality[3] = latitude
			if pointInPolygon(polygon[1], locality[2], locality[3]) == True:
				result.setResult(locality[1], polygon[0])

	result.printNexus()


if __name__ == "__main__":
	main()
#	polygons = Polygons()
#	for i in polygons.getPolygonNames():
#		print i
