# DESCRIPTION
# Finds all files of type $1 (parameter 1), sorts them by date (oldest first), then runs cat against each. Meow.

# USAGE
# Run with one parameter, which is a file type (or anything else you can use), without any . before the extension (for example just txt) to pass repeatedly to cat, like this:
#    catByDate.sh txt
# To pipe the output to a new file, run it like this:
#    catByDate.sh hexplt > all_palettes.hexplt


# CODE
array=($(find . -name "*.$1" -print0 -printf "%T@ %Tc %p\n" | sort -n -r | sed 's/.*[AM|PM] \.\/\(.*\)/\1/g'))
for element in ${array[@]}
do
	cat $element
done