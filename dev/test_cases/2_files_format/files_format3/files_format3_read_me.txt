Test case id: files_format3

Goal: verify if the program indicates if the files are not in the correct format; in this case, 
the files is tab delimited, but, in the second line, I changed  one of the "tab-space" into a "simple-space".

Data: localities_1space_second_line.txt [file with 10 localities, tab delimited, but in the second line one tab-space 
was changed into simple-space], polygons14_simple.txt [file with 14 polygons that do not overlap]

Expected result: the program will indicate that there is something wrong with the file.

Actual result:

[calio@albiorix 3]$ ls
localities_1space_second_line.txt  polygons14_simple.txt
[calio@albiorix 3]$ time phylogeocoder -l localities_1space_second_line.txt -p polygons14_simple.txt --test

[ Error ] The locality data file is not in tab delimited text format.


real	0m0.094s
user	0m0.068s
sys	0m0.026s
[calio@albiorix 3]$ time phylogeocoder -l localities_1space_second_line.txt -p polygons14_simple.txt > result.nex

[ Error ] The locality data file is not in tab delimited text format.


real	0m0.097s
user	0m0.074s
sys	0m0.022s

Comment: The test function indicated that the file was not tab delimited. If one try to carry on with the analysis even after the
error message is prompt, the program again indicates that the file is not in the correct format (the same error message).





