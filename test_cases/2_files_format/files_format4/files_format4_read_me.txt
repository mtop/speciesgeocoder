Test case id: files_format4

Goal: verify if the program indicates if the files are not in the correct format; in this case, 
the localities file contains Windows line breaks.

Data: localities10_windows.txt [file with 10 localities, tab delimited, but with windows line breaks], polygons14_simple.txt 
[file with 14 polygons that do not overlap]

Expected result: the program will indicate that the file is not in the correct format.

Actual result:
[calio@albiorix ~]$ unix2dos localities10_windows.txt 
unix2dos: converting file localities10_windows.txt to DOS format ...
[calio@albiorix ~]$ time phylogeocoder -l localities10_windows.txt -p polygons14_simple.txt --test
[--] 'localities10_windows.txt' passed all tests.
[--] 'polygons14_simple.txt' passed all tests.

real	0m0.202s
user	0m0.088s
sys	0m0.032s
[calio@albiorix ~]$ time phylogeocoder -l localities10_windows.txt -p polygons14_simple.txt
Progress: 100%     
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
Genusa_one 		00000000100010
	;
End;

real	0m0.282s
user	0m0.256s
sys	0m0.023s

Comment: The file with windows line breakes passed the test function. The program coded the distribution correctly.





