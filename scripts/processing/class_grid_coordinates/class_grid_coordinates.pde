// DESCRIPTION
// Grid of rectangles with random stroke colors from hard-coded array of colors. BUT AKTULLY, also a new class (object definition) that does things to enable this. Except I may want to use the dawesome library instead, maybe with some code from this adapted to setting that up for use.

// USAGE
// Open this file in the Processing IDE (or anything else that can run a Processing file), and run it with the triangle "Play" button.


// CODE
// by Richard Alexander Hall


// will be a member (class instance or object) within the grid class, below:
class cellCoordinate {
  // members
  int x; int y;
  // constructor
  cellCoordinate(int passedX, int passedY) {
    x = passedX; y = passedY;
  }
}

// class for grid of coordinates
class grid {
  // members
  int gridWidth, gridHeight;    // total width and height of grid
  int cellWidth, cellHeight;    // width and height of each cell in the grid
  int cellXcount, cellYcount;   // number of cells accross and down in the grid.
  int gridUpperLeftXoffset = 0; int gridUpperLeftYoffset = 0;   // to center grid coordinates on the canvas if cellWidth and cellHeight don't evenly divide into gridWidth and/or gridHeight. Otherwise, the grid could be in the upper left with padding on the right and below. Note that defaults (initialization) are provided here; they will be overriden if necessary.

  // a list of coordinates (intended use is iterating over it) :
  cellCoordinate[] coordinatesList;

  // THE FOLLOWING are two-dimensional arrays of PVectors of cells organized like [cellXcount][cellYcount] (or [cols][rows] or [accross][down], where each vector is an x and y coordinate associated with a cell:
  PVector[][] centerCoordinates;        // center of cell
  PVector[][] upperLeftCoordinates;     // upper left corner of cell
  PVector[][] upperRightCoordinates;    // upper right corner of cell
  PVector[][] lowerRightCoordinates;    // lower right corner of cell
  PVector[][] lowerLeftCoordinates;     // lower left corner of cell

  // constructor requires string that declares a construction mode declaration, for which the options are:
  // - "setCellCountXY", to init with wanted number of cells across and down, and the constructor will do the math on cell width and height.
  // - "setCellWidthAndHeight", to init with wanted width and height of cells, and the constructor will do the math on how many cells across and down that means. as setCellWidthAndHeight can lead to a grid fixed to the upper left with padding on the right and below if the x and/or y parameters don't evenly divide into wantedGridWidth and wantedGridHeight, the function does math to offset the coordinates so that the grid is centered on the canvas.
  grid (int wantedGridWidth, int wantedGridHeight, int x, int y, String initMode) {
    gridWidth = wantedGridWidth; gridHeight = wantedGridHeight;
        // debug print of values passed to function:
        print("grid class constructor called with these values: wantedGridWidth:" + wantedGridWidth + " wantedGridHeight:" + wantedGridHeight + " x:" + x + " y:" + y + " initMode:" + initMode + "\n");
		// init cell width, height, and number of cells according to value of String initMode:
    switch(initMode) {
      case "setCellWidthAndHeight":
        cellWidth = x; cellHeight = y;
        cellXcount = gridWidth / cellWidth; cellYcount = gridHeight / cellHeight;
        // calc offsets which will be used to center grid (coordinates) on canvas:
        gridUpperLeftXoffset = (gridWidth - cellXcount * cellWidth) / 2;
        gridUpperLeftYoffset = (gridHeight - cellYcount * cellHeight) / 2;
        break;
      case "setCellCountXY":
        // set number of cells across and down from wanted cell width and height, then calc cellWidth and cellHeight from that:
				cellXcount = x; cellYcount = y;
        cellWidth = gridWidth / cellXcount; cellHeight = gridHeight / cellYcount;
        break;
      default:
        print("ERROR: grid class constructor called with wrong string parameter! Use either \"setCellWidthAndHeight\" or \"setCellCountXY\".\n");
        exit();
        break;
    }
    // debug print of resultant values:
    print("result values of grid constructor call: gridWidth:" + gridWidth + " gridHeight:" + gridHeight + " cellWidth:" + cellWidth + " cellHeight:" + cellHeight + " cellXcount:" + cellXcount + " cellYcount:" + cellYcount + " gridUpperLeftXoffset: " + gridUpperLeftXoffset + " gridUpperLeftYoffset:" + gridUpperLeftYoffset + "\n");

    // allocate memory for coordinatesList:
    coordinatesList = new cellCoordinate[cellXcount * cellYcount];
    // allocate memory for PVector arrays of two-dimensional coordinates:
    centerCoordinates = new PVector[cellXcount][cellYcount];
    upperLeftCoordinates = new PVector[cellXcount][cellYcount];
    upperRightCoordinates = new PVector[cellXcount][cellYcount];
    lowerRightCoordinates = new PVector[cellXcount][cellYcount];
    lowerLeftCoordinates = new PVector[cellXcount][cellYcount];

    // init various two-dimensional coordinate arrays:
    int cellCounter = 0;
    int tmp_x_coord; int tmp_y_coord;
    for (int yIter = 0; yIter < cellYcount; yIter++) {
      for (int xIter = 0; xIter < cellXcount; xIter++) {
        // expand cellCoordinate array with current x and y coord:
        coordinatesList[cellCounter] = new cellCoordinate(xIter, yIter); cellCounter += 1;
        // cell center coordinate values:
        tmp_x_coord = ((xIter+1) * cellWidth) - (cellWidth / 2) + gridUpperLeftXoffset;
        tmp_y_coord = ((yIter+1) * cellHeight) - (cellHeight / 2) + gridUpperLeftYoffset;
        centerCoordinates[xIter][yIter] = new PVector(tmp_x_coord, tmp_y_coord);
        // upper-left coord. values:
        tmp_x_coord = (xIter * cellWidth) + gridUpperLeftXoffset;
        tmp_y_coord = (yIter * cellHeight) + gridUpperLeftYoffset;
        upperLeftCoordinates[xIter][yIter] = new PVector(tmp_x_coord, tmp_y_coord);
				// upper-right coord. values:
        tmp_x_coord = ((xIter+1) * cellWidth) + gridUpperLeftXoffset;
        tmp_y_coord = (yIter * cellHeight) + gridUpperLeftYoffset;
        upperRightCoordinates[xIter][yIter] = new PVector(tmp_x_coord, tmp_y_coord);
        // lower-right coord. values:
        tmp_x_coord = ((xIter+1) * cellWidth) + gridUpperLeftXoffset;
        tmp_y_coord = ((yIter+1) * cellHeight) + gridUpperLeftYoffset;
        lowerRightCoordinates[xIter][yIter] = new PVector(tmp_x_coord, tmp_y_coord);
        // lower-left coord. values:
        tmp_x_coord = (xIter * cellWidth) + gridUpperLeftXoffset;
        tmp_y_coord = ((yIter+1) * cellHeight) + gridUpperLeftYoffset;
        lowerLeftCoordinates[xIter][yIter] = new PVector(tmp_x_coord, tmp_y_coord);
            // I could make those assignments more efficiently by copying values to all coordinates when the source is in a certain configuration only once, but that would make my code much harder to read and is of dubious more actual code run speed effiency, at my guess.
      }
    }    
  }
}

// GLOBAL VALUES
// have to declare here or draw() won't know it exists; but have to initialize in setup() to get width and height that result from size() in settings():
grid mainGrid;
int mainGridCoordinateListLength;
int cellDrawingCircleSize;  // to be used for circle drawings on grid
int RNDshift = 4;
color[] colorArray = {
  // tweaked with less pungent and more pastel orange and green, from _ebPalettes 16_max_chroma_med_light_hues_regular_hue_interval_perceptual.hexplt:
  #f800fc, #ff0596, #ea0000, #fb5537, #ff9710, #ffc900, #feff06, #a0d901,
  #85e670, #0ccab3, #01edfd, #00a6fe, #0041ff, #9937ff, #c830ff
  // omitted because it is used for the foreground dot color: #5c38ff
};
int colorArrayIDXmax = colorArray.length;
// END GLOBAL VALUES

// GLOBAL FUNCTIONS
int rndShift(){
  return (int) random(RNDshift * -1, RNDshift);
}

void randomStrokeColorFromColorArray() {
  int rndIDX = (int) random(0, colorArrayIDXmax);
  stroke(colorArray[rndIDX]);
}

void drawCells() {
  for (int i = 0; i < mainGridCoordinateListLength; i++) {
    int tmp_x = mainGrid.coordinatesList[i].x;
    int tmp_y = mainGrid.coordinatesList[i].y;
    PVector coord1, coord2, coord3, coord4;
    //NOTE: try this with and withuot .copy() at the end. With .copy(), coord is independent and its values are unuqie to itself. _without_ .copy(), coord is a _reference_ to mainGrid.centerCoordinates[tmp_x][tmp_y], which means that if you alter the values, they persist outside this loop (as the object was created outside this loop) :
    //coord = mainGrid.centerCoordinates[tmp_x][tmp_y].copy();
          //coord = mainGrid.centerCoordinates[tmp_x][tmp_y];
    //coord.x += (int) random(-3, 3);
    //coord.y += (int) random(-3, 3);
    //circle(coord.x, coord.y, cellDrawingCircleSize);
    //grid coordinates array names references:
    //centerCoordinates
    //upperLeftCoordinates
    //upperRightCoordinates
    //lowerRightCoordinates
    //lowerLeftCoordinates
    coord1 = mainGrid.upperLeftCoordinates[tmp_x][tmp_y].copy();
    coord2 = mainGrid.upperRightCoordinates[tmp_x][tmp_y].copy();
    coord3 = mainGrid.lowerRightCoordinates[tmp_x][tmp_y].copy();
    coord4 = mainGrid.lowerLeftCoordinates[tmp_x][tmp_y].copy();
    randomStrokeColorFromColorArray();
    line(coord1.x, coord1.y, coord2.x, coord2.y);
    // OR ALTERNATELY, with some position randomization:
    // line(coord1.x + rndShift(), coord1.y + rndShift(), coord2.x + rndShift(), coord2.y + rndShift());
    randomStrokeColorFromColorArray();
    line(coord2.x, coord2.y, coord3.x, coord3.y);
    // line(coord2.x + rndShift(), coord2.y + rndShift(), coord3.x + rndShift(), coord3.y + rndShift());
    randomStrokeColorFromColorArray();
    line(coord3.x, coord3.y, coord4.x, coord4.y);
    // line(coord3.x + rndShift(), coord3.y + rndShift(), coord4.x + rndShift(), coord4.y + rndShift());
    randomStrokeColorFromColorArray();
    line(coord4.x, coord4.y, coord1.x, coord1.y);
    // line(coord4.x + rndShift(), coord4.y + rndShift(), coord1.x + rndShift(), coord1.y + rndShift());

  }
}
// END GLOBAL FUNCTIONS

void setup() {
  fullScreen();
  // size(700,700);
  // function reference: grid (int wantedGridWidth, int wantedGridHeight, float x, float y, String initMode) {
  // mainGrid = new grid(width, height, 13, 8, "setCellCountXY");
  mainGrid = new grid(width, height, 160, 160, "setCellWidthAndHeight");
  mainGridCoordinateListLength = mainGrid.coordinatesList.length;
  cellDrawingCircleSize = mainGrid.cellWidth;
  fill(#0596ff);
  strokeWeight(6.83);
  stroke(#01edfd);
	strokeCap(PROJECT);    // other options are SQUARE and ROUND
  ellipseMode(CENTER);
}

// main Processing draw function (it loops infinitely)
void draw() {
  clear();
  // background(#5e6061);
  drawCells();
  delay(111);
  // saveFrame("/##########.png");
}
