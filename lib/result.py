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

import sys

class Result(object):
	def __init__(self, polygons, args):
		self.polygonNames =  polygons.getPolygonNames()
		self.args = args
		# Table to store info on which polygon a certain record was coded in
		self.sampletable = []
		
		if args.out is None:
			self.OUTHANDLE = sys.stdout
		else:
	#		self.OUTHANDLE = open(outputfile, 'w')
			self.OUTHANDLE = open(args.out, 'w')



	
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
			# Make sure the species name is not empty
			if name not in self.result and len(name) > 0:
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

	def setResult(self, Locality, polygonName):
		# Make sure the record has a species name associated with it
		if len(Locality[0]) > 0:
			list = self.result[Locality[0]]
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
			self.result[Locality[0]] = newList
			self.sampletable.append((Locality[0], polygonName, Locality[2], Locality[1]))
	
	def getSampletable(self):
		return self.sampletable

	def getResult(self):
		return self.result

	def polygonNumber(self, polygonName):
		return self.polygonNames.index(polygonName)

	def printNexus(self, args): #outputfile=None):
#		if outputfile is None:
#			OUTHANDLE = sys.stdout
#               else:
#			OUTHANDLE = open(outputfile, 'w')

		self.OUTHANDLE.write("#NEXUS\n\n")
		self.OUTHANDLE.write("Begin data;\n")
		self.OUTHANDLE.write("\tDimensions ntax=%s nchar=%s;\n" % (len(self.getSpeciesNames()), len(self.getPolygonNames())))
		self.OUTHANDLE.write("\tFormat datatype=standard symbols=\"01\" gap=-;\n")
		self.OUTHANDLE.write("\tCHARSTATELABELS\n")

		# Print the names of the polygons
		polygons = self.getPolygonNames()
		for i, name in enumerate(polygons):
			separator = ','
			# End the CHARSTATELABLES section in case it's the last polygon
			if i+1 == len(polygons):
				separator = ';'
			self.OUTHANDLE.write("\t%s %s%s\n" % (i+1, name, separator))
		self.OUTHANDLE.write("\n\n")

		self.OUTHANDLE.write("\tMatrix\n")
		# Print the species names and character matrix
		for name in sorted(self.getResult()):
			self.OUTHANDLE.write("%s \t\t%s\n" % (name.replace(" ", "_"), self.resultToStr(self.result[name])))
		self.OUTHANDLE.write("\t;\nEnd;\n")

		if args.out is not None:
			self.OUTHANDLE.close()

	def printTab(self, args):
		# Generate the header line
		header = "Species name"
		for name in self.getPolygonNames():
			header += "\t"
			header += name
		header += "\n"
		self.OUTHANDLE.write(header) 

		# Print the result
		for species in self.getResult():
			row = species
			if not args.verbose:
				for value in self.resultToStr(self.result[species]):
					row += "\t"
					row += value
				self.OUTHANDLE.write("%s%s" % (row, "\n"))
			else:
				
				print self.resultToStr(self.result[species])		# Devel.
		
		if args.out is not None:
			self.OUTHANDLE.close()

		


	def resultToStr(self, resultList):
		string = ''
		for i in resultList:
			if i > 0:
				# If a minimum number of occurenses are required...
				if self.args.number:
					string = self.minOccurence(i, string)
				else:	
					string = self.verbose(i, string)
			else:
				string += "0"
#		print "String: ", string								# Devel.
		return string

	def minOccurence(self, occurences, string):
		if int(occurences) > int(self.args.number[0]):
			return self.verbose(occurences, string)
		else:
			string += "0" + "[" + str(occurences) + "]"
			return string

	def verbose(self, occurences, string):
		if self.args.verbose:
			# The tab-delimited format requires an additional "\t" character
			if self.args.tab == True:
				string += "1" + "[" + str(occurences) + "]\t"
			else:
				string += "1" + "[" + str(occurences) + "]"
		else:
			string += "1"
		return string

#	def setSampletable(self, locality, polygon):
#		locality
