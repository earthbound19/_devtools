# DESCRIPTION
# Uses several other scripts to make animated bent data art from any series of *.bak files (Notepad Plus Plus auto-backups, or from any other program that makes automatic backups so named). in a /progress subdir of whatever path this script is run from. The resulting _out.gif (or out.mp4) animation visually represents (as animated data bent art) changes made in a file over time.

# USAGE
# From a path containing so many incremental (or otherwise saved!) *.bak files, invoke this script:
# ./thisScript.sh

# DEPENDENCIES
# allDataType2PPMglitchArt.sh, imgs2imgsNN.sh, mkNumberedLinks.sh, ffmpegAnim.sh, and their various dependencies; a series of automatically backed up files from a file that was edited.

# NOTES
# You will afterward have a numberedLinks subdirectory, which is full of numbered junction links to *.png files in the path above it. You may safely discard this subdirectory.


# CODE
pushd .

allDataType2PPMglitchArt.sh bak
mkdir ppm
mv *.ppm ./ppm
cd ppm
imgs2imgsNN.sh ppm png 550
mkNumberedLinks.sh png
cd numberedLinks
ffmpegAnim.sh 2 2 13 png
# If you're on windows:
cygstart _out.gif
# OR if you're on mac:
# open _out.gif

popd