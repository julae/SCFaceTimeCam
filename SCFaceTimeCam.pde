// use and convert facetime cam images to float array and played back by SuperCollider

// functionality:
// access webcam
// use brightness, scale between -1, 1
// write to buffer
// OSCmessage to SuperCollider

// supercollider side: set buffer to message, play back


import oscP5.*;
import netP5.*;
import processing.video.*;

Capture video;
OscP5 osc;
NetAddress supercollider;
float buffer[];
int bufferSize;
int fps;

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
}


void draw() {
  //display webcam image
    if(video.available()) {
    video.read();
  }
  image(video, 0, 0);
  
  
  // read brightness of webcam's first pixel row 
  video.loadPixels();
  for (int i = 0; i < bufferSize; i++) {
    int pixelValue = video.pixels[i];
    float pixelBrightness = brightness(pixelValue);
    // scale brightness value between -1 and 1 for Audio playback
     buffer[i] = pixelBrightness/127.5 - 1;
  }
  updatePixels();
  
  
 // send scaled pixel brightness buffer to SC
  OscMessage msgPixelBuf = new OscMessage("/webcam");
  msgPixelBuf.add(buffer);
  osc.send(msgPixelBuf, supercollider);
 
}