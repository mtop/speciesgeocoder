#!/usr/bin/env python

def testLocality(localities, fileName):	
	result = []
	for locality in localities.getLocalities():
		for i in locality:
			# Check that the species names, first and second 
			# coordinate column only contains ASCII characters.
			try:
				i.decode('ascii')
			except UnicodeDecodeError:
				string = "[ Warning ] \'%s\' conains non-ascii characters" % locality[0]
				result.append(string)
				string = "	" + locality[0] + " " + locality[1] + " " + locality[2] + "\n"
				result.append(string)
	if result: 	
		print ""
		for string in result:
			print str(string)

def testPolygons(polygons, filename):
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
		print ""
		for string in result:
			print str(string)
		print ""
