import dawesometoolkit.*;

DawesomeToolkit dawesome;
ArrayList<PVector> grid;
int dotSize = 26;
float xPositionOffset = 0;
float xOffsetIncrement = 1.5;
float maxOffsetAbsoluteValue = 150;
boolean xVectorIsPositive = true;

void flipxVectorIsPositive() {
  //print("xVectorIsPositive val: " + xVectorIsPositive + "\n");
  if (xVectorIsPositive == true) {
    xVectorIsPositive = false;
    //print("true case triggered.\n");
  } else {
    xVectorIsPositive = true;
    //print("false case triggered.\n");
  }
}

void changeScale() {
  if (xVectorIsPositive == true) {
    xPositionOffset += xOffsetIncrement;
    // print("adding to xOffsetIncrement; is " + xPositionOffset +"\n");
  }
  else {
    xPositionOffset -= xOffsetIncrement;
    // print("subtracing from xOffsetIncrement; is " + xPositionOffset +"\n");
  }
  if ( abs(xPositionOffset) >= maxOffsetAbsoluteValue ) {
    flipxVectorIsPositive();
  }
}

void setup(){
  size(600,600);
  noStroke();
  dawesome = new DawesomeToolkit(this);
  //paramaters to gridLayout are:
  //number of points, x distance between them, y distance between them, number of columns
  grid = dawesome.gridLayout(20,30,70,5);
  grid = dawesome.centerPVectors(grid);
}

void draw(){
  background(#313131);
  fill(#ff00ff);
  translate(width/2,height/2);
  int counter = 0;
  for (PVector p : grid) {
    // NOTE: if I intend to operate on a copy of p, I should use p.copy(), OR ELSE I'LL GET A REFERENCE TO p; in that case I should do something like:
    // PVector tmp_vec = p.copy();
    // OR force it to copy by value (not reference) by compbining it with another operator, like this:
    float tmpXpos = p.x + xPositionOffset;
    ellipse(tmpXpos, p.y, dotSize, dotSize);
    counter += 1;
  }
  //delay(500);
  changeScale();
  // in the documentation there is this function that takes these parameters, but it crashes with a does not exist error when I attempt to use it. The function is also in the source code that I find on GitHub. It just doesn't work;
  // that documentation is at: http://cloud.brendandawes.com/dawesometoolkit/reference/index.html
  //grid = dawesome.multiplyPVectors(grid, 2);
}
