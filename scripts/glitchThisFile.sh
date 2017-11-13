# DESCRIPTION
# Produces a corrupted version of whatever file you pass to it as a parameter, skipping the first N bytes of the file (see the skipHeaderBytes variable initialization at the start of this script). Designed for e.g. making glitch art from jpg images or mp4 movies. NOTE: because of bash math restraints (unless I use bc, no thanks), this will fail on files of size 100 bytes or less.

# USAGE
# Pass this script two parameters, being:
# $1 A file name.
# $2 What percent of the file to corrupt (in a copy of it)
# This will produce a corrupted version of the file, named __corrupted_"$2"pct_$timestamp__<originalFileName>.
# NOTE: See comment ALTERNATE OPTIONS HERE for other percent options (which are effective for variously sized files)

# TO DO
# optional random truncation (deletion) of bytes
# throw errors for missing paramaters and exit.
# If the source file is a common movie format, convert it first to a transport stream and corrupt that?
# Exert fine control over header bytes skipped (by using dd bs=1, where it is now using the default 512 bytes).

# NOT TO DO
# In-memory instead of on-disk corruption via xxd. Tried hexStr=`xxd -ps imgData.dat` . . . then (after corruption), with the -r switch reverse the operation. It was prohibitively slow. Piping the output to a file also (resulted in gigabytes-size file).


# IMPORTANT GLOBAL:
	# This isn't necessarily an accurate number of bytes for any header of any bmp image; the header size varies and would have to be determined by parsing the format;
	# "So what you want to do is read the bytes at offsets 10-13, parse them as a 4-byte integer, and that integer represents where in the file to seek to get all of the image data." Re: https://stackoverflow.com/a/21368975
	# http://karpolan.com/software/bmp-header-remover/
	# http://magazine.art21.org/2011/09/13/how-to-create-a-bitmap-image-file-by-hand-without-stencils/#.WgktdyZlBcY
	# possibly the best concise guide: http://www.dragonwins.com/domains/getteched/bmp/bmpfileformat.htm
	# https://en.wikipedia.org/wiki/BMP_file_format#File_structure
	# Interesting--! all possible images in a given resolution generator: http://code.activestate.com/recipes/577674-bitmap-maker/
	# To create a "black" 0x0 bitmap, which turns out 66 bytes:
	# gm convert -size 0x0 xc:black out.bmp
		# HEADER NOTES: Little Endian. File header 14 bytes, ends at 0xE. 0xA (in 4 bytes, starting 10 bytes into file) tells offset to start of pixel data. 0x12 is where image dimensions are given, w and h, 4 bytes each. 0xE gives size of image header (at end of which pixel data starts?) in bytes.
skipHeaderBytes=66

fileToMakeCorruptedCopyOf=$1
percentToCorrupt=$2

echo making corrupt copy of $fileToMakeCorruptedCopyOf and corrupting by $percentToCorrupt percent . . .
# Retrieve extension of source file; thanks re http://stackoverflow.com/a/1665574 :
fileExt=`echo $fileToMakeCorruptedCopyOf | sed -n 's/.*\.\(.\{1,5\}\).*/\1/p'`
__ln=( $( ls -Lon "$fileToMakeCorruptedCopyOf" ) )
__size=${__ln[3]}
		echo file size in bytes is $__size.
__size_minus_header=$((__size - $skipHeaderBytes))
		echo file size minus header, in bytes, is $__size_minus_header.
		echo command one\: dd count=$skipHeaderBytes if=$fileToMakeCorruptedCopyOf of=header.dat
dd count=$skipHeaderBytes if=$fileToMakeCorruptedCopyOf of=header.dat
		echo command two\: dd skip=$skipHeaderBytes if=$fileToMakeCorruptedCopyOf of=imgData.dat
dd skip=$skipHeaderBytes if=$fileToMakeCorruptedCopyOf of=imgData.dat

__ln=( $( ls -Lon "imgData.dat" ) )
__size=${__ln[3]}
		echo file size of imgData.dat in bytes is $__size

echo Percent of file I should corrupt according to parameter passed to script\:
echo $percentToCorrupt

__ln=( $( ls -Lon "imgData.dat" ) )
__size=${__ln[3]}
			# echo file size of imgData in bytes is $__size
		# Re: reply by "lewis" here: http://echochamber.me/viewtopic.php?t=6377
		# Also: http://stackoverflow.com/a/7290825/1397555

# ALTERNATE OPTIONS HERE; comment out the one you don't want:
corruptionPasses=$(($__size / 147500 * $percentToCorrupt))
# corruptionPasses=$(($__size / 100000 * $percentToCorrupt))
# corruptionPasses=$(($__size / 75000 * $percentToCorrupt))
# corruptionPasses=$(($__size / 10000 * $percentToCorrupt))
# corruptionPasses=$(($__size / 1000 * $percentToCorrupt))
# corruptionPasses=$(($__size / 100 * $percentToCorrupt))
# corruptionPasses=3

echo will do $corruptionPasses corruption passes\, which is about $percentToCorrupt percent of the file . . .
for i in $( seq $corruptionPasses )
do
	echo Corruption write pass $i of $corruptionPasses underway . . .
	seekToByte=`shuf -i 1-"$__size" -n 1`
# TO DO: prefetch n random bytes earlier, and get new ones sequentially from that in memory.
# TO DO: Add random (relatively rare, or paramaterized?) deletion of copied chunks before concatination; e.g.: at a 5 on 5-sided die roll, split imgData.dat into two files, delete some random bytes (in a range) from the second file, and concatenate them--thus sometimes *deleting* bytes from the data instead of corrupting the bytes.
	dd conv=notrunc bs=1 count=1 seek=$seekToByte if=/dev/urandom of=./imgData.dat
done

timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
cat ./header.dat ./imgData.dat > "__corrupted_""$percentToCorrupt""pct_""$timestamp""__""$fileToMakeCorruptedCopyOf"
rm header.dat imgData.dat