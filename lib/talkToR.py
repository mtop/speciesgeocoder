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

def stochastic_mapping(args, result):
	import os
	# Test if the tree file exists.
	try:
		open(args.tree, "r")
	except IOError:
		sys.exit("[Error] Unable to open tree file \"%s\"" % args.tree) 
	# Prepare the data for the stochastic mapping analysis.
	# occurences.sgc.txt
	out = open("occurences.sgc.txt", "w")
	# Headers
	header = "Species\t"
	for name in result.getPolygonNames():
		header += "%s\t" % name.replace(" ", "_")
	header += "\n"
	out.write(header)
	# Species names and character matrix
	for name in sorted(result.getResult()):
		string = "%s\t" % name.replace(" ", "_")
		for record in result.resultToStr(result.result[name]):
			string += "%s\t" % record
		string += "\n"
		out.write(string)
	out.close()

	wd = os.getcwd()  					# Working directory
	tbl_file = args.distribution_table	# Species distribution table from SpeciesGeoCoder
	tree_file = args.tree				# Tree file
	out_file = args.m_out				# Stem name output files. Default: "migration_plot"
	n_rep = args.n_rep					# Number of stochastic maps. Default: 100
	map_model = args.map_model			# Transition model, "ER", "SYM" or "ARD". Default: "SYM"
	max_run_time = args.max_run_time	# Max run time for 1 stochastic map (in seconds). Default: 60 sec. 
		                                # This limit does not apply to the first map
	trait= 0
	if args.dev == True:
		verbose = 'T'
	else:
		verbose = 'F'

	# launch R script
	cmd="Rscript R/map_migrations_times.R %s %s %s --o %s --m %s --r %s --s %s --d %s --t %s" \
	% (wd,tbl_file,tree_file,out_file,map_model,n_rep,max_run_time,verbose,trait)
	os.system(cmd)
