#!/usr/local/opt/python/bin/python2.7

import uuid

def split_file(file_name, num_cpu):
	# Split a locality input file in several files
	# and store their names in a list for later removal
	num_lines = sum(1 for line in open(file_name))
	lines = num_lines / num_cpu
	tmp_out_file_list = []
	with open(file_name, 'r') as in_file:

		try:
			# Open first output file
			out = str(uuid.uuid4()) + ".CAN_SAFELY_BE_REMOVED"
			tmp_out_file_list.append(out)
			out_file = open(out, 'w')
			for i, line in enumerate(in_file, 1):
				# Every time the current line number can be divided by the
				# wanted number of lines, close the output file and open a
				# new one. This will result in temporary output files with
				# one row less them "lines"
				if i == 1:
					header = line
				if i % lines == 0:
					# Close the current output file and open the next one
					out_file.close()
					out = str(uuid.uuid4()) + ".CAN_SAFELY_BE_REMOVED"
					tmp_out_file_list.append(out)
					out_file = open(out, 'w')
					out_file.write(header)
				# write the line to the output file
				out_file.write(line)
		finally:
			# Close the last output file
			out_file.close()
			return tmp_out_file_list


if __name__ == "__main__":
	split_file('example_data/localities.csv', 100)
