#!/usr/local/opt/python/bin/python2.7

import operator

def joinResults(finalResult, result_objects):
	for result in result_objects:
		# Jumpstart the Results instance with a list of the analyses species.
		finalResult.setSpeciesNames(result)

		for species, value in result.getResult().iteritems():
			finalResult.result[species] = map(operator.add, finalResult.result[species], value)

###			finalResult.combineResults(species, value)

