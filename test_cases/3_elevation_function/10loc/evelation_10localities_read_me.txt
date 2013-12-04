Test case id: elevation_10localities

Goal: verify if the elevation function is working.  

Data: localities_10.txt [file with 10 localities], polygons_2large_elev.txt [file with 2 polygons equal 
in shape but different in the elevation parameter], tiff file with elevation data

Expected result: First, I will run the files without the elevation function. Then, I will use the elevation function. 
I'm expecting that the program will handle the analysis, but it will take longer to run with the elevation function. 
I will repeat this set of tests 3 times. 

Actual result:

**First time**
[calio@compute-0-4 ~]$ time phylogeocoder -l localities10.txt -p polygons_2large_elev.txt --test
[--] 'localities10.txt' passed all tests.
[--] 'polygons_2large_elev.txt' passed all tests.

real    0m0.188s
user    0m0.069s
sys     0m0.038s
[calio@compute-0-4 ~]$ time phylogeocoder -l localities10.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif --test
[--] 'localities10.txt' passed all tests.
[--] 'polygons_2large_elev.txt' passed all tests.

real    0m0.363s
user    0m0.257s
sys     0m0.042s
[calio@compute-0-4 ~]$ time phylogeocoder -l localities10.txt -p polygons_2large_elev.txt > result_10loc_no_elev1.nex

real    0m0.138s
user    0m0.061s
sys     0m0.043s
[calio@compute-0-4 ~]$ cat result_10loc_no_elev1.nex
#NEXUS

Begin data;
        Dimensions ntax=1 nchar=2;
        Format datatype=standard symbols="01" gap=-;
        CHARSTATELABELS
        1 Neotropics_low,
        2 Neotropics_mont;


        Matrix
Genusa_one              11
        ;
End;
[calio@compute-0-4 ~]$ time phylogeocoder -l localities10.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_10loc_elev1.nex

real    0m21.303s
user    0m5.451s
sys     0m13.679s
[calio@compute-0-4 ~]$ cat result_10loc_elev1.nex
#NEXUS

Begin data;
        Dimensions ntax=1 nchar=2;
        Format datatype=standard symbols="01" gap=-;
        CHARSTATELABELS
        1 Neotropics_low,
        2 Neotropics_mont;


        Matrix
Genusa_one              10
        ;
End;

**Second time**
[calio@compute-0-4 ~]$ time phylogeocoder -l localities10.txt -p polygons_2large_elev.txt > result_10loc_no_elev2.nex

real    0m0.162s
user    0m0.067s
sys     0m0.041s
[calio@compute-0-4 ~]$ cat result_10loc_no_elev2.nex
#NEXUS

Begin data;
        Dimensions ntax=1 nchar=2;
        Format datatype=standard symbols="01" gap=-;
        CHARSTATELABELS
        1 Neotropics_low,
        2 Neotropics_mont;


        Matrix
Genusa_one              11
        ;
End;
[calio@compute-0-4 ~]$ time phylogeocoder -l localities10.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_10loc_elev2.nex

real    0m20.954s
user    0m5.548s
sys     0m13.206s
[calio@compute-0-4 ~]$ cat result_10loc_elev2.nex
#NEXUS

Begin data;
        Dimensions ntax=1 nchar=2;
        Format datatype=standard symbols="01" gap=-;
        CHARSTATELABELS
        1 Neotropics_low,
        2 Neotropics_mont;


        Matrix
Genusa_one              10
        ;
End;

**Third time**
[calio@compute-0-4 ~]$ time phylogeocoder -l localities10.txt -p polygons_2large_elev.txt > result_10loc_no_elev3.nex

real    0m0.163s
user    0m0.074s
sys     0m0.033s
[calio@compute-0-4 ~]$ cat result_10loc_no_elev3.nex
#NEXUS

Begin data;
        Dimensions ntax=1 nchar=2;
        Format datatype=standard symbols="01" gap=-;
        CHARSTATELABELS
        1 Neotropics_low,
        2 Neotropics_mont;


        Matrix
Genusa_one              11
        ;
End;
[calio@compute-0-4 ~]$ time phylogeocoder -l localities10.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_10loc_elev3.nex

real    0m21.232s
user    0m5.433s
sys     0m13.620s
[calio@compute-0-4 ~]$ cat result_10loc_elev3.nex
#NEXUS

Begin data;
        Dimensions ntax=1 nchar=2;
        Format datatype=standard symbols="01" gap=-;
        CHARSTATELABELS
        1 Neotropics_low,
        2 Neotropics_mont;


        Matrix
Genusa_one              10
        ;
End;

Comment: The files passed the test function. The program coded the species correctly, and it took
a little longer to run with the elevation function when comparing the analysis with the same dataset,
but without the elevation function.


Summary:

		Without elevation	With elevation
First	real    0m0.138s	real    0m21.303s
		user    0m0.061s	user    0m5.451s
		sys     0m0.043s	sys     0m13.679s

Second	real    0m0.162s	real    0m20.954s
		user    0m0.067s	user    0m5.548s
		sys     0m0.041s	sys     0m13.206s

Third	real    0m0.163s	real    0m21.232s
		user    0m0.074s	user    0m5.433s
		sys     0m0.033s	sys     0m13.620s








