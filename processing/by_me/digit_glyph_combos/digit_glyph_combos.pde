// DIGIT GLYPH COMBOS
// IN DEVELOPMENT. Will take four glyphs, and display them in a 4-tile,
// displaying in sequence all possible combinations of the tiles,
// repetition allowed, each tile rotating in 90 degree incriments.
// 4 tiles * 4 rotations each = 16 possible tile views,
// 16 views pick 4 all possible combos allow repeat = 65535 4-tile views.

// DEV LOG
// work up to v0.9.0:
// - use PVectors for tile centers
// - reconfigure for transparent bg
// - add commodore vic palette obtained from colodore.com, get_color_sample_grid_hex.py
// - function to get rnd unique 5 colors (indices for color array)
// - tiles array, demo rnd tile load
// - expand rnd color function to retrieve arr. of arbitrary N colors
// - code for 16 discrete tiles; accompanying SVGs
// - offsetting of tiles to crowd toward middle
// - replaced SVG tiles with alternate versions that have no borders--interesting stuff happens with overlap
// - no, scrap commodore vic palette -- garish. adopt instead from fundamental_vivid_hues.hexplt.
// - no, tiles look better with borders and no crowding. If they tesellated maybe without borders it could be cool.
// - changes drawing at regular intervals
// TO DO:
// - iterate through all combos from all16products.txt.
// - save iteration state on every change
// - load and proceed from saved iteration state on program launch
String versionCode = "0.9.0";

// ----------------
// CODE

// GLOBAL VARIABLES
float gridPaddingFromEdge = 50;
float gridXYlength;
int cellsXY = 2;
float cellXYlength;
float xScreenCenter;
float yScreenCenter;
//vectors that describe the center location (XY) of the four tiles:
PVector tile_1A_Center; PVector tile_1B_Center;
PVector tile_2A_Center; PVector tile_2B_Center;
PShape TILE_0; PShape TILE_1; PShape TILE_2; PShape TILE_3;
PShape TILE_4; PShape TILE_5; PShape TILE_6; PShape TILE_7;
PShape TILE_8; PShape TILE_9; PShape TILE_A; PShape TILE_B;
PShape TILE_C; PShape TILE_D; PShape TILE_E; PShape TILE_F;
// array of all those tiles:
PShape[] allTiles = new PShape[16];
int allTilesLength = allTiles.length;
float OT; // Offset Tweak
float OTmultiplier = 0.0;    // the higher this is toward 1, the more tiles will crowd toward center. 0 = no crowding.

color[] colors = {
  #FF00FF, #FF00E2, #FF007F, #FC2273, #FF0000, #FF5100, #FD730A, #FFA100, #FFB700, #FFCD00,
  #FAE000, #FFFF00, #FAFF54, #AFE300, #75FF00, #00FF00, #52FE79, #40F37E, #00E77D, #1DCF00,
  #65D700, #76F1A8, #7FFFFF, #00FFFF, #00E4FF, #00CFFF, #00C4FF, #007FFF, #6060FF, #7F40FF,
  #7202FF, #5F00BE, #40007F, #3C1CB3, #3325D6, #0000FF, #4040FF, #6A6AFF, #7F7FFF, #407FBF,
  #007F7F, #2B2BAB, #00007F, #54007F, #7F007F, #7F0038, #7F0000
};
// variables for timing:
float millis_since_last_change;
float now;
float millisecondsPerDrawingChange = 468.75 * 4;

void setup() {
  // size(800, 1000);
  fullScreen();
  int lengthToUse;
  if (width <= height) { lengthToUse = width; } else { lengthToUse = height; }
  gridXYlength = lengthToUse - (gridPaddingFromEdge * 2);
  cellXYlength = gridXYlength / cellsXY;
  xScreenCenter = width / 2;
  yScreenCenter = height / 2;
  OT = gridXYlength * OTmultiplier;
  float cellOffsetToCenter = (cellXYlength / 2);
// would like to have OT be either 0 or multiplier every run of change_drawing, via
// rnd true/false boolean like this: useOT = random(1) > .5;
  tile_1A_Center = new PVector(xScreenCenter - cellOffsetToCenter + OT, yScreenCenter - cellOffsetToCenter + OT);
  tile_1B_Center = new PVector(xScreenCenter + cellOffsetToCenter - OT, yScreenCenter - cellOffsetToCenter + OT);
  tile_2A_Center = new PVector(xScreenCenter - cellOffsetToCenter + OT, yScreenCenter + cellOffsetToCenter - OT);
  tile_2B_Center = new PVector(xScreenCenter + cellOffsetToCenter - OT, yScreenCenter + cellOffsetToCenter - OT);
  // svg files must be in the /data folder of the current sketch to load successfully:
  TILE_0 = loadShape("0.svg"); TILE_0.disableStyle(); allTiles[0] = TILE_0;
  TILE_1 = loadShape("1.svg"); TILE_1.disableStyle(); allTiles[1] = TILE_1;
  TILE_2 = loadShape("2.svg"); TILE_2.disableStyle(); allTiles[2] = TILE_2;
  TILE_3 = loadShape("3.svg"); TILE_3.disableStyle(); allTiles[3] = TILE_3;
  TILE_4 = loadShape("4.svg"); TILE_4.disableStyle(); allTiles[4] = TILE_4;
  TILE_5 = loadShape("5.svg"); TILE_5.disableStyle(); allTiles[5] = TILE_5;
  TILE_6 = loadShape("6.svg"); TILE_6.disableStyle(); allTiles[6] = TILE_6;
  TILE_7 = loadShape("7.svg"); TILE_7.disableStyle(); allTiles[7] = TILE_7;
  TILE_8 = loadShape("8.svg"); TILE_8.disableStyle(); allTiles[8] = TILE_8;
  //TILE_8 = loadShape("8-B-alt.svg"); TILE_8.disableStyle(); allTiles[2] = TILE_8;
  TILE_9 = loadShape("9.svg"); TILE_9.disableStyle(); allTiles[9] = TILE_9;
  TILE_A = loadShape("A.svg"); TILE_A.disableStyle(); allTiles[10] = TILE_A;
  TILE_B = loadShape("B.svg"); TILE_B.disableStyle(); allTiles[11] = TILE_B;
  TILE_C = loadShape("C.svg"); TILE_C.disableStyle(); allTiles[12] = TILE_C;
  TILE_D = loadShape("D.svg"); TILE_D.disableStyle(); allTiles[13] = TILE_D;
  TILE_E = loadShape("E.svg"); TILE_E.disableStyle(); allTiles[14] = TILE_E;
  TILE_F = loadShape("F.svg"); TILE_F.disableStyle(); allTiles[15] = TILE_F;
  shapeMode(CENTER);
  strokeWeight(0);
  change_drawing();    // only called once here in setup (as setup is only called once)
}

// does what I want, I don't know how :shrug: used by getNrndColors() ;
// from: https://forum.processing.org/two/discussion/7696/unique-random-number-for-elements-in-array
static final boolean contains(int n, int... nums) {
  for (int i : nums)  if (i == n)  return true;
  return false;
}

color[] getNrndColors(int howMany, color[] palette) {
  color[] returnColors = new color[howMany];
  // get an array of unique numbers which are indices of palette;
  // NOTE the QTY must be <= RANGE:
  int QTY = howMany, RANGE = palette.length;
  final int[] numbers = new int[QTY];
  for (int rnd, i = 0; i != QTY; ++i) {
    numbers[i] = MIN_INT;
    while (contains(rnd = (int)random(0, RANGE), numbers));
      numbers[i] = rnd;
  }
  // use rnd unique number indeces to create palette of 5 unique colors from other palette:
  print("\n");
  for (int j = 0; j < numbers.length; j++) {
    //print(numbers[j] + "\n");
    returnColors[j] = colors[numbers[j]];
  }
  // return that palette:
  return returnColors;
};

void setFillAndStroke(color wut) {
  fill(wut); stroke(wut);
}

void change_drawing() {
  millis_since_last_change = millis();
  color[] RND5colors = getNrndColors(9, colors);
  background(RND5colors[0]);
  setFillAndStroke(RND5colors[1]);
  shape(allTiles[int(random(0, allTilesLength))], tile_1A_Center.x, tile_1A_Center.y, cellXYlength, cellXYlength);
  setFillAndStroke(RND5colors[2]);
  shape(allTiles[int(random(0, allTilesLength))], tile_1B_Center.x, tile_1B_Center.y, cellXYlength, cellXYlength);
  setFillAndStroke(RND5colors[3]);
  shape(allTiles[int(random(0, allTilesLength))], tile_2A_Center.x, tile_2A_Center.y, cellXYlength, cellXYlength);
  setFillAndStroke(RND5colors[4]);
  shape(allTiles[int(random(0, allTilesLength))], tile_2B_Center.x, tile_2B_Center.y, cellXYlength, cellXYlength);
}

void draw(){
  now = millis();
  if ((now - millis_since_last_change) > millisecondsPerDrawingChange) {
    print("1 second elapsed.\n");
    change_drawing();
  }
}

// to do: change to ~1 second timer, not mousePressed() event:
void mousePressed() {
  change_drawing();
}

void keyPressed() {
  change_drawing();
}