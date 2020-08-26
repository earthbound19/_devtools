# DESCRIPTION
# Creates a markdown image listing (README.md) of all .png format palette files (rendered from .hexplt source files) in the current path.

# WARNINGS
# - This will overwrite a palette README.md file that already exists.
# - It will also delete a README.md if there are no .pngs in the directory you run this in.

# USAGE
# Run this script without any parameters:
#    palettesMarkdownGallery.sh
# NOTE
# On Mac (at least) this script throws an error about test, and yet it still works as intended (the test causes a zero or nonzero return code).


# CODE
# checking error code on find command thanks to a genius breath yon: https://serverfault.com/a/768042/121188
! test -z $(find . -maxdepth 1 -iname \*.png)
error_code=`echo $?`
# echo error_code is $error_code

# If no png files were found (if find threw an error), destroy any README.md gallery file and exit the script:
if (( error_code == "1" ))
then
	echo "--NO png files were found. DESTROYING README.md and will then exit script!";
	rm README.md; exit
else
	echo "--png files were found. Will create README.md gallery."
fi

# Otherwise, proceed with gallery creation:
printf "# Palettes\n\nClick any image to go to the source image; the text line above the image to go to the source .hexplt file.\n\n" > README.md

array=(`find . -maxdepth 1 -type f -iname \*.png -printf '%f\n' | tr -d '\15\32' | sort -n`)

for element in ${array[@]}
do
	hexpltName=${element%.*}
	printf "### [$hexpltName]($hexpltName.hexplt)\n\n" >> README.md
	printf "[ ![$element]($element) ]($element)\n\n" >> README.md
done

printf "Created with [palettesMarkdownGallery.sh](https://github.com/earthbound19/_ebDev/blob/master/scripts/palettesMarkdownGallery.sh)." >> README.md

echo DONE.