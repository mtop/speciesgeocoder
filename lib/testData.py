#!/usr/bin/env python
# -*- coding: utf-8 -*-

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

def testLocality(localities, fileName):	
	result = []
	for locality in localities.getLocalities():
		for i in locality:
			# Check that the species names, first and second 
			# coordinate column only contains ASCII characters.
			try:
				i.decode('ascii')
			except UnicodeDecodeError:
				string = "[ Warning ] A problem was detected on row [" + locality[0] + " " + locality[1] + " " + locality[2] + "]"
				result.append(string)
				string = "[ Warning ] \'%s\' contains non-ascii characters" % i
				result.append(string)

		# Check that the coordinates only contains legal characters 
		# and hence can be converted to a floating point number.
		try:
			float(locality[1])
		except:
			string =  "[ Error ]   \'%s\' is not a decimal number." % locality[1]
			result.append(string)
			

	if result: 	
		for string in result:
			print str(string)
	else:
		print "[--] \'%s\' passed all tests." % fileName

def testPolygons(polygons, fileName):
	result = []
	for polygon in polygons.getPolygons():
		for i in polygon[0]:				# polygon[0] = Polygon name
			try:
				i.decode('ascii')
			except UnicodeDecodeError:
				string = "[ Warning ] \'%s\' conains non-ascii characters" % polygon[0]
				result.append(string)
				break

		for latLong in polygon[1]:
			x, y = latLong.split(",")
			try:
				float(x)
				float(y)
			except:
				string = "[ Error ] Detected an error with coordinate pair \'%s\' in polygon \'%s\'" % (latLong, polygon[0])
				result.append(string)

		# Test lower elevation boundary, if present.	
		if polygon[2]:
			try:
				float(polygon[2])
			except:
				string = "[ Error ] Detected an error with elevation limit \'%s\' for polygon \'%s\'" % (polygon[2], polygon[0])
				result.append(string)

		# Test high elevation boundary, if present.
		if polygon[3]:
			try:
				float(polygon[3])
			except:
				strint = "[ Error ] Detected an error with elevation limit \'%s\' for polygon \'%s\'" % (polygon[3], polygon[0])
				result.append(string)

			

	if result:
		for string in result:
			print str(string)
	else:
		print "[--] \'%s\' passed all tests." % fileName
