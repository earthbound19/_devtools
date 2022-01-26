// DESCRIPTION
// Intended for CLI use. Extracts dominant color and a palette of an arbitrary number of colors from an image, printing to stdout.

// USAGE
// Run with two parameters:
// process.argv[2] <./path_to_image_to_process.png>
// process.argv[3] <number of colors to extract for palette>.
// For example, substituting /path/to/this with the actual path to this script on your system:
//    node /path/to/this/color-thief-jimp-palette.js input.png 12


// CODE
var ColorThief = require('color-thief-jimp');
var Jimp = require('jimp');

Jimp.read('./' + process.argv[2], (err, sourceImage) => {
  if (err) {
    console.error(err);
    return;
  }
    // TO GET dominant color:
    // var dominantColor = ColorThief.getColorHex(sourceImage);
    // console.log('dominant color found is [HEX]:\n' + dominantColor);
  var palette = ColorThief.getPaletteHex(sourceImage, process.argv[3]);
    // console.log('color palette extracted is [HEX]:');
  console.log(palette);
});
