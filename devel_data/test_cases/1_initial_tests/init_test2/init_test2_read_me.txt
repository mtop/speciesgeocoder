Test case id: initial_test2 [getting to know the program]

Goal: verify if the elevation function is working

Data: points_10_new.csv [file with 10 localities; the format was changed to tab delimited], polygons_1elev.txt [file with 2 polygons equal 
in shape, but different in the elevation parameter], tiff file with elevation data

Expected result: the code will handle the analysis but it might take a while to end

Actual result:
[calio@albiorix 2]$ time phylogeocoder -l points_10_NEW.csv -p polygons_1elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result.nex

real    0m10.914s
user    0m3.943s
sys     0m5.568s
[calio@albiorix 2]$ ls
points_10_NEW.csv  polygons_1elev.txt  result.nex
[calio@albiorix 2]$ cat result.nex
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

Comment: The analysis run faster than I was expecting. Its is working.





