// CODE
String version = "0.2.0";
int numCoordinates;
ArrayList<motionPoint> motionPoints;

import dawesometoolkit.*;
import java.util.*;

DawesomeToolkit dawesome;
ArrayList<PVector> spiral;
int pointsDistance = 13;
color[] dotColors = {
  #01EDFD, #00FFFF, #00CCCC, #0CCAB3, #00A693, #009B7D, #008B8B, #008080, #006D6F, #004C54, #007BA7, #0D98BA, #00B7EB, #00A6FE, #3AA8C1, #43B3AE, #3AB09E, #20B2AA, #40E0D0, #7DF9FF, #B2FFFF, #E0FFFF, #C0E8D5, #A8C3BC, #88D8C0, #7FFFD4, #87D3F8, #40826D, #2E8B57, #00A86B
};
float motoinPointMaxBearing = 2;  // is used also as minimum via * -1
float averageDotSize = 10;

color getRNDdotColor() {
  int rndColorIDX = (int) random(dotColors.length);
  return dotColors[rndColorIDX];
}

class motionPoint {
  PVector location;
  PVector bearing;
  color pointColor;
  float size;
  // constructor:
  motionPoint(PVector locationParam, PVector bearingParam, color colorParam, float sizeParam) {
    location = locationParam.copy();
    bearing = bearingParam.copy();
    pointColor = colorParam;
    size = sizeParam;
  }
  // location update via bearing:
  void move() {
    location.add(bearing);
    // if x out of bounds, wrap around:
    float xABS = Math.abs(location.x);
    if (location.x < 0 || location.x > width) {
      location.x = width - xABS;
    }
    // if y out of bounds, wrap around:
    float yABS = Math.abs(location.y);
    if (location.y < 0 || location.y > width) {
      location.y = width - yABS;
    }
  }
}

void newVariant() {
  int howManyPoints = (int) (width * 0.7);
  // make layout:
  dawesome = new DawesomeToolkit(this);
  spiral = dawesome.vogelLayout(howManyPoints,pointsDistance);
  // shuffle layout and get first N elements from it, using them to build motionPoints:
  Collections.shuffle(spiral);
numCoordinates = (int) random(5, 13);
    // (re)allocate ArrayList memo:
  motionPoints = new ArrayList<motionPoint>();
  for (int i = 0; i < numCoordinates; i++) {
    PVector iterVector = spiral.get(i);
    float motionBearingParamX = random(motoinPointMaxBearing * -1, motoinPointMaxBearing);
    float motionBearingParamY = random(motoinPointMaxBearing * -1, motoinPointMaxBearing);
    PVector motionBearingParam = new PVector(motionBearingParamX, motionBearingParamY);
    float dotSizeParam = random(averageDotSize * 0.5, averageDotSize * 1.5);
    motionPoint pt = new motionPoint(
                                      iterVector,
                                      motionBearingParam,
                                      getRNDdotColor(),
                                      dotSizeParam
                                    );
    motionPoints.add(pt);
  }
  // empty the dawesome layout (since we got what we want from it and won't use it further:
  spiral = new ArrayList<PVector>();  
}


void setup() {
  //fullScreen();
  size(512, 512);
  boolean widthGreaterThanHeight;
  noStroke();
  newVariant();
}

void draw() {
  clear();
  background(#362e2c);
  for (motionPoint p : motionPoints) {
    fill(p.pointColor);
    ellipse(p.location.x, p.location.y, p.size, p.size);
    p.move();
  }
}


void mousePressed() {
  newVariant();
}

void keyPressed() {
  newVariant();
}