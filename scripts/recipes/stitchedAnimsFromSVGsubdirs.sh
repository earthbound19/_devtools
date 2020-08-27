# DESCRIPTION
# Makes a stitched anim from output subdirectories of SVG animation frames, from small_and_simple_things.pde (Processing) output with (for example) the following global variables set to these values:
#    boolean savePNGs = false;
#    boolean saveSVGs = true;
#    boolean saveAllFrames = false (or true!);
#    boolean saveAllFramesInteractOverride = true (or false!);

# USAGE
# After you obtain so many images in subdirectories via small_and_simple_things.pde, run this script without any parameters:
#    stitchedAnimsFromSVGsubdirs.sh


# CODE
array=$(find . -maxdepth 1 -type d -printf '%f\n' | sort -n)
# the :1 in the following slices the array to omit
# the first element, ., which we don't want;
# re: https://stackoverflow.com/a/2701872/1397555
array=("${array[@]:1}")

# To prep to create zero-padded numbers for each .mp4 file:
array_length=${#array[@]}
padToDigits=${#array_length}

currdir=$(pwd)
i=0
for element in ${array[@]}
do
	i=$((i+1))
	zeroPaddedNumber=$(printf "%0"$padToDigits"d" $i)
	# if the render target does *not* exist, do things to create it. Otheriwise do nothing for this loop:
	if [ ! -e anim_segment_"$zeroPaddedNumber".mp4 ]
		then
		pushd .
		cd $currdir/$element
		echo rendering animation in $currdir/$element . . .
		# remove tmp_rip directory if it exists:
		if [ -d tmp_rip ]; then rm -rf tmp_rip; fi
		mkdir tmp_rip
		cp *.svg ./tmp_rip
		cd tmp_rip
		# TO DO: obviate the need of renumberFiles.sh by detecting number of padded zeros,
		# and first file number, and passing that to ffmpeg re:
		# https://en.wikibooks.org/wiki/FFMPEG_An_Intermediate_Guide/image_sequence
		renumberFiles.sh svg
		allSVG2img.sh 1920 png
		ffmpegAnim.sh 30 30 9 png
		mv ./_out.mp4 ../../anim_segment_"$zeroPaddedNumber".mp4
		cd ..
		rm -rf tmp_rip
		popd
	else echo Render target anim_segment_"$zeroPaddedNumber".mp4 already exists\; skipping render..
	fi
done

# concatenate resulting .mp4 files:
concatVidFiles.sh mp4
# rename the concatenated file after the parent directory:
current_dir=$(pwd)
parent_dir=$(basename $current_dir)
mv ./_mp4sConcatenated.mp4 ./_FINAL_$parent_dir.mp4