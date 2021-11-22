# DESCRIPTION
# DANGEROUS. Renames all files and folders found on a system such that a search string is substituted with a replace string, WITHOUT PROMPT OR WARNING, but requiring a password parameter. See DON'T DO THIS UNLESS under USAGE.

# WARNING
# THIS CAN BREAK STUFF HARD AND FAST AND PERMANENTLY IF MISUSED. See "DON'T DO THIS UNLESS" section under "USAGE."

# REQUIREMENTS
# Voidtools "Everything" search engine, working and showing files you search for correctly, and accompanying es (CLI tool for it) in you PATH, probably MSYS2 bash environment.

# USAGE
# Run with these parameters:
# - $1 search string
# - $2 replace string. If provided as the syntax-phrase combination "-_-SNIP-_-" (with or without quote marks), the search string will be deleted from all found files (replaced with nothing).
# - $3 the word YOINK
# Example that will replace the string "dGSUyfhH" with "Murky_Forest" in all files:
#    everythingRename.sh dGSUyfhH Murky_Forest YOINK
# Example that will delete the string SNAIRFU from all found files:
#    everythingRename.sh SNAIRFU -_-SNIP-_- YOINK
# DON'T DO THIS UNLESS:
# - You're very sure you know what you're doing
# - You've tested it on disposable files first
# - You're also looking at files found from a search string using Everything, to verify renames and to be able to undo any breaks.
# - You know and can see that there's no funky crap (like terminal-unfriendly characters) in file and folder names you operate on.

# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source string) passed to script. Exit."; exit 1; else srcString=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (destination string) passed to script. Exit."; exit 2; else destString=$2; fi
	if [ "$destString" == "-_-SNIP-_-" ]; then destString=""; fi
if [ ! "$3" == "YOINK" ]; then printf "\nParameter 3 incorrect. See USAGE comments in script."; exit 3; fi

foundPaths=($(es $1 | tr -d '\15\32'))		# the tr statement deletes windows-style newlines, which throw win-ported GNU tools out of whack.
for path in ${foundPaths[@]}
do
	renameTarget=$(echo $path | sed "s/$srcString/$destString/g")
	mv $path $renameTarget
done