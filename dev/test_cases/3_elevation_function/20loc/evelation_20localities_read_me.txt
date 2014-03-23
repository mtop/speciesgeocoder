Test case id: elevation_20localities

Goal: verify if the elevation function is working. Compare how long the analyses last when increasing the number of localites. 

Data: localities_20.txt [file with 20 localities], polygons_2large_elev.txt [file with 2 polygons equal 
in shape but different in the elevation parameter], tiff file with elevation data

Expected result: First, I will run the files without the elevation function. Then, I will use the elevation function. 
I'm expecting that the program will handle the analysis, but it will take longer to run with the elevation function. 
I will repeat this set of tests 3 times. 

Actual result:

**First time**
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities20.txt -p polygons_2large_elev.txt --test
[--] 'localities20.txt' passed all tests.
[--] 'polygons_2large_elev.txt' passed all tests.

real    0m0.158s
user    0m0.055s
sys     0m0.050s
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities20.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif --test
[--] 'localities20.txt' passed all tests.
[--] 'polygons_2large_elev.txt' passed all tests.

real    0m0.337s
user    0m0.263s
sys     0m0.047s
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities20.txt -p polygons_2large_elev.txt > result_20loc_no_elev1.nex

real    0m0.137s
user    0m0.076s
sys     0m0.032s
[calio@compute-0-4 elevation]$ cat result_20loc_no_elev1.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities20.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_20loc_elev1.nex

real    0m23.554s
user    0m6.485s
sys     0m14.962s
[calio@compute-0-4 elevation]$ cat result_20loc_elev1.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities20.txt -p polygons_2large_elev.txt > result_20loc_no_elev2.nex

real    0m0.166s
user    0m0.073s
sys     0m0.038s
[calio@compute-0-4 elevation]$ cat result_20loc_no_elev2.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities20.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_20loc_elev2.nex

real    0m23.708s
user    0m6.548s
sys     0m15.043s
[calio@compute-0-4 elevation]$ cat result_20loc_elev2.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities20.txt -p polygons_2large_elev.txt > result_20loc_no_elev3.nex

real    0m0.165s
user    0m0.076s
sys     0m0.034s
[calio@compute-0-4 elevation]$ cat result_20loc_no_elev3.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities20.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_20loc_elev3.nex

real    0m24.263s
user    0m6.692s
sys     0m15.473s
[calio@compute-0-4 elevation]$ cat result_20loc_elev3.nex 
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
but without the elevation function. The analyses with 10 (see test case with 10 localities) and 20 localities 
lasted about the same amount of time.


Summary:

		Without elevation	With elevation
First	real    0m0.137s	real    0m23.554s
		user    0m0.076s	user    0m6.485s
		sys     0m0.032s	sys     0m14.962s
		
Second	real    0m0.166s	real    0m23.708s
		user    0m0.073s	user    0m6.548s
		sys     0m0.038s	sys     0m15.043s

Third	real    0m0.165s	real    0m24.263s
		user    0m0.076s	user    0m6.692s
		sys     0m0.034s	sys     0m15.473s












