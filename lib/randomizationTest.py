import sys

try: 
	from numpy import *
	import numpy as np
except(ImportError): 
	sys.exit("\nError: numpy library not found.\nYou can download numpy at: http://sourceforge.net/projects/numpy/files/ \n")



def get_pres_abs(D):
       	pres_abs = np.zeros(np.shape(D))
       	pres_abs[D>0] +=1
       	return pres_abs

def sensitivity_test(dict):
	errors=[.05,.1,.25,.5]
	D = np.array([dict[i] for i in dict])       
	pres_abs = get_pres_abs(D)
	list1,list2 = [],[] # store summary stats across errors
	for error in errors: 
		l=[]
		n_wrong_sp = []
		worng_area = []
		for i in range(10000):
			randomized_sample = np.random.binomial(D,1-error,np.shape(D))
			randomized_pres_abs = get_pres_abs(randomized_sample)
			species_differently_coded = sum(abs(randomized_pres_abs-pres_abs),axis=1)
			areas_differently_coded = sum(abs(randomized_pres_abs-pres_abs),axis=0)
			ind_species_differently_coded = np.zeros(np.shape(species_differently_coded))
			ind_species_differently_coded[species_differently_coded>0]+=1
			n_wrong_sp.append(len(species_differently_coded[species_differently_coded>0]))
			l.append(ind_species_differently_coded)
		
		list1.append([int(mean(n_wrong_sp)),int(1.96*std(n_wrong_sp))])
		l=np.array(l)
		by_sp_error= mean(l,axis=0)
		list2.append(by_sp_error)
		
	
	
	outfile= open("sensitivity_test.txt","wb")
	outfile.writelines("Error (%):\t5\t10\t25\t50\n")
	line="Number of species wrongly coded:\t%s (+/-%s)\t%s (+/-%s)\t%s (+/-%s)\t%s (+/-%s)\n" % \
	(list1[0][0],list1[0][1],list1[1][0],list1[1][1],list1[2][0],list1[2][1],list1[3][0],list1[3][1])
	outfile.writelines(line)
	outfile.writelines("# Probability of wrong coding by species\n")
	j=0
	for i in dict:
		line="%s\t%s\t%s\t%s\t%s\n" % (i, list2[0][j],list2[1][j],list2[2][j],list2[3][j])
		j+=1
		outfile.writelines(line)
	
	outfile.close()
	sys.stderr.write("Results of the sensitivity test are saved in 'sensitivity_test.txt'")


# test
if __name__ == "__main__":
	dict= {'Ivesia unguiculata': [1, 0, 14, 14, 0, 0, 0, 0], 'Ivesia lycopodioides': [0, 10, 73, 73, 0, 0, 0, 0], 'Ivesia shockleyi': [1, 20, 6, 6, 0, 0, 0, 0], 'Ivesia jaegeri': [0, 0, 0, 0, 12, 1, 0, 0], 'Ivesia kingii': [0, 23, 1, 1, 0, 0, 0, 0], 'Ivesia santolinoides': [0, 0, 56, 56, 0, 1, 0, 0], 'Ivesia sabulosa': [0, 16, 0, 0, 3, 0, 0, 0], 'Ivesia longibracteata': [0, 0, 5, 5, 0, 0, 0, 0], 'Ivesia sericoleuca': [0, 18, 8, 8, 0, 0, 0, 0], 'Ivesia saxosa': [0, 7, 2, 2, 1, 9, 0, 0], 'Ivesia webberi': [0, 7, 3, 3, 0, 0, 0, 0], 'Ivesia argyrocoma': [0, 0, 0, 0, 0, 25, 0, 0], 'Ivesia rhypara': [0, 26, 0, 0, 0, 0, 3, 0], 'Ivesia setosa': [0, 40, 0, 0, 0, 0, 0, 1], 'Ivesia multifoliolata': [0, 0, 0, 0, 12, 0, 0, 0], 'Ivesia utahensis': [0, 10, 0, 0, 0, 0, 0, 0], 'Ivesia tweedyi': [0, 0, 0, 0, 0, 0, 27, 9], 'Ivesia aperta': [0, 25, 1, 1, 0, 0, 0, 0], 'Ivesia baileyi': [0, 50, 0, 0, 0, 0, 0, 1], 'Ivesia arizonica': [0, 4, 0, 0, 7, 0, 0, 0], 'Ivesia cryptocaulis': [0, 0, 0, 0, 2, 0, 0, 0], 'Ivesia pygmaea': [0, 1, 31, 31, 0, 0, 0, 0]}
	sensitivity_test(dict)
