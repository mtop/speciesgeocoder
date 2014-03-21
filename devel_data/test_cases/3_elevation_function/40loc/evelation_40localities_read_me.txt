Test case id: elevation_40localities

Goal: verify if the elevation function is working. Compare how long the analyses last when increasing the number of localites. 

Data: localities_40.txt [file with 40 localities], polygons_2large_elev.txt [file with 2 polygons equal 
in shape but different in the elevation parameter], tiff file with elevation data

Expected result: First, I will run the files without the elevation function. Then, I will use the elevation function. 
I'm expecting that the program will handle the analysis, but it will take longer to run with the elevation function. 
I will repeat this set of tests 3 times. 

Actual result:

**First time**
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities40.txt -p polygons_2large_elev.txt --test
[--] 'localities40.txt' passed all tests.
[--] 'polygons_2large_elev.txt' passed all tests.

real    0m35.122s
user    0m0.076s
sys     0m0.035s
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities40.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif --test
[--] 'localities40.txt' passed all tests.
[--] 'polygons_2large_elev.txt' passed all tests.

real    0m35.976s
user    0m0.255s
sys     0m0.053s
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities40.txt -p polygons_2large_elev.txt > result_40loc_no_elev1.nex

real    0m0.178s
user    0m0.083s
sys     0m0.036s
[calio@compute-0-4 elevation]$ cat result_40loc_no_elev1.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities40.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_40loc_elev1.nex

real    0m30.668s
user    0m9.396s
sys     0m19.101s
[calio@compute-0-4 elevation]$ cat result_40loc_elev1.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities40.txt -p polygons_2large_elev.txt > result_40loc_no_elev2.nex

real    0m0.177s
user    0m0.081s
sys     0m0.038s
[calio@compute-0-4 elevation]$ cat result_40loc_no_elev2.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities40.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_40loc_elev2.nex

real    0m29.980s
user    0m8.963s
sys     0m18.871s
[calio@compute-0-4 elevation]$ cat result_40loc_elev2.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities40.txt -p polygons_2large_elev.txt > result_40loc_no_elev3.nex

real    0m38.839s
user    0m0.086s
sys     0m0.042s
[calio@compute-0-4 elevation]$ cat result_40loc_no_elev3.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities40.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_40loc_elev3.nex

real    2m8.666s
user    0m8.990s
sys     0m18.682s
[calio@compute-0-4 elevation]$ cat result_40loc_elev3.nex
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

**Fourth**
[calio@compute-0-1 elevation]$ time phylogeocoder -l localities40.txt -p polygons_2large_elev.txt > result_40loc_no_elev4.nex

real    0m0.538s
user    0m0.076s
sys     0m0.046s
[calio@compute-0-1 elevation]$ cat  result_40loc_no_elev4.nex
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
[calio@compute-0-1 elevation]$ time phylogeocoder -l localities40.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_40loc_elev3.nex

real    8m52.420s
user    0m6.502s
sys     0m15.828s
[calio@compute-0-1 elevation]$ cat result_40loc_elev3.nex
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
but without the elevation function. I decided to run a fourth analysis because the time was increasing between the analyses.
It took almost 9 minutes to finish! Some time later I re-ran the analysis and it lasted about 30 seconds as the fisrt and second analyses.

Summary:

		Without elevation	With elevation
First	real    0m0.178s	real    0m30.668s
		user    0m0.083s	user    0m9.396s
		sys     0m0.036s	sys     0m19.101s

Second	real    0m0.177s	real    0m29.980s
		user    0m0.081s	user    0m8.963s
		sys     0m0.038s	sys     0m18.871s

Third	real    0m38.839s	real    2m8.666s
		user    0m0.086s	user    0m8.990s
		sys     0m0.042s	sys     0m18.682s

Fourth	real    0m0.538s	real    8m52.420s
		user    0m0.076s	user    0m6.502s	
		sys     0m0.046s	sys     0m15.828s






