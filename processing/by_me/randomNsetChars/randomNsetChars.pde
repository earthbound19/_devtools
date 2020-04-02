// DESCRIPTION
// Prints variants of constructed random character sets (hard-coded but hackable: block
// # characters), scrolling down the screen, with character color morph (randomization).

// LICENSE
// This code and accompanying files are my original work and I dedicate it to th
// Public Domain, with the exception of the font files, which have their respective
// open (but not Public Domain) licenses. - RAH 2020-03-17 09:18 AM Tuesday

// KNOWN ISSUES
// - if you save images and it gets to hundreds or thousands of frames, the displayed
// framerate and file saving lags.

// TO DO:
// - mitigate long-running lag by splitting into folders every thousandth file?
// - log seed / frame numbers for reference?
// - something with this? https://stackoverflow.com/questions/51702011/can-we-create-partially-colored-text-in-processing
// - unique rnd colors of rows? Might entail:
//  - converting text to PShape; possibly re: https://discourse.processing.org/t/convert-text-to-pshape/15552/2
// - tweet image with current char set text?
// - save SVG?
// - svg numbering and save anim mode, for anims?


// CODE
// Changes this version:
// - add comments about cool variants (rnd seeds)

// GLOBAL VARIABLE DECLARATIONS
String versionNumber = "1.5.2";

int delayBetweenRenders = 84;    // has been: 84, 112, 141;
// to figure ffmpegAnim.sh "source" framerate, calculate: 1000 / delayBetweenRenders

boolean booleanOverrideSeed = false;
// rnd seed may be in range (-2147483648, 2147483647) :
int seed = 71028736;
// RND seeds and their emergent properties:
// 71028736 starts blue-cyan and gets really interesting fast.
// 1980151040 starts blue-cyan interesting pattern start. Leads to 71028736 (above).
// NOTE: At this writing both of the following booleans must be true to save anims; indiv.
// frames are not saved:
boolean saveAllFrames = false;
boolean savePNGs = false;

color[] bgColors = {
	#1C1C1C, #151D1D,	#0E1D1F, #031E21,	#06161E, #0A0E1C,	#0B0B1B, #080813,
	#030308, #000000,	#0D0B00, #171201,	#201901
};
int bgColorsLength = bgColors.length;
int bgColorsArrayIndex = 0;

// palette tweaked (and expanded with more cyans and greens, and lighter those) from:
// https://github.com/earthbound19/_ebArt/blob/master/palettes/fundamental_vivid_hues_v2.hexplt
color[] fillColors = {
	#FF00FF, #FF00C0, #FF007F, #DB12A3, #C91BB5, #B624C8, #A42DDA, #7F40FF,
	#6060FF, #6A6AFF, #7F7FFF, #608BF3, #4894EA, #00AFCF, #00C1EA, #00CFFF, #00C4FF,
	#00E4FF, #2DEEFF, #3EF1FF, #7FFFFF, #6DFFFF, #5BFFFF, #25FFFF, #00FFFF,
	#32F2DA, #43EECD, #54EAC1, #76E1A8, #40F37E, #52FE79, #00E77D, #1DCF00,
	#65D700, #85FF00, #00FF00, #B5FF00, #B2F300, #AFE300, #D1EF00, #FFD500,
	#FFB700, #FD730A, #FF5100, #FF0000, #FF0047, #FF006B, #FF009C
};
int fillColorsLength = fillColors.length;
int fillColorsArrayIndex = 0;

boolean rndColorChangeMode = true;
color bgColor;
color fillColor;

PFont myFont;

// FOR OTHER POSSIBLE characters to use in superset, see: http://s.earthbound.io/RNDblockChars
// SUPER SET DEFINITION from which subsets may be randomly drawn; combining any of these can produce interesting results:
// -- here are some possible subsets of them to use as supersets (from which sub-subsets would
// be made) :
 //String masterCharset = "┈┉┊┋┌└├┤┬┴┼╌╍╎╭╮╯╰╱╲╳╴╵╶╷";     // box drawing subset
 //String masterCharset = "▲△◆◇○◌◍◎●◜◝◞◟◠◡◢◣◤◥◸◹◺◿◻◼";     // geometric shapes subset
 //String masterCharset = "∧∨∩∪∴∵∶∷∸∹∺⊂⊃⊏⊐⊓⊔⊢⊣⋮⋯⋰⋱";      // math operators subset
 //String masterCharset = "◈⟐⟢ːˑ∺≋≎≑≣⊪⊹☱☰☲☳☴☵☶☷፨჻܀";   //Apple emoji subset
 //String masterCharset = "─│┌┐└┘├┤┬┴┼╭╮╯╰╱╲╳▂▃▄▌▍▎▏▒▕▖▗▘▚▝○●◤◥♦";	// Commodore 64 font/drawing glyphs set--which, it happens, combines characters from some of the others interestingly.
String masterCharset = "▔▀▆▄▂▌▐█▊▎░▒▓▖▗▘▙▚▛▜▝▞▟";			// block characters subset
int masterCharsetLength = masterCharset.length();

String subCharSetRND;
int subCharSetRNDlength;

float fontPointSize;

float characterWidth;
float columnWidth;
float rowHeight;
int columns;
int rows;

String charsDisplayString;

boolean displayRNDsubsets;
int numRendersToDisplaySubset;
int reloadAfterNrenders;
int renderCount;
int subsetDisplayedrendersCounter;

String animFramesSaveSubdir;
// END GLOBAL VARIABLES DECLARATIONS


// BEGIN CUSTOM FUNCTIONS
// given a string, returns a subset of unique random characters from the string,
// of random length from 1 to the length of the string.
String getRNDcharsSubset(String srcString) {
  String rndSubSet = "";
  int rndSubSetBuildToLength = int(random(0, masterCharsetLength + 1));
  for (int i = 0; i <= rndSubSetBuildToLength; i++) {
   boolean isAlreadyInSubset = false;
   while (isAlreadyInSubset == false) {
     int rndSubsetIDX = int(random(0, masterCharsetLength));
     char pickedChar = srcString.charAt(rndSubsetIDX);
     for (int j = 0; j < rndSubSet.length(); j++) {
       if (pickedChar == rndSubSet.charAt(j)) {
         isAlreadyInSubset = true;
       }
     }
     if (isAlreadyInSubset == false) {
       rndSubSet += pickedChar;
       isAlreadyInSubset = true;
     }
   }
  }
  return rndSubSet;
}

void setRNDbgColor() {
	bgColorsArrayIndex = int(random(0, bgColorsLength));
	bgColor = bgColors[bgColorsArrayIndex];
	background(bgColor);
}

// FUNCTION ALTERS A GLOBAL! :
// randomly changes index to select bg color from self, before, or after,
// looping around if past either edge of array index, but only if an rnd color mode bool is true:
void mutateBGcolor() {
  if (rndColorChangeMode == true) {
      int rndChoiceTwo = int(random(-2, 2));
      bgColorsArrayIndex += rndChoiceTwo;
      // if less than zero, set to array max.:
      if (bgColorsArrayIndex <= 0) {
        bgColorsArrayIndex = bgColorsLength;
      }
      // if more than array max., set to zero:
      if (bgColorsArrayIndex >= bgColorsLength) {
        bgColorsArrayIndex = 0;
      }
      bgColor = bgColors[bgColorsArrayIndex];
	background(bgColor);
  }
}

void setRNDfillColor() {
	fillColorsArrayIndex = int(random(0, fillColorsLength));
	fillColor = fillColors[fillColorsArrayIndex];
	fill(fillColor);
}

// FUNCTION ALTERS A GLOBAL! :
// randomly changes index to select foreground color from self, before, or after,
// looping around if past either edge of array index, but only if an rnd color mode bool is true:
void mutateFillColor() {
  if (rndColorChangeMode == true) {
      int rndChoiceOne = int(random(-2, 2));
      fillColorsArrayIndex += rndChoiceOne;
      // if less than zero, set to array max.:
      if (fillColorsArrayIndex <= 0) {
        fillColorsArrayIndex = fillColorsLength;
      }
      // if more than array max., set to zero:
      if (fillColorsArrayIndex >= fillColorsLength) {
        fillColorsArrayIndex = 0;
      }
      fillColor = fillColors[fillColorsArrayIndex];
	fill(fillColor);
  }
}
// END CUSTOM FUNCTIONS


void settings() {
  fullScreen();
  // size(1280, 720);

  // get a random string and use it as an animation save frames subdir name component:
	String rndString = "";
  String rnd_string_components = "abcdeghjkmnpqruvwyzABCDEGHJKMNPQRUVWYZ23456789";
  for (int i = 0; i < 12; i++)
  {
    int rnd_choice = (int) random(0, rnd_string_components.length());
    rndString+= rnd_string_components.charAt(rnd_choice);
  }
  animFramesSaveSubdir = "_anim_run_" + rndString + "/";
}


void setup() {
	// this check ensures manual seed is only done once, expecting no other code to ever set
	// booleanOverrideSeed to true again:
	if (booleanOverrideSeed == true) {
    randomSeed(seed);
    booleanOverrideSeed = false;
  } else {
    seed = (int) random(-2147483648, 2147483647);
		randomSeed(seed);
  }
	print("Seed " + seed + "\n");

  fontPointSize = width/43;    // tried sizes list: 83.4 51.5 43 39.1 32 24 12; unifont was last width/28.46

	subCharSetRND = getRNDcharsSubset(masterCharset);

	setRNDbgColor();
	setRNDfillColor();

  displayRNDsubsets = true;
  numRendersToDisplaySubset = 15;
  reloadAfterNrenders = numRendersToDisplaySubset * 4;
  renderCount = 0;
  subsetDisplayedrendersCounter = 0;
  
  // Uncomment the following two renders to see the available fonts 
  //String[] fontList = PFont.list();
  //printArray(fontList);
  myFont = createFont("BabelStoneShapes.ttf", fontPointSize);
  textFont(myFont);
  textAlign(CENTER, TOP);

  textSize(fontPointSize);    // Also sets vertical leading; re
  // https://processing.org/reference/textLeading_.html -- so reset that with textLeading():
  characterWidth = textWidth('_');
  columns = int(width / characterWidth);
  rowHeight = fontPointSize * 0.965;    // for unifont-12.1.04.ttf: = * 1.987;
  // I'm mystified why (textAscent() + textDescent() gave wrong val here with Fira Mono:
  textLeading(rowHeight);
  
  rows = int(height / rowHeight);
}


// EXCEPT MOAR CUSTOM FUNCTION
void renderRNDcharsScreen () {
	clear();
  subsetDisplayedrendersCounter += 1;
  if (subsetDisplayedrendersCounter == numRendersToDisplaySubset) {
    subsetDisplayedrendersCounter = 0;
  }
  
  mutateBGcolor();
  mutateFillColor();
  
  // length of subCharSetRND can be changed, so this needs to be done every call of this func.:
  charsDisplayString = "";
  int subCharSetRNDlength = subCharSetRND.length();
  charsDisplayString = "";
  for (int row = 0; row < rows + 1; row++) {
    for (int column = 0; column < columns; column++) {
      int rndInt = int(random(0, subCharSetRNDlength));
      charsDisplayString += subCharSetRND.charAt(rndInt);
    }
    charsDisplayString += "\n";
  }
  text(charsDisplayString, width/2, 0);
  // only delay if we are not saving PNG images:
  if (savePNGs == false) {
	delay(delayBetweenRenders);
  }

  // SAVE PNG FRAME AS PART OF ANIMATION FRAMES conditioned on boolean:
  if (saveAllFrames == true && savePNGs == true) {
    saveFrame(animFramesSaveSubdir + "/##########.png");
  }

  // to mitigate mysterious slowdown via periodic reload of script:
  renderCount += 1;
  if (renderCount == reloadAfterNrenders) {
    // print("Calling setup again at renderCount == " + renderCount + "!\n");
    setup();
  }
}

void draw () {
  // to change display on every draw loop:
  renderRNDcharsScreen();
}

// call setup() for new variation on mouse press AND/OR key press:
void mousePressed() {
  setup();
}
void keyPressed() {
  setup();
}
