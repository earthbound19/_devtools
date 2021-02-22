import dawesometoolkit.*;

class rndOffset {
  int mimumumRNDoffset; int maximumRNDoffset;
  int xOffset; int yOffset;

  // randomizes offsets
  void randomizeOffsets() {
    xOffset = int(random(mimumumRNDoffset, maximumRNDoffset));
    yOffset = int(random(mimumumRNDoffset, maximumRNDoffset));
  }

  //constructor
  rndOffset(int passedMinimumRNDoffset, int passedMaximumRNDoffset) {
    mimumumRNDoffset = passedMinimumRNDoffset; maximumRNDoffset = passedMaximumRNDoffset;
    randomizeOffsets();
  }
}

// GLOBALS
DawesomeToolkit dawesome;
int numberOfCoordinates = 108;
ArrayList<PVector> layout;
ArrayList<rndOffset> rndOffsets;
int dotSize = 14;
int xPixelsApart = 60; boolean xPixelsApartShrinking = true;

void setup(){
  fullScreen();
  //size(600,600);
  dawesome = new DawesomeToolkit(this);
  //parameters to .gridLayout: numberOfPoints, xPixelsApart, yPixelsApart, numberOfColumns: 
  layout = dawesome.gridLayout(numberOfCoordinates,60,50,12);
  // BREAKS THIS if uncommented:
  //layout = dawesome.vogelLayout(200,10);
  // center the layout so 0,0 is the center:
  layout = dawesome.centerPVectors(layout);
  rndOffsets = new ArrayList<rndOffset>();
  //add numberOfCoordinates to that list (to be correlated with coordinates on the layout):
  for (int i = 0; i < numberOfCoordinates; i++) {
    rndOffsets.add(new rndOffset(-4, 4));
  }

  fill(#5c38ff);
}


void shiftXpixelsApart() {
  if (xPixelsApartShrinking == true) {
    xPixelsApart -= 1;
  }
}

void draw(){
  background(#656767);
  noStroke();
  translate(width/2,height/2);
  int idxCounter = 0;
  for (PVector p : layout) {
    int rndX = rndOffsets.get(idxCounter).xOffset;
    int rndY = rndOffsets.get(idxCounter).yOffset;
    // call the function in that which randomizes x and y:
    rndOffsets.get(idxCounter).randomizeOffsets();
    //int rndX = rndOffsets.get(idxCounter).xOffset;
    ellipse(p.x + rndX, p.y + rndY, dotSize, dotSize);
    idxCounter+=1;
  }
  delay(96);
  shiftXpixelsApart();
}
