Test case id: elevation_50localities

Goal: verify if the elevation function is working. Compare how long the analyses last when increasing the number of localites. 

Data: localities_50.txt [file with 50 localities], polygons_2large_elev.txt [file with 2 polygons equal 
in shape but different in the elevation parameter], tiff file with elevation data

Expected result: First, I will run the files without the elevation function. Then, I will use the elevation function. 
I'm expecting that the program will handle the analysis, but it will take longer to run with the elevation function. 
I will repeat this set of tests 3 times. 

Actual result:

**First time**
calio@compute-0-4 elevation]$ time phylogeocoder -l localities50.txt -p polygons_2large_elev.txt --test
[--] 'localities50.txt' passed all tests.
[--] 'polygons_2large_elev.txt' passed all tests.

real    0m0.150s
user    0m0.067s
sys     0m0.037s
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities50.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif --test
[--] 'localities50.txt' passed all tests.
[--] 'polygons_2large_elev.txt' passed all tests.

real    0m0.326s
user    0m0.255s
sys     0m0.043s
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities50.txt -p polygons_2large_elev.txt > result_50loc_no_elev1.nex

real    0m0.177s
user    0m0.082s
sys     0m0.041s
[calio@compute-0-4 elevation]$ cat result_50loc_no_elev1.nex
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
[calio@compute-0-4 elevation]$ time phylogeocoder -l localities50.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_50loc_elev1.nex

{{{{The analysis ran for more than 5 hours, but it didn't end. I stopped it}}}}


**Second time**
[calio@compute-0-1 ~]$ time phylogeocoder -l localities50.txt -p polygons_2large_elev.txt > result_50loc_no_elev2.nex

real    0m0.981s
user    0m0.079s
sys     0m0.053s
[calio@compute-0-1 ~]$ cat result_50loc_no_elev2.nex
#NEXUS

Begin data;
	Dimensions ntax=1 nchar=2;
	Format datatype=standard symbols="01" gap=-;
	CHARSTATELABELS
	1 Neotropics_low,
	2 Neotropics_mont;


	Matrix
Genusa_one 		11
	;
End;
[calio@compute-0-1 ~]$ time phylogeocoder -l localities50.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_50loc_elev2.nex

{{{{The analysis ran for more than 5 hours, but it didn't end. I stopped it}}}}


**Third time**
[calio@compute-0-1 ~]$ time phylogeocoder -l localities50.txt -p polygons_2large_elev.txt > result_50loc_no_elev3.nex

real    0m2.012s
user    0m0.090s
sys     0m0.052s
[calio@compute-0-1 ~]$ cat result_50loc_no_elev3.nex
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
[calio@compute-0-1 ~]$ time phylogeocoder -l localities50.txt -p polygons_2large_elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result_50loc_elev3.nex

{{{{The analysis ran for more than 5 hours, but it didn't end. I stopped it}}}}


Comment: The files passed the test function. The analyses with the elevation function were taking too long to finish, so I ended them.


		Without elevation	With elevation
First	real    0m0.177s	No results
		user    0m0.082s
		sys     0m0.041s

Second	real    0m0.981s	No results
		user    0m0.079s
		sys     0m0.053s
		
Third	real    0m2.012s	No results
		user    0m0.090s
		sys     0m0.052s












