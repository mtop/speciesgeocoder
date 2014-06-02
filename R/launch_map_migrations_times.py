#!/usr/bin/env python 
# Created by Daniele Silvestro on 29/05/2014
import os 

############## @MATS: these are the variables that need to be passed by the user/SpeciesGeoCoder
wd            = "/Users/daniele/Desktop/map_migration_time/"  # working directory where input files (table and tree) are and output will be saved
tbl_file      = "CAHighlands_SA.txt"                              # species distribution table from SpeciesGeoCoder
tree_file     = "1birdtree.nex"                               # tree file
out_file      = "migration_plot_CAH_SA"                              # Stem name output files. Default: "migration_plot"
n_rep         = 3                                             # Number of stochastic maps. Default: 100
map_model     = "ARD"                                         # Transition model, here are the options: "ER", "SYM", "ARD". Default: "SYM"
max_run_time  = 60                                            # Max run time for 1 stochastic map (in seconds). Default: 60 sec. 
                                                              # The limit does not apply to the first map


# launch R script
print "\nThe following R libraries are required: ape, phytools, geiger, optparse.\n"
cmd="cd %s; Rscript map_migrations_times.R %s %s %s --o %s --m %s --r %s --s %s" \
% (wd,wd,tbl_file,tree_file,out_file,map_model,n_rep,max_run_time)
os.system(cmd)

