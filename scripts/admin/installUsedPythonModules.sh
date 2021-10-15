# DESCRIPTION
# Installs all the Python modules I commonly use.

# USAGE
# Run without any parameter:
#    installUsedPythonModules.sh


# CODE
python -m pip install --upgrade pip

pythonModules=" \
numpy \
scipy \
more_itertools \
colorspacious \
colour-science \
spectra \
ciecam02 \
colormap \
colorgram.py \
Quartz \
Foundation \
Pillow \
easydev \
scour"

# possible future-use modules:
# matplotlib \

# PACKAGE NOTES:
# colour is actually imported as colour-science, but there is another package that imports as colour. I think.
# Pillow is a maintained fork of PIL and imports as name PIL.

# Uncomment whichever applies to your python version:
# pipExeName=pip
pipExeName=pip3

for element in ${pythonModules[@]}
do
	echo "Attempting to install $element via $pipExeName . . ."
	$pipExeName install $element
done