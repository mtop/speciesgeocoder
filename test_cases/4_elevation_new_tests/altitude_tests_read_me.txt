####Test1####
#Localities file: occurenceSouthAmerica1000.txt = 1000 points simulated by Ruud for South America, including points that occur over the ocean
#Polygons file: southamerica_without_altitude.txt = 2 polygons that are equal in shape and cover the exact same area, without differentiating altitude ranges
#Expected result: all points will be coded for both polygons
#Actual result:

screen -S test_locSA1thou_pol2new_noalt
qlogin

[calio@compute-0-4 ~]$ time phylogeocoder -l /usr/local/db/speciesgeocoder/preformancetests/occurenceSouthAmerica1000.txt -p /usr/local/db/speciesgeocoder/preformancetests/southamerica_without_altitude.txt -v > result_1000lSA_2p_noalt.nex
Point in polygon test: 100%

real    0m0.647s
user    0m0.256s
sys     0m0.122s

[calio@compute-0-4 ~]$ cat result_1000lSA_2p_noalt.nex
#NEXUS

Begin data;
	Dimensions ntax=1 nchar=2;
	Format datatype=standard symbols="01" gap=-;
	CHARSTATELABELS
	1 South_america_a,
	2 South_america_b;


	Matrix
species 		1[1000]1[1000]
	;
End;

#Comment: It worked as expected.



####Test2####
#Localities file: occurenceSouthAmerica1000.txt = 1000 points simulated by Ruud for South America, including points that occur over the ocean
#Polygons file: southamerica_without_altitude.txt = 2 polygons that are equal in shape and cover the exact same area, but they are different in the altitude range (one below 500m and the other above 500m)
#Tiff file: elevation with 250 m resolution
#Expected result: some points will be coded for one polygon and some points will be coded for the other polygon
#Actual result:

screen -S test_locSA1thou_pol2new_alt30
qlogin

[calio@compute-0-4 ~]$ time phylogeocoder -l /usr/local/db/speciesgeocoder/preformancetests/occurenceSouthAmerica1000.txt -p /usr/local/db/speciesgeocoder/preformancetests/southamerica2altitude_new.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif -v > result_1000lSA_2p_30t.nex

Indexing tiff files: 100%
Point in polygon test: 100%

real    17m52.707s
user    0m19.843s
sys     0m44.819s

[calio@compute-0-4 ~]$ cat result_1000lSA_2p_30t.nex
#NEXUS

Begin data;
        Dimensions ntax=1 nchar=2;
        Format datatype=standard symbols="01" gap=-;
        CHARSTATELABELS
        1 South_america_below_500,
        2 South_america_above_500;


        Matrix
species                 1[333]0
        ;
End;

#Comment: Only one third of all points were actually coded, and all of them in only one of the polygons.


####Test3####
#Localities file: occurrenceFE.txt = 1000 points from my own dataset for South America; all points occur on land and cover different areas in South America
#Polygons file: southamerica_without_altitude.txt = 2 polygons that are equal in shape and cover the exact same area, without differentiating altitude ranges [same polygons used in test 1]
#Expected result: all points will be coded for both polygons
#Actual result:

screen -S test_locFE1thou_pol2new_noalt
qlogin

[calio@compute-0-1 ~] time phylogeocoder -l /usr/local/db/speciesgeocoder/preformancetests/occurrenceFE.txt -p /usr/local/db/speciesgeocoder/preformancetests/southamerica_without_altitude.txt -v > result_1000lFE_2p_noalt.nex
Point in polygon test: 100%     

real    0m0.653s
user    0m0.327s
sys     0m0.067s


#NEXUS

Begin data;
	Dimensions ntax=25 nchar=2;
	Format datatype=standard symbols="01" gap=-;
	CHARSTATELABELS
	1 South_america_a,
	2 South_america_b;


	Matrix
Species_a 		1[200]1[200]
Species_b 		1[131]1[131]
Species_c 		1[20]1[20]
Species_d 		1[47]1[47]
Species_e 		1[27]1[27]
Species_f 		1[116]1[116]
Species_g 		1[72]1[72]
Species_h 		1[17]1[17]
Species_i 		1[10]1[10]
Species_j 		1[35]1[35]
Species_k 		1[79]1[79]
Species_l 		1[53]1[53]
Species_m 		1[36]1[36]
Species_n 		1[3]1[3]
Species_o 		1[19]1[19]
Species_p 		1[5]1[5]
Species_q 		1[23]1[23]
Species_r 		1[2]1[2]
Species_s 		1[5]1[5]
Species_t 		1[2]1[2]
Species_u 		1[21]1[21]
Species_v 		1[35]1[35]
Species_x 		1[7]1[7]
Species_y 		1[31]1[31]
Species_z 		1[4]1[4]
	;
End;

#Comment: It worked as expected.


####Test4####
#Localities file: occurrenceFE.txt = 1000 points from my own dataset for South America; all points occur on land and cover different areas in South America
#Polygons file: southamerica_without_altitude.txt = 2 polygons that are equal in shape and cover the exact same area, but they are different in the altitude range (one below 500m and the other above 500m) [same polygons used in test 2]
#Tiff file: elevation with 250 m resolution
#Expected result: some points will be coded for one polygon and some points will be coded for the other polygon
#Actual result:

screen -S teste_locFE1thou_pol2new_alt30
qlogin

[calio@compute-0-1 ~] time phylogeocoder -l /usr/local/db/speciesgeocoder/preformancetests/occurrenceFE.txt -p /usr/local/db/speciesgeocoder/preformancetests/southamerica2altitude_new.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif -v > result_1000lFE_2p_30t.nex
Indexing tiff files: 100%
Point in polygon test: 100%     

real    13m51.450s
user    0m39.402s
sys     1m12.629s

[calio@compute-0-1 ~] $ cat result_1000lFE_2p_30t.nex
#NEXUS

Begin data;
	Dimensions ntax=25 nchar=2;
	Format datatype=standard symbols="01" gap=-;
	CHARSTATELABELS
	1 South_america_below_500,
	2 South_america_above_500;


	Matrix
Species_a 		1[200]0
Species_b 		1[131]0
Species_c 		1[20]0
Species_d 		1[47]0
Species_e 		1[27]0
Species_f 		1[116]0
Species_g 		1[72]0
Species_h 		1[17]0
Species_i 		1[10]0
Species_j 		1[35]0
Species_k 		1[79]0
Species_l 		1[53]0
Species_m 		1[36]0
Species_n 		1[3]0
Species_o 		1[19]0
Species_p 		1[5]0
Species_q 		1[23]0
Species_r 		1[2]0
Species_s 		1[5]0
Species_t 		1[2]0
Species_u 		1[21]0
Species_v 		1[35]0
Species_x 		1[7]0
Species_y 		1[31]0
Species_z 		1[4]0
	;
End;

#Comment: All points were coded, but the program fail to distinguish the polygons, so all point fell in the same polygon (as if all species occurred below 500 m, which not true)



