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

import sys,os

def parse_args(args):

	try:
		import argparse
	except ImportError:
		sys.stderr.write("[Error] The python module \"argparse\" is not installed\n")
		sys.stderr.write("[--] Would you like to install it now using 'sudo easy_install' [Y/N]? ")
		answer = sys.stdin.readline()
		if answer[0].lower() == "y":
			sys.stderr.write("[--] Running \"sudo easy_install argparse\"\n")
			from subprocess import call
			call(["sudo", "easy_install", "argparse"])
		else:
			sys.exit("[Error] Exiting due to missing dependency \"argparser\"")

	parser = argparse.ArgumentParser(prog="SpeciesGeoCoder")
	parser.add_argument('--version', action='version', version='%(prog)s 0.9.4')
	locality_group = parser.add_mutually_exclusive_group(required=True)
	#polygon_group = parser.add_mutually_exclusive_group(required=True)
	#polygon_group.add_argument("-p", "--polygons", help="Set path to file containing polygon coordinates")
	parser.add_argument("-p", "--polygons", help="Set path to file containing polygon coordinates", required=True)
	#polygon_group.add_argument("-s", "--shape", help="Set path to shape file containing polygons")
	locality_group.add_argument("-l", "--localities", help="Set path to file containing species locality data")
	locality_group.add_argument("-g", "--gbif", help="Set path to file containing species locality data downloaded from GBIF")
	parser.add_argument("-t", "--tif", help="Set path to geotiff file(s)", nargs="*")
	parser.add_argument("--plot", help="Produce graphical output illustrating coexistance, distribution etc.", action="store_true", default="False")
	
	### Stochastic mapping ###
	mapping_group = parser.add_argument_group('Stochastic_mapping')
	mapping_group.add_argument("--stochastic_mapping", help="Do stochastic mapping", action="store_true")
	#mapping_group.add_argument("--distribution_table", help="Path to species distribution table produced by SpeciesGeoCoder", default="occurences.sgc.txt")
	mapping_group.add_argument("--tree", help="Set path to NEXUS tree file")
	mapping_group.add_argument("--m_out", help="Name of the output file from the stochastic mapping analysis", default="Stochastic_mapping")
	mapping_group.add_argument("--n_rep", help="Number of stochastic maps", default=100)
	mapping_group.add_argument("--map_model", help="Transition model", choices=['ER', 'SYM', 'ARD'], default="ER") 
	mapping_group.add_argument("--max_run_time", help="Max run time for 1 stochastic map (in seconds).", default=60)
	mapping_group.add_argument("--trait", help="Trait >0 indicates the number of the character to be analyzed", default=0)
	
	parser.add_argument("-o", "--out", help="Name of optional output file. Output is sent to STDOUT by default")
	parser.add_argument("--tab", help="Output in tab-separated format", action="store_true", default="False")
	parser.add_argument("-v", "--verbose", action="store_true", help="Report how many times a species is found in each polygon. Don't use in combination with option '--number'")
	parser.add_argument("-b", "--binomial", action="store_true", help="Treats first two words in species names as genus name and species epithet. Use with care as this option is LIKELY TO LEAD TO ERRONEOUS RESULTS if names in input data are not in binomial form.")
	parser.add_argument("-n", "--number", help="Set the minimum number of occurrences (localities) needed for considering a species to be present in a polygon", nargs="*")
	parser.add_argument("--test", help="Test if the input data is in the right format", action="store_true")
	parser.add_argument("--dev", help=argparse.SUPPRESS, action="store_true")
	
	### GUI options ###
	parser.add_argument("--dir_output", help="Output directory for R plots", default=os.getcwd())
	parser.add_argument("--path_script", help=argparse.SUPPRESS, default=os.getcwd())
	
	return parser.parse_args(args)


class Polygons(object):
	# Object that contains polygons exported from QGIS.
	def __init__(self, args):
		self.polygonFile = args.polygons
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
			if line[:7].lower() == "polygon":
				low = None
				high = None
				# Identify the name of the polygon
				splitline = line.split('\t')
				name = splitline[1].rstrip()
				splitline[0] = splitline[0].replace(", ", ",")
				polygon = splitline[0].split("((", 1)[-1].rstrip("))").split(",")
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
					high = None
#				print name, polygon, low, high		# Devel.
				yield name, polygon, low, high

	def setPolygonNames(self, name):
		if name not in self.polygonNames:
			self.polygonNames.append(name)

	def getPolygonNames(self):
		return self.polygonNames


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

	def getQuant(self):
		# Return the number of localities
		nr = 0
		for i in self.getLocalities():
			nr += 1
		return nr


class MyLocalities(Localities):
	# Object that contains the locality data
	# read from a tab-delimited *.csv file.
	def __init__(self, args):
		self.args = args
		self.localityFile = self.args.localities # [0]
		self.speciesNames = []
		self.order = ""
		self.progress = 0
		for name in self.getLocalities():
			self.setSpeciesName(name[0])

	def getLocalities(self):
		try:
			f = open(self.localityFile, "rU")
			lines = f.readlines()
			if lines[0][0] == "#":
				pass
			else:
				sys.exit("[ Error ] \'%s\' does not start with a header line." % self.localityFile)
		except IOError:
			sys.exit("[ Error ] No such file \'%s\'" % self.localityFile)

		for line in lines:
			if not line:
				break
			# Determine the Lat/Long column order.
			if line[0] == "#":
				strings = ["Latitude", "latitude", "Lat.", "lat.", "Lat", "lat"]
				# Dev-note: Test for other delimiters then \t
				if line.split("\t")[1] not in strings:
					self.order = "long-lat"
				else:
					self.order = "lat-long"
				continue
			splitline = line.split("\t")

			if self.args.binomial:
				species = self.getBinomialName(splitline[0])
			else:
				species = splitline[0].strip()
			self.setSpeciesName(species)
			try:
				latitude = splitline[1]
				longitude = splitline[2]
			except IndexError:
				sys.exit('[ Error ] The locality data file is not in tab delimited text format')
			yield species.replace("  ", " "), latitude, longitude
	
	def getCoOrder(self):
		# Retur the order the localities are stored in input file
		return self.order

	def setSpeciesName(self, name):
		if name not in self.speciesNames:
			self.speciesNames.append(name)

	def getSpeciesNames(self):
		return self.speciesNames

	def getLocalityFileName(self):
		return self.localityFile

class GbifLocalities(Localities):
	# Object that contains the locality data in the form
	# that is delivered from http://data.gbif.org 
	def __init__(self, args):
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
			if len(line.split("\t")[77]) > 0 and len(line.split("\t")[78]) > 0:
				# Simple check if the names of the columns are sane
				if line.split("\t")[77] == "decimalLatitude" and line.split("\t")[78] == "decimalLongitude":
					continue
			try:
				float(line.split("\t")[77])
				float(line.split("\t")[78])
			except:
				continue
			# Under development.
#			if args.binomial:
#				species = self.getBinomialName(line.split("\t")[3])
#			else:
#				species = line.split("\t")[219]
			species = line.split("\t")[219]
			latitude = line.split("\t")[77]
			longitude = line.split("\t")[78]
			yield species.replace("  ", " "), latitude, longitude

	def setSpeciesNames(self, name):
		if name not in self.speciesNames:
			self.speciesNames.append(name)
	
	def getSpeciesNames(self):
		return self.speciesNames

	def getgbifFile(self):
		return self.gbifFile


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
		return False
	try:
		y = float(y)
	except:
		sys.stderr.write("[ Warning ] \'%s\' is not a number\n" % y)
		return False
	n = len(poly)
	inside = False
	p1x,p1y = poly[0].split(' ')
	p1x = float(p1x)
	p1y = float(p1y)
	for i in range(n+1):
		p2x = float('%s' % poly[i % n].split(' ')[0])
		p2y = float('%s' % poly[i % n].split(' ')[1])
		if y > min(p1y,p2y):
			if y <= max(p1y,p2y):
				if x <= max(p1x,p2x):
					if p1y != p2y:
						xinters = (y-p1y)*(p2x-p1x)/(p2y-p1y)+p1x
					if p1x == p2x or x <= xinters:
						inside = not inside
		p1x,p1y = p2x,p2y
	return inside


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
			low = -1000000					# A really low elevation.
		else:
			low = int(polygon[2])
		if not polygon[3]:
			high = 1000000					# A really high elevation.
		else:
			high = int(polygon[3])
		return (low <= elevation and elevation < high)
	else:
		# Notify the user that no elevation data is available for a locality.
		sys.stderr.write("[ Warning ] No elevation data available for locality %s, %s\n" % (lon.rstrip("\n"), lat.rstrip("\n")))

def print_progress(done, numLoc):
	# Print progress report to STDERR (Thanks Martin Zackrisson for code snippet)
	done += 1
	progress = (done/float(numLoc))*100
	sys.stderr.write("Point in polygon test: {0:.0f}%     \r".format(progress))
	return done

def main():
	from lib.result import Result
	# Create list to store the geotif objects in.
	polygons = Polygons(args)
	result = Result(polygons, args)
	done = 0
	# Index the geotiff files if available.
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
		localities = MyLocalities(args)
		numLoc = localities.getQuant()
		result.setSpeciesNames(localities)
		for locality in localities.getLocalities():
			done = print_progress(done, numLoc)
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
								result.setResult(locality, polygon[0])		
						else:
							# Store the result
							result.setResult(locality, polygon[0])
				else:
					# locality[0] = species name, locality[1] = longitude, locality[2] =  latitude
					if pointInPolygon(polygon[1], locality[1], locality[2]) == True:
						if args.tif:
							if elevationTest(locality[2], locality[1], polygon, index) == True:
								result.setResult(locality[0], polygon[0])
	
	if args.gbif:
		gbifData = GbifLocalities(args)
		result.setSpeciesNames(gbifData)
		numLoc = gbifData.getQuant()

		# For each GBIF locality record ...
		for locality in gbifData.getLocalities():
			done = print_progress(done, numLoc)
			# ... and for each polygon ...
			for polygon in polygons.getPolygons():
				# ... test if the locality record is found in the polygon.
				if pointInPolygon(polygon[1], locality[2], locality[1]) == True:
					result.setResult(locality, polygon[0])
					
					# Test if elevation files are available.
					if args.tif:
						if elevationTest(locality[1], locality[2], polygon, index) == True:
							# Store the result
							result.setResult(locality, polygon[0])
					else:
						# Store the result
						result.setResult(locality, polygon[0])
						
	sys.stderr.write("\n")

	# Print the output
	if args.tab == True:
		result.printTab(args)
	else:
		result.printNexus(args)


	if args.plot == True:
		import os
		from lib.plot import prepare_plots
		prepare_plots(result, polygons)
		#__ GUI STUFF
		dir_output = args.dir_output         # Working directory
		path_script = args.path_script
		cmd="Rscript %s/R/graphical_output.R %s %s %s %s %s %s" \
		% (path_script,path_script, "coordinates.sgc.txt", "polygons.sgc.txt", "sampletable.sgc.txt", "speciestable.sgc.txt",dir_output)
		
		os.system(cmd)


	if args.stochastic_mapping == True:
		import os
		import lib.stochasticMapping as stochasticMapping
		# Run the stochastic mapping analysis
		stochasticMapping.main(args, result)



if __name__ == "__main__":
	
	# Parse the command line arguments
	# Curticy of Viktor Kerkez (http://stackoverflow.com/questions/18160078/how-do-you-write-tests-for-the-argparse-portion-of-a-python-module)
	args = parse_args(sys.argv[1:])

	if args.test == True:
		if args.localities:
			from lib.testData import testLocality
			localities = MyLocalities(args)
			testLocality(localities, args.localities)

		if args.polygons:
			from lib.testData import testPolygons
			polygons = Polygons(args)
			testPolygons(polygons, args.polygons)

	else:
		if args.dev:
			import cProfile
			cProfile.run("main()")
		else:
			main()
