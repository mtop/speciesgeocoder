Test case id: elevation_30localities

Goal: verify if the elevation function is working. Compare how long the analyses last when increasing the number of localites. 

Data: localities_30.txt [file with 30 localities], polygons_2large_elev.txt [file with 2 polygons equal 
in shape but different in the elevation parameter], tiff file with elevation data

Expected result: First, I will run the files without the elevation function. Then, I will use the elevation function. 
I'm expecting that the program will handle the analysis, but it will take longer to run with the elevation function. 
I will repeat this set of tests 3 times. 

Actual result:

**First time**
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities30.txt -p polygons_2large_elev.txt --test
[--] 'localities30.txt' passed all tests.
[--] 'polygons_2large_elev.txt' passed all tests.

real    0m0.158s
user    0m0.062s
sys     0m0.042s
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities30.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif --test
[--] 'localities30.txt' passed all tests.
[--] 'polygons_2large_elev.txt' passed all tests.

real    0m0.321s
user    0m0.246s
sys     0m0.051s
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities30.txt -p polygons_2large_elev.txt > result_30loc_no_elev1.nex

real    0m0.139s
user    0m0.070s
sys     0m0.042s
[calio@compute-0-4 elevation]$ cat result_30loc_no_elev1.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities30.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_30loc_elev1.nex

real    0m26.852s
user    0m7.805s
sys     0m16.906s
[calio@compute-0-4 elevation]$ cat result_30loc_elev1.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities30.txt -p polygons_2large_elev.txt > result_30loc_no_elev2.nex

real    0m0.172s
user    0m0.080s
sys     0m0.035s
[calio@compute-0-4 elevation]$ cat result_30loc_no_elev2.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities30.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_30loc_elev2.nex

real    0m26.967s
user    0m7.856s
sys     0m16.985s
[calio@compute-0-4 elevation]$ cat result_30loc_elev2.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities30.txt -p polygons_2large_elev.txt > result_30loc_no_elev3.nex

real    0m0.170s
user    0m0.072s
sys     0m0.041s
[calio@compute-0-4 elevation]$ cat result_30loc_no_elev3.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities30.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_30loc_elev3.nex

real    0m27.401s
user    0m7.962s
sys     0m17.341s
[calio@compute-0-4 elevation]$ cat result_30loc_elev3.nex
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
lasted about the same amount of time. It seems that adding 10 localities makes the analysis last 1-3 seconds more.

Summary:

		Without elevation	With elevation
First	real    0m0.139s	real    0m26.852s
		user    0m0.070s	user    0m7.805s
		sys     0m0.042s	sys     0m16.906s

Second	real    0m0.172s	real    0m26.967s
		user    0m0.080s	user    0m7.856s
		sys     0m0.035s	sys     0m16.985s

Third	real    0m0.170s	real    0m27.401s
		user    0m0.072s	user    0m7.962s
		sys     0m0.041s	sys     0m17.341s















