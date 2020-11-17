# DESCRIPTION
# Gets -n shades of any -c color (default white if not passed) via the CIECAM02 color space, which models human perception of color (and brightness and other aspects of light) better than any other model at this writing. Writes results to a new .hexplt file named after color.

# DEPENDENCIES
# Python and the various import libraries declared at the start of CODE.

# USAGE
# Run this script through a Python interpeter with the --help parameter for instructions, or read the description sections in the argsparse setup below.
# EXAMPLE RUN that produces 16 shades of gray (as it defaults to shades of white if no --COLOR is specified), which the script will write to the file named FFFFFF_12shades.hexplt:
#    python /path/to_this_script/getNshadesOfColorCIECAM02.py -n 12
# EXAMPLE RUN that produces sixteen shades of magenta, which the script will write to a file named FF00FF_18shades.hexplt:
#    python /path/to_this_script/getNshadesOfColorCIECAM02.py -n 16 --COLOR FF00FF
# NOTES
# - Previously, because of inexact float math, this script was capable of producing more or less colors than requested. Thanks to a numpy linspace function, that is no longer the case. Moreover, results are more exact to what is desired (start with absolute white and end with absolute black, where previously it often produced very slight off-white or black, or didn't even end with black).
# - It may produce some unexpected colors. I recommend you use an editor that live previews hex colors (like Atom with the highlight-colors package). You may be able to avoid unexpected colors by overriding start brightness of color (see -b parameter).
# - It writes results to a file named after the color, e.g. `fff585_15shades.hexplt`.


# CODE
# DEV NOTES
# SEE COMMENTS IN get_CIECAM02_simplified_gamut.py, BUT:
# J (brightness or lightness) range is 0 to 100, h (hue) is 0 to 360, C (chroma) can be 0 to any number (I don't believe that there _is_ a max from whatever corollary/inputs produces the max), maybe max 160. For hard-coded colors, start with max 182 (this seemed a thing with L in HCL).
# ALSO, I tried the same thing with a different color library, in a now deleted script getNshadesOfColorCAM16-colour-science.py, but I was getting very wonky color results, so I forsook it and deleted the script.

import sys
import numpy as np
from colorspacious import cspace_converter, cspace_convert
import argparse

# configure arguments / help
PARSER = argparse.ArgumentParser(description='Gets -n shades of any -c color (default color is white if not passed) via the CIECAM02 color space, which models human perception of color (and brightness and other aspects of light) better than any other model at this writing.')
PARSER.add_argument('-c', '--COLOR', help='String. Color to get shades of, in RGB HEX format e.g. \"-c \'FF00FF\'\" (without the double quote marks, but _with_ the single quote marks) for magenta.', type=str)
PARSER.add_argument('-n', '--NUMBER_OF_SHADES', help='Number. How many shades of color to generate from brightest original color point to black., e.g. "-n 15" (without the quote marks) for 15 shades.', type=int, required=True)
PARSER.add_argument('-b', '--BRIGHTNESS_OVERRIDE', help='Optional number from 0 to 100. If provided, overrides innate brightness (according to CIECAM02 / JCh modeling of J or brightness) of -c color, resulting in colors stepping down from this override brightness. 100 is full bright (will appear white or near-white), 50 is medium bright, 0 is dark (will appear black or near-black). If not provided, generated shades will step (default down) from colors\' inherent brightness to black or near black. To step up to white, see -r option. Note that yellows may get lost as orange below about J = 80, but violets get lost as magenta above that, depending on the value of C also.', type=int)
PARSER.add_argument('-r', '--DARK_TO_BRIGHT', help='Optional switch (no value needed). If present, shades will be generated from dark to light (instead of default bright to dark).', action='store_true')
ARGS = PARSER.parse_args()

# init globals / from parsed arguments
# default color:
COLOR_HEX_RGB_GLOBAL = 'FFFFFF'
# override that default if appropriate arg. passed:
if ARGS.COLOR:
	COLOR_HEX_RGB_GLOBAL = str(ARGS.COLOR)
	COLOR_HEX_RGB_GLOBAL = COLOR_HEX_RGB_GLOBAL.rstrip()		# UN. BE. FREAKING. LEAVABLE!! Windows newlines mess with that string otherwise!!
GLOBAL_NUMBER_OF_SHADES = ARGS.NUMBER_OF_SHADES

# Global clamp function keeps values in boundaries and also converts to int
def clamp(val, minval, maxval):
    if val < minval: return int(minval)
    if val > maxval: return int(maxval)
    return int(val)

# delete any / all # from string if they are provided in arg. (more than one would be bad source):
COLOR_HEX_RGB_GLOBAL = COLOR_HEX_RGB_GLOBAL.replace('#', '')
# print("~\n-c color parameter is ", COLOR_HEX_RGB_GLOBAL)

RGB = tuple(int(COLOR_HEX_RGB_GLOBAL[i:i+2], 16) for i in (0, 2, 4))
JCh_result = cspace_convert(RGB, "sRGB255", "JCh")
# JCH_result[0] is J, JCH_result[1] is C, [JCH_result2] is h

J_min = 0.0000000000000001      # Practically zero and avoids divide by zero warning
J_max = JCh_result[0]
# alter J_max if param. says so:
if ARGS.BRIGHTNESS_OVERRIDE:
	J_max = ARGS.BRIGHTNESS_OVERRIDE

if ARGS.DARK_TO_BRIGHT:		# if told to reverse gradient (dark -> white), swap min,max:
	tmp = J_min; J_min = J_max; J_max = tmp

C = JCh_result[1]				# C
h = JCh_result[2]				# h

JCh2RGB = cspace_converter("JCh", "sRGB255")		# returns a function

colorsRGB = []
# Thanks to help here: https://stackoverflow.com/a/7267806/1397555
descending_j_values = np.linspace(J_max, J_min, num=GLOBAL_NUMBER_OF_SHADES)
for J in descending_j_values:
	# build JCh array:
	JCh = np.array([ [J, C, h] ])
	# build RGB hex array:
	RGB = JCh2RGB(JCh)
	# clamp values to RGB ranges:
	R = clamp(RGB[0][0], 0, 255); G = clamp(RGB[0][1], 0, 255); B = clamp(RGB[0][2], 0, 255)
	# converts to two-digit (if needed) padded hex string: "{0:0{1}x}".format(255,2)
	R = "#" + "{0:0{1}x}".format(R,2); G = "{0:0{1}x}".format(G,2); B = "{0:0{1}x}".format(B,2);
	hex_string = R + G + B
	hex_string = hex_string.upper()
	colorsRGB.append(hex_string)
	colorsRGB.append(hex_string)

# Deduplicate list but maintain order; re: https://stackoverflow.com/a/17016257/1397555
from more_itertools import unique_everseen
colorsRGB = list(unique_everseen(colorsRGB))

outFileName = COLOR_HEX_RGB_GLOBAL + "_" + str(len(colorsRGB)) + "shades.hexplt"

print("Writing to output file ", outFileName, " . . .")
f = open(outFileName, "w")
for element in colorsRGB:
# 	# print(element)
	f.write(element + "\n")
f.close()