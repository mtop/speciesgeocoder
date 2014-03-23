Test case id: files_format2

Goal: verify if the program indicates if the files are not in the correct format; in this case, 
the files is tab delimited, but, in the first line, I changed  one of the "tab-space" into a "simple-space".

Data: localities_1space_first_line.txt [file with 10 localities, tab delimited, but in the first line one tab-space 
was changed into simple space], polygons14_simple.txt [file with 14 polygons that do not overlap]

Expected result: the program will indicate that there is something wrong with the file.

Actual result:

[calio@albiorix 2]$ ls
localities_1space_first_line.txt  polygons14_simple.txt
[calio@albiorix 2]$ time phylogeocoder -l localities_1space_first_line.txt -p polygons14_simple.txt --test
[--] 'localities_1space_first_line.txt' passed all tests.
[--] 'polygons14_simple.txt' passed all tests.

real	0m0.108s
user	0m0.082s
sys	0m0.026s
[calio@albiorix 2]$ time phylogeocoder -l localities_1space_first_line.txt -p polygons14_simple.txt > result.nex

real	0m0.272s
user	0m0.246s
sys	0m0.024s
[calio@albiorix 2]$ cat result.nex 
#NEXUS

Begin data;
	Dimensions ntax=1 nchar=14;
	Format datatype=standard symbols="01" gap=-;
	CHARSTATELABELS
	1 1,
	2 2,
	3 3,
	4 4,
	5 5,
	6 6,
	7 7,
	8 8,
	9 9,
	10 10,
	11 11,
	12 12,
	13 13,
	14 14;


	Matrix
Genusa_one 		00000000000000
	;
End;

Comment: The file passed the test function, however, the localities were not coded 
(there are for sure points in two polygons).





