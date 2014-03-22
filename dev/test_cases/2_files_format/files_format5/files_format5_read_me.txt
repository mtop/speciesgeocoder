####Test case id: files_format5####

##Part 1
#Goal: verify if the program indicates if the files are not in the correct format; in this case, the localities file does not contain the first line  [#species	lat.	long.] 
#Data: occurrenceFE_wrong.txt [file with 1000 localities]; southamerica_without_altitude.txt [file with 2 polygons equal in shape that cover all south america]. All points fall inside the polygons area.
#Expected result: the program will indicate that the file is not in the correct format.
#Actual result:

screen -S wrong
qlogin

[calio@compute-0-4 ~]$ time phylogeocoder -l /usr/local/db/speciesgeocoder/preformancetests/occurrenceFE_wrong.txt -p /usr/local/db/speciesgeocoder/preformancetests/southamerica_without_altitude.txt --test
[--] '/usr/local/db/speciesgeocoder/preformancetests/occurrenceFE_wrong.txt' passed all tests.
[--] '/usr/local/db/speciesgeocoder/preformancetests/southamerica_without_altitude.txt' passed all tests.

real    0m1.297s
user    0m0.113s
sys     0m0.070s

#Comment: The file without the first line passed the test.


##Part 2
#Goal: verify if the program performs the analysis even when the file is not in the correct format; in this case, the localities file does not contain the first line  [#species	lat.	long.] 
#Data: occurrenceFE_wrong.txt [file with 1000 localities]; southamerica_without_altitude.txt [file with 2 polygons equal in shape that cover all south america]. All points fall inside the polygons area.
#Expected result: the program will prompt some error message.
#Actual result:

[calio@compute-0-4 ~]$ time phylogeocoder -l /usr/local/db/speciesgeocoder/preformancetests/occurrenceFE_wrong.txt -p /usr/local/db/speciesgeocoder/preformancetests/southamerica_without_altitude.txt > result_wrong.nex
Point in polygon test: 100%     

real    0m0.633s
user    0m0.286s
sys     0m0.074s

[calio@compute-0-4 ~]$ cat result_wrong.nex
#NEXUS

Begin data;
        Dimensions ntax=25 nchar=2;
        Format datatype=standard symbols="01" gap=-;
        CHARSTATELABELS
        1 South_america_a,
        2 South_america_b;


        Matrix
Species_a               00
Species_b               00
Species_c               00
Species_d               00
Species_e               00
Species_f               00
Species_g               00
Species_h               00
Species_i               00
Species_j               00
Species_k               00
Species_l               00
Species_m               00
Species_n               00
Species_o               00
Species_p               00
Species_q               00
Species_r               00
Species_s               00
Species_t               00
Species_u               00
Species_v               00
Species_x               00
Species_y               00
Species_z               00
        ;
End;


#Comment: The program performed the analysis without prompting any error message, however, coded the distribution was not coded correctly (it seems that the point don't occur inside the polygon areas, but this is not true).





