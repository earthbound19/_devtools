// DESCRIPTION
// Experiment hacking another script (vogel_spiral_dots_animated.pde) to generate random constellation-like collections of dots connected by lines.

// DEPENDENCIES
// dawesome toolkit (Processing library)

// USAGE
// Install Processing, open this file in the Processing editor or a Processing script runner, and run the script.


// CODE
String version = "1.0.0";
// This git commit: parameter set 2 (a variant of the work).

import dawesometoolkit.*;
// import java.util.ArrayList;    // imported by default?
import java.util.Collections;

class rotatingColorIDX {
  int colorIDX = 0;
  int maxColorIDX = 0;
  
  rotatingColorIDX(int initColorIDX, int passedMaxColorIDX) {
    colorIDX = initColorIDX;
    maxColorIDX = passedMaxColorIDX;
  }
  
  void rotateColorIDX() {
    colorIDX += 1;
    if (colorIDX >= maxColorIDX) {colorIDX = 0;}
  }
}

DawesomeToolkit dawesome;
int howManyVogelPoints;   // intended to determine the length of the following ArrayList:
ArrayList<PVector> vogelLayout;
ArrayList<rotatingColorIDX> bgPointColors;
int backgroundDotSize = 21;
int foregroundDotSize = 15;
int vogelPointsDistance = 13;
color[] backgroundDotRNDcolors = {
  #01EDFD, #00FFFF, #00CCCC, #0CCAB3, #00A693, #009B7D, #008B8B, #008080, #006D6F, #004C54, #007BA7, #0D98BA, #00B7EB, #00A6FE, #3AA8C1, #43B3AE, #3AB09E, #20B2AA, #40E0D0, #7DF9FF, #B2FFFF, #E0FFFF, #C0E8D5, #A8C3BC, #88D8C0, #7FFFD4, #87D3F8, #40826D, #2E8B57, #00A86B
};
int backgroundDotRNDcolorsArrayMaxIDX = backgroundDotRNDcolors.length;

void setup(){
  // fullScreen();
  size(800,800);   // prev. values: 1200,630
  // size(1920,1080);
  boolean widthGreaterThanHeight;
  //determine if width or height is greater and do math on the larger value:
  if (width > height) {howManyVogelPoints = int(width * .95);} else {howManyVogelPoints = int(height * .95);}   // prev. intended fill value: 3.8
  dawesome = new DawesomeToolkit(this);
  vogelLayout = dawesome.vogelLayout(howManyVogelPoints,vogelPointsDistance);
  bgPointColors = new ArrayList<rotatingColorIDX>();
  
  // init bgPointColors ArrayList; thx to help from: https://stackoverflow.com/a/3982597
  bgPointColors = new ArrayList<rotatingColorIDX>();
  int bgColorInitIDX = 0;
  for (PVector p : vogelLayout) {
    // add one to bgPointColors for every point in layout, with rnd start IDX, highest poss idx backgroundDotRNDcolorsArrayMaxIDX:
      // had at first chosen rnd bg color; wanted to see how it looks with rotate through them per point:
      // int bgColorInitIDX = (int) random(0, backgroundDotRNDcolorsArrayMaxIDX);
    bgPointColors.add(new rotatingColorIDX(bgColorInitIDX, backgroundDotRNDcolorsArrayMaxIDX));
    // increment the color idx and reset to zero if above max index:
    bgColorInitIDX += 1; if (bgColorInitIDX >= backgroundDotRNDcolorsArrayMaxIDX) {bgColorInitIDX = 0;}
  }
  
  noStroke();
}

void draw(){
  clear();
  //background(#656767);
  background(#362e2c);
  translate(width/2,height/2);

  // randomly wiggling vogel dots behind the main, non-wiggling dots:
  int layoutPointCounter = 0;
    int bgPointColorIDX = bgPointColors.get(layoutPointCounter).colorIDX;
    color bgPointColor = backgroundDotRNDcolors[bgPointColorIDX];
    fill(bgPointColor);
  int howManyStars = (int) random(5, 13);
//  print("will create from " + howManyStars + " points.\n");
  ArrayList<PVector> starPVectors = new ArrayList<PVector>();
  for (int i = 0; i < howManyStars; i++) {
      int RNDx = int(random(-4, 4));
      int RNDy = int(random(-4, 4));
      int RNDbgColorDotIDX = (int) random(backgroundDotRNDcolorsArrayMaxIDX);
      fill(backgroundDotRNDcolors[RNDbgColorDotIDX]);
    int rndVogelLayoutIDX = (int) random(0, howManyVogelPoints);
    PVector starLocation = vogelLayout.get(rndVogelLayoutIDX);
//    print("got " + (int) starLocation.x + " and " + (int) starLocation.y + " .. ");
    starPVectors.add(starLocation);
    // COMMENT THIS OUT once I get a sorted list to use:
    ellipse(starLocation.x + RNDx, starLocation.y + RNDy, backgroundDotSize + RNDx, backgroundDotSize + RNDx);
  }
  // bubble sort point list to be sorted by nearest point next; do this to a copy of the ArrayList:
  // ArrayList<PVector> starPVectorsNearestSort = new ArrayList<PVector>();
  // for (PVector c : starPVectors) { starPVectorsNearestSort.add(c); }    // is there a function that copies ArrayLists though?
  // starPVectorsNearestSort = 
  print("NEW VARIANT . . .\n");
  float dist;
  float shortestFoundDist = 378278.01;
  // float shortestFoundDistTMP = 0;
  for (PVector p : starPVectors) {
    for (PVector q : starPVectors) {
      dist = p.dist(q);
      if (dist < shortestFoundDist && dist != 0) {
        print("dist " + dist + " < shortestFoundDist " + shortestFoundDist + " . . ");
        shortestFoundDist = dist;
      }
    }
    print ("shortest found dist: " + shortestFoundDist + "\n");
    shortestFoundDist = 378278.01;
  }
    // increment associated bgPointColors color IDX:
    bgPointColors.get(layoutPointCounter).rotateColorIDX();
    layoutPointCounter += 1;
      // FORMER CODE:
      // fixed color, slightly smaller, fixed position dots in front of those; OR, if you comment out the next fill line, the fill color is the same in every one but rotates! :
      //fill(#5c38ff);  // medium blue-violet
      // for (PVector p : vogelLayout) {
      // ellipse(p.x, p.y, foregroundDotSize, foregroundDotSize);
  // saveFrame("/##########.png");
  delay(1800);
}
