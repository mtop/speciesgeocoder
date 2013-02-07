geocoder
========

	Species locality data + polygons -> nexus file.

#   geocoder.py is a program written in Python that takes one file
#   containing polygons, and one file with species locality data
#   as input. The program then tests if a species have been recorded
#   inside any of the polygons. The result is presented as a nexux-
#   file with "0" indicating absence, and "1" indicating pressence
#   in a polygon.
#
#   Input:  See the example files localities.txt and polygons.txt.
#   Output:	See the example file ivesioids_out.nex.
