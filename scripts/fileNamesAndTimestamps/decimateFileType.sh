# DESCRIPTION
# Counts all files of type $1 in the current directory, then deletes all files counted between the 1st file and all multiples of $2. See NOTES for a more detailed explanation.

# USAGE
# With this script in your PATH, run it with these parameters:
# - $1 the file type to search for (in the current directory only).
# - $2 the multiple of those files to _keep_ when counting and deleting them.
# Example which will delete every png image in the current directory which, by counted order, is not 1 or a multiple of 3:
#    decimateFileType.sh png 3
# NOTES
# - You may wish, after running this script, to run renumberFiles.sh (see the USAGE comment in that script) to make e.g. animation frame numbers in files contiguous again.
# - The script sorts listed files by create date before deleting, so that e.g. animation frames will stay in order.
# - The formula for listed file numbers to delete is $2 minus one because this preserves the first frame.
# - Here is a way of detailing the file delete pattern:
#    1. file number 1: KEEP
#    2. all files counted between that and the next multiple of $2: DELETE
#    3. file counted on multiple of $2: KEEP
#    4. repeat steps 2 and 3 until there are no more files to delete


# CODE
if ! [ "$1" ]; then echo "No parameter \$1. Exit."; exit; else fileTypeToDelete=$1; fi
if ! [ "$2" ]; then echo "No parameter \$2. Exit."; exit; else divisor=$2; fi
if [[ "$divisor" -eq 1 ]]; then echo "The value of 1 passed for \$2 will delete every file. Nope. Exit."; exit; fi

read -p "WARNING: all files of type $fileTypeToDelete, listed and counted, and which are not a multiple of ($divisor - 1) will be deleted! If this is what you intend, type YORFEL and <enter> (or <return>). Otherwise, type anything else and <enter>/<return>, or CTRL+Z or CTRL+C. TYPE: " florf

if [[ "$florf" != "YORFEL" ]]; then echo "No input match. Exit."; exit; else echo "Input match; continuing . . ."; fi

# Sorts by time stamp:
array=( $(find . -maxdepth 1 -name "*.$fileTypeToDelete" -print0 -printf "%T@ %Tc %p\n" | sort -n | sed 's/.* [0-9]\{3,\} \.\/\(.*\)/\1/g') )

counter=0
for element in ${array[@]}
do
	result=$((counter % $divisor))
	counter=$((counter + 1))
	if [[ ! result -eq 0 ]]
	then
		echo "DELETING $element at count $counter . . ."
		rm $element
	fi
done