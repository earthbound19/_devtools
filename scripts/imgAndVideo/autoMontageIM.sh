# DESCRIPTION
# Uses imagemagick montage to pack all images of type $1 in the current
# directory into a montage of approximate size $2. Tiles are padded
# with a dark gray, and the entire result image is padded with a darker
# gray. Result file will be named __montage_<name_of_current_directory>.

# DEPENDENCIES
# A nixy' environment and imagemagick / montage + convert.

# USAGE
# Invoke the script with two parameters, being:
# $1 an image file type, without any . in the extension, e.g.
#  png, not .png. All images of this type in the current
#  directory will be used in the montage.
# $2 OPTIONAL. How many tiles across the montage should be. If not
#   provided or provided as AUTO, imagemagick will automatically
#   decide tiles across and down to be similar to ratio of images.
# $3 OPTIONAL. Approximate intended width of the final montage image,
#  in pixels. Tiles in the image will not be enlarged to fill up space (only
#  shrunk if necessary). For smaller images, if you set an outsized
#  montage size, this could lead to a lot of gray padding around images
#  in the montage. IF PROVIDED as keyword FULL, montage image width
#  is automatically figured to ~accommodate all images in the montage
#  AT FULL SIZE; meaning: the tile width for each image in the montage
#  will be set to the original image width of the first found image,
#  which tiles combined will produce a montage of roughly the size of
#  all original images combined. IF NOT PROVIDED, montage width will be
#  approximately the size of the first image found. In that case, montage
#  width is approximated as: (tile width * tiles across) = montage width.
# Result file will be named __montage_<name_of_current_directory>.
# Example invocation that will create a montage from all png files in
#  the current directory, with number of tiles across auto-decided, and
#  each tile ~800 px wide:
# autoMontageIM.sh png AUTO 800
# An example command that will accomplish the same but set the tiles
#  across to 9:
# autoMontageIM.sh png 9 800
# An example 

# DEV NOTES
# All combinations of possible parameter types the script can handle,
#  for testing:
#  autoMontageIM.sh png (or any image type) +
#  [none] OR n OR AUTO +
#  [none] OR n OR FULL = these possible tests:
# autoMontageIM.sh png [none]
# 	( ^ combos with group 1 only)
# autoMontageIMG.sh png 4 [none]
# autoMontageIMG.sh png AUTO
# 	( ^ combos with group 2 only)
# autoMontageIMG.sh png 4 1600
# autoMontageIMG.sh png 4 FULL
# autoMontageIMG.sh png AUTO 1600
# autoMontageIMG.sh png AUTO FULL
# 	( ^ combos with group 2 and 3)
# SO, all tests are -- I think? :
# autoMontageIM.sh png
# autoMontageIMG.sh png 4
# autoMontageIMG.sh png AUTO
# autoMontageIMG.sh png 4 1600
# autoMontageIMG.sh png 4 FULL
# autoMontageIMG.sh png AUTO 1600
# autoMontageIMG.sh png AUTO FULL
#
# Phew!


# CODE
# If user did not pass parameter $1, warn and exit.

# START GLOBALS SETUP
if ! [ "$1" ]
then
	echo No parameter \$1 \(image type\) passed to script. Exit.
	exit
else
	imageType=$1
fi

if ! [ "$2" ] || [ "$2" == "AUTO" ]
then
	echo ""
	echo "No parameter \$2 passed to script, or passed as AUTO;"
	echo " ImageMagick will set tiles across automatically."
	tilesAcrossParam=
else
	tilesAcross=$2
	tilesAcrossParam="-tile $tilesAcross"
	echo ""
	echo "Will tile montage $tilesAcross tiles across."
fi

    # Get dimensions of first image of type $1 found.
    # -printf '%f\n' chops off the ./ at the start which we don't want:
firstImage=`gfind . -maxdepth 1 -type f -name "*.png" -printf '%f\n' | head -n 1`
originalIMGwidth=`gm identify -format "%w" $firstImage`
originalIMGheight=`gm identify -format "%h" $firstImage`
numImagesFound=`gfind . -maxdepth 1 -type f -name "*.png" -printf '%f\n' | wc -l`
SQRTofNumImagesFound=`echo "scale=0; sqrt($numImagesFound) + 1" | bc`

if [ "$3" ]
then
	if [ "$3" == "FULL" ]
	then
		echo ""
		echo "Keyword FULL passed as \$3 to script;"
		echo " montage will be roughly the area of all original"
		echo " images combined."
		tileWidth=$originalIMGwidth
	else
		echo ""
		echo "Will create montage approximately $3 pixels wide."
		tileWidth=`echo "scale=0; $3 / $SQRTofNumImagesFound" | bc`
	fi
else
	echo ""
	echo "No parameter \$3 (montage width in pixels) passed to script;"
	echo " montage will be roughly the same width of first image found."
	tileWidth=`echo "scale=0; $originalIMGwidth / $SQRTofNumImagesFound" | bc`
fi
# END GLOBALS SETUP

heightToWidthAspect=`echo "scale=5; $originalIMGwidth / $originalIMGheight" | bc`
tileHeight=`echo "scale=0; $tileWidth / $heightToWidthAspect" | bc`
widthPadding=`echo "scale=0; $tileWidth - ($tileWidth * 95.5 / 100)" | bc`
heightPadding=`echo "scale=0; $tileHeight - ($tileHeight * 95.5 / 100)" | bc`
# Dev. testing only:
# echo "tilesAcross $tilesAcross tilesAcrossParam $tilesAcrossParam numImagesFound=$numImagesFound SQRTofNumImagesFound=$SQRTofNumImagesFound tileWidth=$tileWidth firstImage=$firstImage originalIMGwidth=$originalIMGwidth originalIMGheight=$originalIMGheight heightToWidthAspect=$heightToWidthAspect tileHeight=$tileHeight widthPadding=$widthPadding heightPadding=$heightPadding"

# Create the montage to a temp image file.
# Because I can't seem to find the escape sequence necessary to do this from bash+cmd, print the command to a bash script, then execute the script:
geometryParam="$tileWidth"x$tileHeight\>+$heightPadding+$heightPadding
echo "magick montage -background '#767575' $tilesAcrossParam -geometry '$geometryParam' *.$imageType ___oooot_n4yR24PG.png" > tmp_command_MbVTjRGUYXUJ.sh
./tmp_command_MbVTjRGUYXUJ.sh
rm tmp_command_MbVTjRGUYXUJ.sh
# Get dimensions of result and calculate desired (larger) pad size for result:
originalIMGwidth=`gm identify -format "%w" ___oooot_n4yR24PG.png`
originalIMGheight=`gm identify -format "%h" ___oooot_n4yR24PG.png`
paddedImageW=`echo "$originalIMGwidth + ($widthPadding * 2.25)" | scale=0 bc`
paddedImageH=`echo "$originalIMGheight + ($widthPadding * 2.25)" | scale=0 bc`
echo Will pad final montage from $originalIMGwidth to $paddedImageW and $originalIMGheight to $paddedImageH . . .
# Pad temp image file to final result file;
# Construct final file name first:
thisPath=`pwd`
thisFolderName=`basename $thisPath`
gm convert ___oooot_n4yR24PG.png -gravity center -background '#454444' -extent "$paddedImageW"x"$paddedImageH" _montage__"$thisFolderName".png
# Remove temp image file:
rm ___oooot_n4yR24PG.png

echo DONE. Result file is _montage__"$parentDirectoryName".png.