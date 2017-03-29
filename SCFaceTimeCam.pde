// use and convert facetime cam images to float array and played back by SuperCollider

// functionality:
// access webcam
// use brightness, scale between -1, 1
// write to buffer
// OSCmessage to SuperCollider

// sc: set buffer to message, play back
// 

import oscP5.*;
import netP5.*;
import processing.video.*;

Capture video;
OscP5 osc;
NetAddress supercollider;
float buffer[];
int bufferSize;
int fps;
float randomCoord[][];
int randSize;
float pixelBrightness;
float freq, amp;


void setup() {
//  println(Capture.list());
  size(1280, 720);
  fps = 30;
  video = new Capture(this, 1280, 720, fps);
  video.start();
  
  // buffer to send to SC:
  bufferSize = width;
  buffer = new float[bufferSize];
  osc = new OscP5(this, 12000);
  supercollider = new NetAddress("127.0.0.1", 57120);
  
  // set draw() frame rate to video frame rate
  frameRate(fps);
  
  randSize = 15;
  randomCoord = new float[randSize][2];
  background(255);
}


void draw() {
    //display webcam image
    if(video.available()) {
    video.read();
  }
  
   int randInt1 = (int)random(randSize);
   int randInt2 = (int)random(randSize);
   float randomX1 = randomCoord[randInt1][0];
   float randomY1 = randomCoord[randInt1][1];
   float randomX2 = randomCoord[randInt2][0];
   float randomY2 = randomCoord[randInt2][1];
   
   // freq / amp sensitive circles
   float amp_mult = 3;
   amp = amp * amp_mult;
   noStroke();
   colorMode(HSB, 1255);
   fill(freq, amp * 1255, amp * 1255, 15);
   ellipse(randomX1, randomY1, amp * 100 , amp * 100);
  

  // read brightness of webcam's first pixel row 
  video.loadPixels();
  for (int i = 0; i < bufferSize; i++) {
    colorMode(RGB, 255);
    int pixelValue = video.pixels[i];
    float pixelBrightness = brightness(pixelValue);
    // scale brightness value between -1 and 1 for Audio playback
     buffer[i] = pixelBrightness/127.5 - 1;
     
     // shape lines
     if (i % 1000 == 0) {
       stroke(10, 10, 10, 10);
       line(randomX1, randomY1, randomX2, randomY2);
     }
     
     // random lines
     if (i % 100 == 0) {
       stroke(10, 10, 10, 10);
       line(random(width), random(height), random(width), random(height));
     }
}
  
 // send scaled pixel brightness buffer to SC
  OscMessage msgPixelBuf = new OscMessage("/webcam");
  msgPixelBuf.add(buffer);
  osc.send(msgPixelBuf, supercollider);
 
 // add timeable graphics
 
 
 if (second() % 20 == 0) {
  for (int i = 0; i < randSize; i++) {
    randomCoord[i][0] = random(width);
    randomCoord[i][1] = random(height);
  }
  if (second() % 5 == 0) {
    fill(255, 25);
    rect(0, 0, width, height);
  }
 }
 
}

// frequency and amplitude message from sc output bus 0
void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.addrPattern().equals("/adress")) {
    freq = theOscMessage.get(0).floatValue();
    amp = theOscMessage.get(1).floatValue();
    print("freq:" + freq + "\n");
    print("amp:" + amp + "\n");
  }
}