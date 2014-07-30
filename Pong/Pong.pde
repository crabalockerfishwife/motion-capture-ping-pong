import ddf.minim.*;
import processing.video.*;

//final static int id = (int) random(100,999);

float handX, handY;

Capture cam;
int[][] objects;
int l, h;
ArrayList<Integer> label;
ArrayList<Integer> unique;
int[][] edges;
ArrayList<Float> xLoc = new ArrayList<Float>();
ArrayList<Float> yLoc = new ArrayList<Float>();
float[] COG = new float[2];
float[][] oleCOG = new float[3][2];
int frCo = 0;

color topLeft;
boolean game=false;
ArrayList<Float>allGR = new ArrayList<Float>();
ArrayList<Float>allGB = new ArrayList<Float>();
ArrayList<Float>allBR = new ArrayList<Float>();
ArrayList<Float>allGreen = new ArrayList<Float>();
ArrayList<Float>allBlue = new ArrayList<Float>();
ArrayList<Float>allRed = new ArrayList<Float>();
boolean capture=false;
boolean musicstarted=false;
float minGR,maxGR,minGB,maxGB,minBR,maxBR;
float aveGR,aveGB,aveBR;

float padR,padG,padB;

float[][] matrix = {{1,1,1},{1,1,1},{1,1,1}};

AudioPlayer audioPlayer;
AudioPlayer hitSound;
Minim minim;
Minim hitMinim;

PImage background;
float score, highscore;
float ballX, ballY, ballZ;
float xVel, yVel, zVel;
boolean dead=true;

ArrayList<Float>paddleSizes=new ArrayList<Float>();

void setup() {
  l=640;
  h=480;
  size(l, h); 
  restart();
  highscore=0;

  minim = new Minim(this);
  audioPlayer = minim.loadFile("Tomato.mp3");
  hitMinim = new Minim(this);
  hitSound = hitMinim.loadFile("Hit.mp3");
  
  ballZ=0.5;

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, l, h);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {

    cam = new Capture(this, cameras[0]);

    cam.start();
  }
  label = new ArrayList<Integer>();
  label.add(0);
  unique = new ArrayList<Integer>();
}

void draw(){
 if(game){
   game();
   if(!musicstarted){
     audioPlayer.play();
     audioPlayer.loop(); 
     musicstarted=true;
   }
 }
 else calibrate();
 
 if(allGR.size()>=100){
   float minGreen=allGreen.get(0);
   float maxGreen=allGreen.get(0);
   float minBlue=allBlue.get(0);
   float maxBlue=allBlue.get(0);
   float minRed=allRed.get(0);
   float maxRed=allRed.get(0);
   
   float aveGreen=0;
   float aveBlue=0;
   float aveRed=0;
   
   for(Float f:allGreen){
     aveGreen+=f;
     if(minGreen>f)minGreen=f; 
     if(maxGreen<f)maxGreen=f;
   }
   for(Float f:allBlue){
     aveBlue+=f;
     if(minBlue>f)minBlue=f; 
     if(maxBlue<f)maxBlue=f;
   }
   for(Float f:allRed){
     aveRed+=f;
     if(minRed>f)minRed=f; 
     if(maxRed<f)maxRed=f;
   }
   
   aveGreen/=allGreen.size();
   aveBlue/=allBlue.size();
   aveRed/=allRed.size();
   
   padR=aveRed;
   padG=aveGreen;
   padB=aveBlue;
   
   minBlue+=(aveBlue-minBlue)/10;
   maxBlue+=(aveBlue-maxBlue)/10;
   minGreen+=(aveGreen-minGreen)/10;
   maxGreen+=(aveGreen-maxGreen)/10; 
   minRed+=(aveRed-minRed)/10;
   maxRed+=(aveRed-maxRed)/10;
   
   minGB=minGreen/maxBlue;
   maxGB=maxGreen/minBlue;
   minGR=minGreen/maxRed;
   maxGR=maxGreen/minRed;
   minBR=minBlue/maxRed;
   maxBR=maxBlue/minRed;
   
   game=true;
 }
}

void calibrate(){
  if (cam.available() == true) {
    cam.read();
  }
  cam.loadPixels();
  for (int c = 0; c < cam.width; c++) { // For each pixel in the cam frame...
    for (int r = 0; r < cam.height; r++) {
      int loc = (cam.width - c - 1) + r*cam.width;
      int pixLoc = c + r*width;
      color currColor = cam.pixels[loc]; 
      pixels[pixLoc] = color(currColor);
    }
  }
  updatePixels();
  loadPixels();
  topLeft=color(pixels[0]);
  fill(255);
  textSize(20);
  if(!capture){
    text("Hold paddle over the top left corner, and press spacebar.",0,height-50); 
  }
  else{
    text("Capturing...",width/2-50,height-50);
    allGR.add(green(topLeft)/red(topLeft));
    allBR.add(blue(topLeft)/red(topLeft));
    allGB.add(green(topLeft)/blue(topLeft));
    allGreen.add(green(topLeft));
    allBlue.add(blue(topLeft));
    allRed.add(red(topLeft));
  }
  
  if(keyPressed && key==' '){
   capture=true; 
  }
}

void game() {
  background(255);
  translate(width/2, height/2);
  camstuff();
  stroke(0);
  imageMode(CENTER);
  tint(255, 235);
  image(background, 0, 0, width, height);
  textSize(15);
  fill(0);
  text("Score: "+score, -280, -220);
  text("Highscore: "+highscore, 100, -220);
  fill(255*ballZ);
  if (ballZ>0.75 && zVel>0)fill(0, 255*ballZ, 0);
  ellipse(ballX*ballZ, ballY*ballZ, 50*ballZ, 50*ballZ);

  fill(255, 128, 128, 20);
  ellipse(ballX, ballY, 50, 50); //A projection of where the paddle needs to be to hit the ball.

  fill(padR, padG, padB*0, 100);
  rectMode(CENTER);
  rect(handX-width/2, handY-height/2, 50, 50);
  
  ballX+=xVel;
  ballY+=yVel;
  ballZ+=zVel;
  if (ballZ<=0.0) {
    zVel=abs(zVel);
  }
  if (ballZ>=1.1) {
    background(0);
    fill(128, 0, 0);
    textSize(50);
    text("GAME OVER\nScore: "+score, 0, 0);
    audioPlayer.pause();
    musicstarted=false;
    dead = true;
    if (score>highscore) {
      highscore = score;
    }
  }
  if (ballX<=(width/-2)+25) {
    xVel=abs(xVel);
  }
  if (ballX>=(width/2)-25) {
    xVel=abs(xVel)*-1;
  }
  if (ballY<=(height/-2)+25) {
    yVel=abs(yVel);
  }
  if (ballY>=(height/2)-25) {
    yVel=abs(yVel)*-1;
  }
  if (dead) {
    if (keyPressed) {
      if (key==ENTER) {
        restart();
      }
    }
  }
  float aveSize=0;
  for (Float f : paddleSizes) {
    aveSize+=f;
  }
  aveSize/=paddleSizes.size();
  
  if (paddleSizes.size()>2 && abs(paddleSizes.get(paddleSizes.size()-1)-paddleSizes.get(paddleSizes.size()-2))>abs(aveSize*0.5)) {
    hit();
  }
  
}

void hit() {
  fill(padR*2, padG*2, padB*2, 100);
  rectMode(CENTER);
  rect(handX-width/2, handY-height/2, 50, 50);
  if (ballZ>0.75 && ballZ<1.1 && zVel>0) {
    if (handX-width/2>ballX-50 && handX-width/2<ballX+50 && handY-height/2>ballY-50 && handY-height/2<ballY+50) {
      //////println("hit");
      hitSound.play();
      hitSound.rewind();
      zVel=(0.7-ballZ)/100-score/1000;
      xVel+=(ballX-(handX-width/2))/10;
      yVel+=(ballY-(handY-height/2))/10;
      score++;
    }
  } else {
    //score-=0.05;
  }
}

void setupScreen() {
  background=loadImage("Background.png");
  ballZ=0.01;
  zVel=0.01;
  xVel=random(5)-2.5;
  yVel=random(5)-2.5;
}

void restart() {
  score=0;
  dead=false;
  setupScreen();
}


//CAMSTUFF
//CAMSTUFF
//CAMSTUFF BUFFER

void camstuff() {
  if (cam.available() == true) {
    cam.read();
  }
  cam.loadPixels();
  for (int c = 0; c < cam.width; c++) { // For each pixel in the cam frame...
    for (int r = 0; r < cam.height; r++) {
      int loc = (cam.width - c - 1) + r*cam.width;
      int pixLoc = c + r*width;
      color currColor = cam.pixels[loc]; 
      pixels[pixLoc] = color(currColor);
    }
  }
  updatePixels();
  
  
  blur();
  
  //image(cam, 0, 0);
  objects = new int[h][l];


  label.clear();
  label.add(0);
  unique.clear();

  loadPixels();
  markBlobs();
  //updatePixels();

  markSeparate();
  findUnique();

  fillBiggest();
  findEdges();
  //updatePixels();

  //pause();
  //fill(0,255,255);
  //ellipse(COG(xLoc, yLoc)[0] , COG(xLoc, yLoc)[1], 50, 50);
  handX=COG(xLoc, yLoc)[0];
  handY=COG(xLoc, yLoc)[1];
}

void fillBiggest() {

  int[] sizes = new int[ unique.get( unique.size() -1) + 1];
  for (int y = 0; y<h; y++) {
    for (int x = 0; x<l; x++) {
      int cur = y*l+x;
      if (objects[y][x] != 0) {
        int i = objects[y][x];
        while ( ( (int)label.get(i)) != i ) {
          i = label.get(i);
        } 
        sizes[i]++;
      }
    }
  }
  int biggest = 0;
  for (int i =0; i< sizes.length; i++) {
    if (sizes[i] > sizes[biggest]) {
      biggest = i;
    }
  }
  xLoc.clear();
  yLoc.clear();
  for (int y = 0; y<h; y++) {
    for (int x = 0; x<l; x++) { 
      int cur = y*l+x;
      if (objects[y][x] != 0) {
        int i = objects[y][x];
        while ( ( (int)label.get(i)) != i ) {
          i = label.get(i);
        } 
        if (i == biggest) {
          pixels[cur] = color(255);
          xLoc.add((float)x);
          yLoc.add((float)y);
        } else {
          pixels[cur] = color(0);
        }
      }
    }
  }
}

void markBlobs() {
  for (int y = 0; y < h; y++) {
    for (int x = 0; x <l; x++) {
      if (isHand( pixels[y*l + x])) {
        pixels[ y * l + x ] = color(255);
        objects[y][x] = 255;
      } else {
        pixels[ y * l + x ] = color(0);
        objects[y][x] = 0;
      }
    }
  }
}

boolean isHand(color c) {
  float green = green(c);
  float blue = blue(c);
  float red = red(c);
  if (brightness(c)>100 && (green/blue < maxGB) && (green/blue > minGB) && (green/red > minGR) && (green/red < maxGR) && (blue/red > minBR) && (blue/red < maxBR) ) {
    return true;
  } else {
    return false;
  }
}

void findEdges() {
  edges = new int[4][2];
  // find top
A:
  for (int y = 0; y<h; y++) {
B: 
    for (int x = 0; x < l; x++) {
      if (pixels[ y*l + x] != color(0) ) {
        edges[0][0] = y;
        edges[0][1] = x;
        break A;
      }
    }
  }

  // find bottom
C: 
  for (int y = h-1; y > -1; y--) {
D: 
    for (int x = 0; x < l; x++) {
      if (pixels[ y*l + x] != color(0) ) {
        edges[1][0] = y;
        edges[1][1] = x;
        break C;
      }
    }
  }

  // find left
E: 
  for (int x = 0; x < l; x++) {
F: 
    for (int y = 0; y < h; y++) {
      if (pixels[ y*l + x] != color(0) ) {
        edges[2][0] = y;
        edges[2][1] = x;
        break E;
      }
    }
  }

  // right
G: 
  for (int x = (l-1); x > -1; x--) {
H: 
    for (int y = 0; y < h; y++) {
      if (pixels[ y*l + x] != color(0) ) {
        edges[3][0] = y;
        edges[3][1] = x;
        break G;
      }
    }
  }
  /*
  ellipseMode(CENTER);
   fill(255);
   for (int i =0; i < edges.length; i++) {
   ellipse( edges[i][1], edges[i][0], 10, 10);
   ////println( edges[i][0] + " , " + edges[i][1] );
   }
   */
  makeRect( edges );
}

void makeRect( int[][] coords ) {
  // order: top, bottom, left, right
  int maxY, minY, maxX, minX;
  maxY = coords[0][0];
  minY = coords[1][0];
  maxX = coords[3][1];
  minX = coords[2][1];
  rectMode(CORNER);
  noFill();
  stroke(255, 0, 0);
  rect( minX, minY, maxX - minX, maxY - minY );
  paddleSizes.add(new Float((maxY-minX)*(maxY-minY)));
  if (paddleSizes.size()>20)paddleSizes.remove(0);
  fill(255);
}

void markSeparate() {
  int cnt = 1;
  int cur;

  for (int y = 0; y<h; y++) {
    for (int x = 0; x<l; x++) {

      cur = y*l+x;
      int a = 0;
      int b = 0;
      int c = 0;
      int d = 0;
      if ( objects[y][x] == 255) {

        if ( inBounds(y-1, x-1) ) {
          a = objects[y-1][x-1];
        }

        if ( inBounds(y-1, x) ) {
          b= objects[y-1][x];
        }
        if ( inBounds(y-1, x+1) ) {
          c = objects[y-1][x+1];
        }
        if ( inBounds(y, x-1) ) {
          d = objects[y][x-1];
        }
        if ( a==0 && b==0 && c==0 && d==0 ) {
          objects[y][x] = cnt;
          label.add(cnt);
          cnt++;
        } else {
          int min = findMin(a, b, c, d);
          objects[y][x] = min;
          if (a!=0) {
            label.set( a, min );
          }
          if (b!=0) {
            label.set( b, min );
          }
          if (c!=0) {
            label.set( c, min ); 
          }
          if (d!=0) {
            label.set( d, min ); 
          }
        }
      }
    }
  }
}

boolean inBounds( int i, int j ) {
  return ( i > -1 && j > -1 && i < h && j < l );
}

void findUnique() {
  for (int i =0; i<label.size (); i++) {
    if ( ((int)label.get(i)) == i ) {
      unique.add(i);
    }
  }
  /*
  //if (start) {
   blobs = new color[ unique.size() ];
   for (int i = 0; i < blobs.length; i++) {
   blobs[i] = color( random(255), random(255), random(255 ) );
   }
   //start = false;
   //}
   */
}

int findMin( int a, int b, int c, int d ) {
  ArrayList<Integer> cont = new ArrayList<Integer>();
  if (a!=0)
    cont.add(a);
  if (b!=0)
    cont.add(b);
  if (c!= 0)
    cont.add(c);
  if (d!= 0)
    cont.add(d);

  int ret = cont.get(0);
  for (int i = 1; i < cont.size (); i++) {
    if (cont.get(i) < ret) {
      ret = cont.get(i);
    }
  }

  return ret;
}

void pause (int s) {
  int mili = millis();
  while (millis () < mili + 1000 * s) {
  }
}

float[] COG (ArrayList<Float> x, ArrayList<Float> y) {
  float[] ans = new float[2];
  newCOG(x, y);
  for (int h = 0; h < oleCOG.length; h++) {
    ans[0] += oleCOG[h][0];
    ans[1] += oleCOG[h][1];
  }
  ans[0] = ans[0]/oleCOG.length;
  ans[1] = ans[1]/oleCOG.length;
  return ans;
}

float[] newCOG (ArrayList<Float> x, ArrayList<Float> y) {
  if (frCo >= oleCOG.length) {
    frCo = 0;
  }
  float[] ans = new float[2];
  for (int h = 0; h < x.size (); h++) {
    ans[0] += x.get(h);
  }
  for (int c = 0; c < y.size (); c++) {
    ans[1] += y.get(c);
  }
  ans[0] = ans[0]/x.size();
  ans[1] = ans[1]/y.size();
  /*if ( (COG[0] > (-1.0 - 0.00001)) && (COG[0] < (-1.0 + 0.00001))) { 
   COG = ans;
   } else if (ans[0]*/
  oleCOG[frCo] = ans; 
  frCo++;
  return ans;
}


void blur() {
  //if (toggle) {
  loadPixels();

  for (int c = (matrix.length - 1)/2; c < cam.width-(matrix.length - 1)/2; c++) { // For each pixel in the cam frame...
    for (int r = (matrix.length - 1)/2; r < cam.height-(matrix.length - 1)/2; r++) {
      int loc = c + r*width;
      color neCo = convolve(matrix, c - (matrix.length - 1)/2, r - (matrix.length - 1)/2);
      pixels[loc] = neCo;
    }
  }
  updatePixels();
}


color convolve (float[][] matrix, int x, int y) {
  float red =0;
  float green =0;
  float blue =0;
  float sum =0;
  for(int c = 0; c < matrix.length; c++) {
    for (int h = 0; h < matrix[c].length; h++) {
      int loc = (x + c) + (y + h)*width;
      red += (red(pixels[loc]) * matrix[c][h]);
      green += (green(pixels[loc]) * matrix[c][h]);
      blue += (blue(pixels[loc]) * matrix[c][h]);
      sum += matrix[c][h];
    }
  }
  red /= sum;
  green /= sum;
  blue /= sum;
  return color(red,green,blue);
}
