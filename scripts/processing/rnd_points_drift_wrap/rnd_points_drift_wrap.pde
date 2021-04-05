// CODE
String version = "0.0.1";

import dawesometoolkit.*;

DawesomeToolkit dawesome;
ArrayList<PVector> layout;
int dotSize = 10;
int vogelPointsDistance = 13;
color[] dotColors = {
  #01EDFD, #00FFFF, #00CCCC, #0CCAB3, #00A693, #009B7D, #008B8B, #008080, #006D6F, #004C54, #007BA7, #0D98BA, #00B7EB, #00A6FE, #3AA8C1, #43B3AE, #3AB09E, #20B2AA, #40E0D0, #7DF9FF, #B2FFFF, #E0FFFF, #C0E8D5, #A8C3BC, #88D8C0, #7FFFD4, #87D3F8, #40826D, #2E8B57, #00A86B
};

void setup(){
  //fullScreen();
   size(512, 512);
  boolean widthGreaterThanHeight;
  //determine if width or height is greater and do math on the larger value:
  int howManyVogelPoints = (int) (width * 0.5);
  dawesome = new DawesomeToolkit(this);
  layout = dawesome.vogelLayout(howManyVogelPoints,vogelPointsDistance);
  noStroke();
}

void draw(){
  clear();
  background(#362e2c);
  translate(width/2,height/2);

  // randomly wiggling vogel dots behind the main, non-wiggling dots:
  for (PVector p : layout) {
    ellipse(p.x, p.y, dotSize, dotSize);
  }
}
