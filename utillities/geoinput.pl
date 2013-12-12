#!/usr/bin/perl -w
use strict;

#ask for user input
unless (@ARGV) {print "Please give an input 1 and input 2 and output file name"; exit;}

#open file
open(FILE, "$ARGV[0]");
open(FILE2, ">$ARGV[1]");

#set scalar variable to be used later to ?
my $poly = "?";
my $name = "?";

#for every line in the file do the following:
while (<FILE>) {
    # if a line has a polygon extract the polygon and the polygon name
    if ($_ =~ m%.*POLYGON\(\((.+)\)\).*\t(.+)%){
        $poly = $1;
        $name = $2;
    }
    
    #reformat the polygon from qgis output to geocoder input
    if ($poly ne "?") {
        $poly =~ s/,/;/g;
        $poly =~ s/\s/,/g;
        $poly =~ s/;/ /g;
    }
    #if polygon and name are present print them to file and reset the values to ?
    if ($poly ne "?" and $name ne "?") {
        print FILE2 "$name: $poly\n";
        $poly = "?";
        $name = "?";
    }
    

}

#close files
close FILE;
close FILE2;