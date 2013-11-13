#!/usr/bin/perl -w
use strict;

#ask for user input
unless (@ARGV) {print "Please give an input file"; exit;}

#open input file
open(FILE, "$ARGV[0]");

#for each line in the file do the following
while (<FILE>){
    #make a directory for which the name is the line in the file
    system("mkdir $_");
}
#close the file
close FILE;