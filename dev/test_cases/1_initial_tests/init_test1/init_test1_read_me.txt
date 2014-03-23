Test case id: initial_test1 [getting to know the program]

Goal: verify if the levation function is working

Data: points_10.csv [file with 10 localities], polygons_1elev.txt [file with 2 polygons equal 
in shape but different in the elevation parameter], tiff file with elevation data

Expected result: the code will handle the analysis but it might take a while to end

Actual result:
[calio@albiorix 1]$ time phylogeocoder -l points_10.csv -p polygons_1elev.txt -t /usr/local/git/geocoder/elevation_data/neotropis/*.tif > result1.nex
Traceback (most recent call last):
  File "/usr/local/git/geocoder/geocoder.py", line 464, in <module>
    main()
  File "/usr/local/git/geocoder/geocoder.py", line 409, in main
    localities = MyLocalities()
  File "/usr/local/git/geocoder/geocoder.py", line 150, in __init__
    for name in self.getLocalities():
  File "/usr/local/git/geocoder/geocoder.py", line 176, in getLocalities
    longitude = splitline[2]
IndexError: list index out of range

real    0m39.089s
user    0m2.694s
sys     0m3.239s

Comment: I think I have bumped into another problem. Old files are generating the same message.

### Closed ###
This bug has been fixed. The code now handles the IndexError problem and produces a more informative error meassage.

mats@Slartibartfasts:~/git/geocoder/test_cases/1_initial_tests/init_test1$ phylogeocoder -l points_10.csv -p polygons_1elev.txt

[ Error ] The locality data file is not in tab delimited text format.

mats@Slartibartfasts:~/git/geocoder/test_cases/1_initial_tests/init_test1$

