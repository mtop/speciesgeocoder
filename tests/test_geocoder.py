#!/usr/local/opt/python/bin/python2.7

from os import sys, path
sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))
import pytest
import geocoder
import SGC_output

version = "SpeciesGeoCoder 0.9.4\n"

class TestParser:

	def test_version(self, capsys):
		with pytest.raises(SystemExit):
			args = geocoder.parse_args(['--version'])
		out, err = capsys.readouterr()
		assert err == version

class TestClass:
	
	def setup_args(self):
		return geocoder.parse_args(['-p', 'example_data/polygons.txt', '-l', 'example_data/localities.csv'])

	def setup_args2(self):
		return geocoder.parse_args(['-p', 'example_data/polygons.txt', '-g', 'example_data/gbif_Ivesia_localities.txt'])

class TestClassPolygons(TestClass):
	# Test the class Polygons and at the same time the polygon file

	def setup_TestPolygons(self):
		self.args = self.setup_args()
		self.TestPolygons = geocoder.Polygons(self.args)
		self.polygon = list(self.TestPolygons.getPolygons())

	def loop_over_polygons(self, position):
		for item in self.polygon:
			nr = 0
			assert self.polygon[nr][position] == SGC_output.polygons[nr][position]
			nr += 1

	def test_number_of_polygons(self):
		# Test number of polygons in input file
		self.setup_TestPolygons()
		assert len(self.polygon) == 8
		
	def test_polygonNames(self):
		# Test names of polygons
		self.setup_TestPolygons()
		# Test first list that only contains the polygon names
		assert self.TestPolygons.polygonNames == SGC_output.polygonNames

		self.loop_over_polygons(position=0)

	def test_polygons(self):
		# Test the polygons
		self.setup_TestPolygons()
		self.loop_over_polygons(position=1)

	def test_low(self):
		# Test the low value of the elevation range
		self.setup_TestPolygons()
		self.loop_over_polygons(position=2)

	def test_high(self):
		# Test the high value of the elevation range
		self.setup_TestPolygons()
		self.loop_over_polygons(position=3)
	
	def test_setPolygonNames(self):
		# Again test the list that only contains the names of the polygons
		self.setup_TestPolygons()
		self.TestPolygons.setPolygonNames('New_Polygon')
		assert self.TestPolygons.polygonNames == SGC_output.modified_polygonNames

	def test_getPolygonNames(self):
		self.setup_TestPolygons()
		assert self.TestPolygons.getPolygonNames() == SGC_output.polygonNames

class TestClassMyLocalities(TestClass):
	
	def setup_TestMyLocalities(self):
		self.args = self.setup_args()
		self.TestMyLocalities = geocoder.MyLocalities(self.args)
	
	def test_speciesNames(self):
# Perhaps redundant
		# Test species names
        	self.setup_TestMyLocalities()
        	# Test first list that only contains the species names
        	assert self.TestMyLocalities.speciesNames == SGC_output.speciesNames

	def test_getLocalities(self):
		self.setup_TestMyLocalities()
		assert list(self.TestMyLocalities.getLocalities()) == SGC_output.localities

	def test_getCoOrder(self):
		self.setup_TestMyLocalities()
		assert self.TestMyLocalities.getCoOrder() == 'lat-long'

	def test_setSpeciesNames(self):
		self.setup_TestMyLocalities()
		self.TestMyLocalities.setSpeciesName('New Species')
		assert self.TestMyLocalities.speciesNames == SGC_output.modified_speciesNames

	def test_getSpeciesNames(self):
		self.setup_TestMyLocalities()
		assert self.TestMyLocalities.getSpeciesNames() == SGC_output.speciesNames

	def test_getLocalityFileName(self):
		self.setup_TestMyLocalities()
		assert self.TestMyLocalities.getLocalityFileName() == 'example_data/localities.csv'
	
	def test_getBinomialName(self):
		self.setup_TestMyLocalities()
		assert self.TestMyLocalities.getBinomialName('New species name') == 'New species'
		assert self.TestMyLocalities.getBinomialName('New species with name') == 'New species'
# Perhaps something to implement
#		assert self.TestMyLocalities.getBinomialName('New_species + name') == 'New species'

	def test_getQuant(self):
		self.setup_TestMyLocalities()
		assert self.TestMyLocalities.getQuant() == 571


class TestGbifLocalities(TestClass):

	def setup_TestGbifLocalities(self):
		self.args = self.setup_args2()
		self.TestGbifLocalities = geocoder.GbifLocalities(self.args)

	def test_getLocalities(self):
		self.setup_TestGbifLocalities()
		assert list(self.TestGbifLocalities.getLocalities()) == SGC_output.gbifLocalities

	def test_setSpeciesNames(self):
		pass

	def test_getSpeciesNames(self):
		self.setup_TestGbifLocalities()
#		print self.TestGbifLocalities.getSpeciesNames()
		assert self.TestGbifLocalities.getSpeciesNames() == SGC_output.gbifSpeciesNames

	def test_getgbifFile(self):
		self.setup_TestGbifLocalities()
		assert self.TestGbifLocalities.getgbifFile() == 'example_data/gbif_Ivesia_localities.txt'

	def test_getQuant(self):
		self.setup_TestGbifLocalities()
		assert self.TestGbifLocalities.getQuant() == 3458


class TestPointInPolygon:

	def test_(self):
		pass
