Test case id: files_format1

Goal: verify if the program indicates if the files are not in the correct format; in this case, 
the localities file is not tab delimited.

Data: points_10.csv [file with 10 localities, not tab delimited], polygons_1elev.txt [file with 2 polygons equal 
in shape, but different in the elevation parameter], tiff file with elevation data

Expected result: the program will indicate that the file is not in the correct format.

Actual result:
[calio@albiorix 1]$ ls
points_10.csv  polygons_1elev.txt  polygons_2elev.txt  polygons_3elev.txt
[calio@albiorix 1]$ time phylogeocoder -l points_10.csv -p polygons_1elev.txt  --test

[ Error ] The locality data file is not in tab delimited text format.


real    0m0.094s
user    0m0.067s
sys     0m0.026s

Comment: The program is indicating that the file is not tab delimited.





