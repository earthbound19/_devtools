# DESCRIPTION
# Samples every pixel in an image and dumps to a list of hex color codes contained in the image.

# USAGE
# With this script and the input image in your PATH, invoke this script with the image as the first parameter, e.g.:
# python img2RGBhexList.py input_image.png
# To pipe the output to a file:
# python img2RGBhexList.py input_image.png > input_image_hex_colors_list.hexplt
# To reduce that to unique colors:
# sort tmp.hexplt > tmp_garblethax.txt && uniq tmp_garblethax.txt > tmp.hexplt && rm ./tmp_garblethax.txt


# CODE
# ganked from: https://stackoverflow.com/a/19917486/1397555
#!/usr/bin/python
import sys
from PIL import Image

def rgb2hex(r, g, b):
    return '#{:02x}{:02x}{:02x}'.format(r, g, b)

img = Image.open((sys.argv[1]))

pixels = list(img.convert('RGBA').getdata())

for r, g, b, a in pixels: # just ignore the alpha channel
	norf = rgb2hex(r, g, b)
	print(norf)