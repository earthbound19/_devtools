# DESCRIPTION
# Copies the video stream of a source video into a new container and re-encodes the audio in aac high quality, into an mp4 container. Intended for slightly modified video distribution from source video from some (silly) devices that record AVC/PCM videos (which have like 1:10 ratio waste) in sound stream size via PCM; ergo this script to get them compressed audio to save space. Output files are named after the input file, but add ~_aacSound to the file name. Also, metadata and timestamps are copied from the source to the target.

# DEPENDENCIES
#    ffmpeg

# USAGE
# Run with these parameters:
# - $1 file name of the source video (in the current directory) to re-encode the sound for.
# For example:
#    copyVidLosslessEncodeSound.sh inputVideo.MOV


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file name of input video) passed to script. Exit."; exit 1; else inputFile=$1; fi

outputFileName=${inputFile%.*}_aacSound.mp4
if [ -e ${inputFile%.*}_aacSound.mp4 ]
then
	echo "Output file name $outputFileName already exists; will not clobber; skip. To re-render it, rename or delete that file, and run this script with the same input file again."
else
	echo Converting $inputFile . . .
	ffmpeg -i $inputFile -map 0:v -vcodec copy -map 0:a -acodec aac -crf 10 ${inputFile%.*}_aacSound.mp4
	# copy metadata from source file to render target:
	exiftool -overwrite_original -TagsFromFile $inputFile ${inputFile%.*}_aacSound.mp4
	# Update time stamp of file to metadata creation date; uses a conditional like is given in this post: https://exiftool.org/forum/index.php?topic=6519.msg32511#msg32511 -- but adding an -else clause:
	exiftool -if "defined $CreateDate" -v -overwrite_original '-FileModifyDate<CreateDate' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" -else -v -overwrite_original '-FileModifyDate<DateTimeOriginal' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" ${inputFile%.*}_aacSound.mp4

fi