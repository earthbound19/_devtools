# DESCRIPTION
# Takes a list of RGB colors expressed in hex (one per line) and sorts them 
# using an advanced color appearance model for human color vision: CIECAM02.
# If you're sorting very different colors, YOU MAY WISH to use
# RGBhexColorSortinCAM16-UCS.py instead (see). This uses the colorspacious library; that uses colour-science.

# USAGE
# With this script and a .hexplt file both in your immediate path, and Python in your PATH, call this script with these positional parameters:
# - 1 A list of RGB colors as hexadecimal numbers, in .hexplt format (a simple text list, one color per line).
# - 2 OPTIONAL. May be anything, and if present, the script will overwrite the original hex palette list with the sorted colors. To use positional parameter 3 (the next one) but not overwrite the original hex palette list, pass this as the string 'NULL' (with or without quote marks).
# - 3 OPTIONAL. Any hex color code string in the format '#000000', which the script will use as the first color to compare other colors to, even if it's not in the list. The list will therefore be sorted by next nearest color starting with this arbitrary color. If the color happens to be in the original list file (first argument), it will remain in the final list. If the color is not in the original list, it will not appear in the final sorted list.
# Example invocation with only a hexplt file given:
#  Python RGBhexColorSortInCIECAM02.py PrismacolorMarkers.hexplt
# The result will be printed to stdout, so that you may for example redirect the output to a new .hexplt file, e.g.:
#  Python RGBhexColorSortInCIECAM02.py inputColors.hexplt > result.hexplt
# Example invocation with the optional second parameter, which will cause the script to overwrite the original .hexplt file with the sorted version of it:
#  Python RGBhexColorSortInCIECAM02.py inputColors.hexplt foo
# Example invocation with the optional third parameter, an arbitrary color to start comparisons with (here, magenta):
#  Python RGBhexColorSortInCIECAM02.py inputColors.hexplt foo '#ff00ff'
# NOTES
# - This expects perfect data. If there's a blank line anywhere in the
# input file, or any other unexpected data, it may stop with an unhelpful error.
# - This will also delete duplicate colors in the list.
# - The same input always produces the same output, though if you change the order of colors in the list, the results may change. This is because the script uses the first color in the list to begin its comparisons (but you may override that with parameter 3). You therefore may wish to decide which color you want first in the list for those comparison purposes, or pass an arbitrary color via parameter 3.

# DEPENDENCIES
# Python (probably Python 3.5), various python packages (see import list at start of code) which you may install with easy_install or pip.

# LICENSE
# This is my original code and I release it to the Public Domain. -RAH 2019-09-23 09:18 PM

# CODE
# TO DO: Maybe see DEVELOPER NOTES at end of script.
import sys
from itertools import combinations
from colorspacious import cspace_convert, deltaE

# GLOBALS and positional parameters check, with clear boolean/value inits to describe:
overwriteOriginalList = False
arbitraryFirstCompareColor = False
countOfArbitraryFirstColorInOriginalList = 0
if len(sys.argv) > 1:
    hexpltFileNamePassedToScript = sys.argv[1]
else:
    print('\nNo parameter 1 (source .hexplt file) passed to script. Exit.')
    sys.exit()
if len(sys.argv) > 2:
    if sys.argv[2] != 'NULL':   # Only set the following to true if user did not pass the string NULL (allows using positional parameter 2 without "using" it, and also using positional parameter 3:
        overwriteOriginalList = True
if len(sys.argv) > 3:
    arbitraryFirstCompareColor = sys.argv[3]
# END GLOBALS and positional parameters check

def hex_to_CIECAM02_JCh(in_string):
    """ Takes an RGB hex value and returns:
    1. a CIECAM02 3-point value.
    2. The CIECAM02 triplet string used in the cspace_convert function call in this function.
    This is because you may want to hack this function to try different triplet strings. See comments
    in this function, and the cspace_convert function call in this function."""
        # hex to RGB ganked from https://stackoverflow.com/a/29643643/1397555 :
    RGB = tuple(int(in_string[i:i+2], 16) for i in (0, 2, 4))
        # REFERENCE for the third parameter of the next function call in code; re
        # re https://colorspacious.readthedocs.io/en/latest/reference.html#colorspacious.deltaE :
        # classcolorspacious.JChQMsH(J, C, h, Q, M, s, H)
        # A namedtuple with a mnemonic name: it has attributes J, C, h, Q, M, s, and H, each of which holds a scalar
        # or NumPy array representing . . 
        # [things!] . . . [read the docs thar!] . . . and as a convenience, all strings composed of the character
        # JChQMsH are automatically treated as specifying CIECAM02-subset spaces, so you can write:
        # 
        # "JCh"
        #
        # SO . . .
        # J = lightness
        # C = chroma
        # h = hue angle
        # Q = brightness
        # M = colorfulness
        # s = saturation
        # H = hue composition
        # 
        # . . . whatever on earth that all means.
        # 
        # The documentation (defaults to? and) recommends sort by "JCh".
        # Possible sorts are [h/H/][M/s/C][J/Q]
        #
        # permutations of 'J', 'C', 'h':
        # ('J', 'C', 'h')
        # ('J', 'h', 'C')
        # ('C', 'J', 'h')
        # ('C', 'h', 'J')
        # ('h', 'J', 'C')
        # ('h', 'C', 'J')
        #
        # I would suggest you maybe try "hQC", "hCQ", "HsQ", "ChJ", "Jhs", IF THE
        # RESULTS DIFFERED. In early development I thought they did, but that was
        # because my script's intended functionality was broken (same input didn't
        # always produce same output) :
    CIECAM02_dimSTR = "JCh"
    CIECAM02_dimResult = cspace_convert(RGB, "sRGB255", CIECAM02_dimSTR)
    return CIECAM02_dimResult, CIECAM02_dimSTR

# split input file into list on newlines:
f = open(hexpltFileNamePassedToScript, "r")
colors_list = list(f.read().splitlines())
f.close()

if arbitraryFirstCompareColor != False:     # if a parameter was passed to script (arbitrary color in format '#ffffff' to start comparisons with), dynamically alter the list to insert that color at the start. BUT FIRST, track (with the following variable, countOfArbitraryFirstColorInOriginalList) the count of that color in the list before we add it to the list, because if that count is zero before adding, we will want to remove it from the list after comparisons and sorting (we don't want to permanently add it to the list; we only want to add it temporarily). (Because we don't want to add colors permanently to the list that were never there; we want to leave the list as it was found.) But if it _was_ originally in the list, we want to keep it there after adding, because the list will be deduplicated. Because the list will be deduplicated, the color we add to the list (even if it was in the list already before we added it) it would end up appearing only once in the list, and removing it after that would remove it entirely. That is a lot of explanation for the following two lines of code :)
    countOfArbitraryFirstColorInOriginalList = colors_list.count(arbitraryFirstCompareColor)
    colors_list.insert(0, arbitraryFirstCompareColor)
# strip beginning '#' character off every string in that list:
colors_list = [element[1:] for element in colors_list]
# deduplicate the list, but maintain same order:
from more_itertools import unique_everseen
colors_list = list(unique_everseen(colors_list))

# SORT HEX RGB color list to next nearest per color,
# by converting to CIECAM02, then sorting on some dimensions in that space.

# get a list of lists of all possible color two-combinations, with an deltaE (distance
# measurement between the colors) as a value in the lists; doing this
# with manual nested for loops because itertools returns tuples and other reasons that
# may not be valid:
pair_deltaEs = []

for i in range(len(colors_list)):
    for j in range(i + 1, len(colors_list)):
        # print(colors_list[i], colors_list[j])
        CIECAM02_comp_one, SPACE = hex_to_CIECAM02_JCh(colors_list[i])
        CIECAM02_comp_two, SPACE = hex_to_CIECAM02_JCh(colors_list[j])
        distance = deltaE(CIECAM02_comp_one, CIECAM02_comp_two, input_space = SPACE)
        pair_deltaEs.append([distance, colors_list[i], colors_list[j]])

# results in lowest deltaE values first; may cause searches to run faster (I don't know):
# Only print any information if we're overwriting the original list, because if we're not, the user may want to pipe printed output to a new .hexplt file, which they woudln't want cluttered with information that would break the .hexplt format:
if overwriteOriginalList == True:
    print('\nSorting deltaEs . . .')
pair_deltaEs.sort()
sorted_colors = list()

# Again, conditional print (avoid printing clutter if user isn't ovewriting original file:
if overwriteOriginalList == True:
    print('Sorting colors by nearest deltaE . . .')
search_color = colors_list[0]
sorted_colors.append(search_color)  # starts list
while len(sorted_colors) < len(colors_list):
    # get subsection of deltaE list in which color appears:
    deltaEs_subsection = list()
    for idx, element in enumerate(pair_deltaEs):
        if search_color in element:
            deltaEs_subsection.append(element)
    # sort that subsection, which places the lowest deltaE in the first list in it.
    deltaEs_subsection.sort()
    # then put the color pair in that subsection list in the sorted list, with the search color (the
    # "search_color" variable here in this code) first; the search color may
    # be at either [0][1] or [0][2], so figure out which. Then add color and the
    # other color: if len(deltaEs_subsection) > 1:
    if search_color == deltaEs_subsection[0][1]:
        matched_color = deltaEs_subsection[0][2]
        sorted_colors.append(matched_color)
#        print('added ', matched_color, 'for', search_color)
        search_color = matched_color
    else:
        matched_color = deltaEs_subsection[0][1]
        sorted_colors.append(matched_color)
#        print('added ', matched_color, 'for', search_color)
        search_color = matched_color
    # remove the subsection from pair_deltaEs, to avoid future matches against current search_color
    # after search_color changes in the next loop:
    for element_two in deltaEs_subsection:
        pair_deltaEs.remove(element_two)


# FINALE

# add '#' back to the start of every element in the sorted color list before print:
for IDX, color in enumerate(sorted_colors):
    fixedTehColorFormat = '#' + color
    sorted_colors[IDX] = fixedTehColorFormat

# If we inserted an arbitrary color at start of list (to make first comprarison from), but it wasn't in the original list, remove it from the new sorted colors list; otherwise leave it there:
if countOfArbitraryFirstColorInOriginalList == 0 and arbitraryFirstCompareColor != False:
    sorted_colors.remove(arbitraryFirstCompareColor)

# Again, conditional print if we're overwriting original list, and if we are overwriting original list, this is where in code we do that:
if overwriteOriginalList == True:
    print('Writing sorted color list back over original file . . .')
    with open(hexpltFileNamePassedToScript, 'w') as f:
        for element in sorted_colors:
            f.write(element + '\n')
    f.close()
# If not ovewriting original list, print the sorted list:
else:
    for element in sorted_colors:
        print(element)



# DEVELOPER NOTES
# Try the same function but with different parameters J'a'b' in the colour library? 
# re: https://colour.readthedocs.io/en/develop/generated/colour.difference.delta_E_CAM16LCD.html
# re: https://colour.readthedocs.io/en/develop/tutorial.html
# NOTE that the install package name for that is colour-science, NOT colour (which is valid but
# something else far more limited!)
# - See URLs in comments in the below code. They all probably were developed because of this
# paper: https://www.researchgate.net/publication/227991182_CIE_Color_Appearance_Models_and_Associated_Color_Spaces
# - Chart of all known color spaces / models and how to convert between them, re colour library:
# https://colour.readthedocs.io/en/develop/index.html#automatic-colour-conversion-graph-colour-graph
# - I only get the colorio library installing on python 3.8.0 on mac. possible use of cam16 color
# - another library that does other things: http://markkness.net/colorpy/ColorPy.html
# space in it: https://github.com/nschloe/colorio/blob/master/test/test_cam16.py
# - stinking awesome answer that led to some of this: https://stackoverflow.com/a/49346067/1397555