

import processing.video.*;

int numPixels;
int[] backgroundPixels;
Capture video;
boolean begCol = false;

ArrayList<Float> reds = new ArrayList<Float>();
ArrayList<Float> greens = new ArrayList<Float>();
ArrayList<Float> blues = new ArrayList<Float>();
ArrayList<Float> ratGR = new ArrayList<Float>();
ArrayList<Float> ratGB = new ArrayList<Float>();
ArrayList<Float> ratBR = new ArrayList<Float>();

void setup() {
  size(640, 480); 

  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  //video = new Capture(this, 160, 120);
  video = new Capture(this, width, height);

  // Start capturing the images from the camera
  video.start();  

  numPixels = video.width * video.height;
  // Create array to store the background image
  backgroundPixels = new int[numPixels];
  // Make the pixels[] array available for direct manipulation
  loadPixels();
}

void draw() {
  if (video.available()) {
    video.read(); // Read a new video frame
    //image(video, 0,0);
    video.loadPixels(); 

    int presenceSum = 0;
    for (int c = 0; c < video.width; c++) { // For each pixel in the video frame...
      for (int r = 0; r < video.height; r++) {
        int loc = (video.width - c - 1) + r*video.width;
        int pixLoc = c + r*width;
        if (c == 0 && r == 0) {
          if (begCol) {
            reds.add(red(video.pixels[loc]));
            greens.add(green(video.pixels[loc]));
            blues.add(blue(video.pixels[loc]));
            ratGR.add(green(video.pixels[loc])/red(video.pixels[loc]));
            ratGB.add(green(video.pixels[loc])/blue(video.pixels[loc]));
            ratBR.add(blue(video.pixels[loc])/red(video.pixels[loc]));
            print(ratGR.get(ratGR.size() -1) + ", ");
            print(ratGB.get(ratGB.size() -1) + ", ");
            println(ratBR.get(ratBR.size() -1));
          }
        } 
        color currColor = video.pixels[loc]; 
        pixels[pixLoc] = color(currColor);
        
      }
      updatePixels(); // Notify that the pixels[] array has changed
    }
  }
}


void keyPressed() {     
  if (!(begCol)) {
    begCol = true;
  }
  else if (begCol) {
    float[] aves = tabulation();
    println(aves[0] + ", " + aves[1] + ", " + aves[2]); 
    begCol = false;
  }
}

float[] tabulation() {
  float[] ans = new float[3];
  float red =0;
  float green =0;
  float blue =0;
  float rGR;
  float rGB;
  float rBR;
  for (int r = 0; r < reds.size(); r++) {
    red += reds.get(r);
    
  }
  red = red/reds.size();
  reds = new ArrayList<Float>();
  for (int g = 0; g < greens.size(); g++) {
    green += greens.get(g);
  }
  green = green/greens.size();
  greens = new ArrayList<Float>();
  for (int b = 0; b < blues.size(); b++) {
    blue += blues.get(b);
  }
  blue = blue/blues.size();
  blues = new ArrayList<Float>();
  ans[0] = red;
  ans[1] = green;
  ans[2] = blue;
  return ans;
} 
