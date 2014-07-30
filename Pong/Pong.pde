import ddf.minim.*;
import processing.video.*;

float handX, handY;

Capture cam;
int[][] objects;
int l, h;
ArrayList<Integer> label, unique;
int[][] edges;
ArrayList<Float> xLoc = new ArrayList<Float>();
ArrayList<Float> yLoc = new ArrayList<Float>();
float[] COG = new float[2];
float[][] oleCOG = new float[4][2];
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
boolean easteregg=false;

float minGR,maxGR,minGB,maxGB,minBR,maxBR, aveGR,aveGB,aveBR;
float padR,padG,padB;

float[][] matrix = {{1,1,1},{1,1,1},{1,1,1}};

AudioPlayer audioPlayer, hitSound;
Minim minim, hitMinim;

PImage background,tomato,tomatox,spatula,spatulax;
int tomatophase;
float score, highscore;
float ballX, ballY, ballZ, xVel, yVel, zVel;
boolean dead=true;

ArrayList<Float>paddleSizes=new ArrayList<Float>();

void setup() {
  l=640;
  h=480;
  size(l, h); 
  restart();
  highscore=0;

  imageMode(CENTER);

  minim = new Minim(this);
  audioPlayer = minim.loadFile("Tomato.mp3");
  hitMinim = new Minim(this);
  hitSound = hitMinim.loadFile("Hit.mp3");
  
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
   eastereggcheck();
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

void eastereggcheck(){
  if (keyPressed && (key == 'j' || key == 's' || key == 'm' || key == 't' || key == 'y' || key == 'c')){
    if(!easteregg){
       tomato=loadImage("art/"+key+".png");
       tomatox=loadImage("art/"+key+"x.png");
    }
     else{
       loadimages(tomatophase);
     }
     easteregg=!easteregg;
  }
}

void calibrate(){
  if (cam.available()) cam.read();
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
  if(!capture) text("Hold paddle over the top left corner, and press spacebar.",0,height-50);
  else{
    text("Capturing...",width/2-50,height-50);
    allGR.add(green(topLeft)/red(topLeft));
    allBR.add(blue(topLeft)/red(topLeft));
    allGB.add(green(topLeft)/blue(topLeft));
    allGreen.add(green(topLeft));
    allBlue.add(blue(topLeft));
    allRed.add(red(topLeft));
  }
  
  if(keyPressed && key==' ') capture=true; 
}

void game() {
  if(keyPressed && key=='q')score++; //Just a little cheat for testing.
  
  translate(width/2, height/2);
  camstuff();
  tint(255, 230);
  image(background, 0, 0, width, height);
  
  textSize(15);
  fill(0);
  text("Score: "+score, -280, -220);
  text("Highscore: "+highscore, 100, -220);
  
  if (ballZ>0.75 && zVel>0)image(tomatox,ballX*ballZ, ballY*ballZ, 60*ballZ, 60*ballZ);
  else image(tomato,ballX*ballZ, ballY*ballZ, 60*ballZ, 60*ballZ);

  fill(255, 128, 128, 20);
  ellipse(ballX, ballY, 50, 50); //A projection of where the paddle needs to be to hit the ball.

  ballX+=xVel;
  ballY+=yVel;
  ballZ+=zVel*1.2;
  
  if (ballZ<=0.0) {
    zVel=abs(zVel);
  }

  if (ballZ>=1.1 || tomatophase>20) {
    background(0);
    textSize(50);
    if(ballZ>=1.1){
      fill(128, 0, 0);
      text("GAME OVER\nScore: "+score, 0, 0);
    }
    else{
      fill(128,255,128);
      text("YOU WIN\nScore: "+score, 0, 0);
    }
    textSize(20);
    text("Hit ENTER to restart",0,200);
    audioPlayer.pause();
    musicstarted=false;
    dead = true;
    if (score>highscore) highscore = score;
  }
  
  if (ballX<=(width/-2)+25) xVel=abs(xVel);
  if (ballX>=(width/2)-25) xVel=abs(xVel)*-1;
  if (ballY<=(height/-2)+25) yVel=abs(yVel);
  if (ballY>=(height/2)-25) yVel=abs(yVel)*-1;
  
  if (dead && keyPressed && key==ENTER) {
    restart();
  }
  float aveSize=0;
  for (Float f : paddleSizes) {
    aveSize+=f;
  }
  aveSize/=paddleSizes.size();
  
  if (paddleSizes.size()>2 && abs(paddleSizes.get(paddleSizes.size()-1)-paddleSizes.get(paddleSizes.size()-2))>abs(aveSize*0.5)) {
    hit();
  }
  else{
    tint(padR, padG, padB);
    image(spatula,handX-width/2, handY-height/2, 70, 70);
  }
}

void hit() {
  tint(padR*2, padG*2, padB*2);
  image(spatulax, handX-width/2, handY-height/2, -70, 70);
  if (ballZ>0.75 && ballZ<1.1 && zVel>0) {
    if (handX-width/2>ballX-50 && handX-width/2<ballX+50 && handY-height/2>ballY-50 && handY-height/2<ballY+50) {
      hitSound.play();
      hitSound.rewind();
      zVel=(0.7-ballZ)/100-score/5000;
      xVel+=(ballX-(handX-width/2))/10;
      yVel+=(ballY-(handY-height/2))/10;
      score++;
      if(score%2==0)tomatophase=(int)(score/2);loadimages(tomatophase);
    }
  }
}

void setupScreen() {
  background=loadImage("art/Background.png");
  spatula=loadImage("art/spatula.png");
  spatulax=loadImage("art/spatulax.png");
  loadimages(tomatophase);
  ballZ=0.5;
  zVel=0.01;
  xVel=random(5)-2.5;
  yVel=random(5)-2.5;
}

void restart() {
  score=0;
  tomatophase=1;
  dead=false;
  setupScreen();
}

void loadimages(int i){
  tomato=loadImage("art/tomato"+i+".png");
  tomatox=loadImage("art/tomato"+i+"x.png");
  if(i>20){
   tomato=loadImage("art/c.png");
   tomatox=loadImage("art/c.png");
  }
}

void camstuff() {
  if (cam.available()) cam.read();
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
  objects = new int[h][l];
  
  label.clear();
  label.add(0);
  unique.clear();

  loadPixels();
  markBlobs();

  markSeparate();
  findUnique();

  fillBiggest();

  float[]coor=COG(xLoc,yLoc);
  handX=coor[0];
  handY=coor[1];
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
  paddleSizes.add(new Float(sizes[biggest]));
  if(paddleSizes.size()>10)paddleSizes.remove(0);
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
  float g = green(c);
  float b = blue(c);
  float r = red(c);
  return (brightness(c)>100 && (g/b < maxGB) && (g/b > minGB) && (g/r > minGR) && (g/r < maxGR) && (b/r > minBR) && (b/r < maxBR) );
}

void markSeparate() {
  int cnt = 1;
  
  for (int y = 0; y<h; y++) {
    for (int x = 0; x<l; x++) {
      int cur = y*l+x;
      int a = 0;
      int b = 0;
      int c = 0;
      int d = 0;
      
      if ( objects[y][x] == 255) {
        if ( inBounds(y-1, x-1) ) a = objects[y-1][x-1];
        if ( inBounds(y-1, x) ) b= objects[y-1][x];
        if ( inBounds(y-1, x+1) ) c = objects[y-1][x+1];
        if ( inBounds(y, x-1) ) d = objects[y][x-1];
        
        if ( a==0 && b==0 && c==0 && d==0 ) {
          objects[y][x] = cnt;
          label.add(cnt);
          cnt++;
        } else {
          int min = findMin(a, b, c, d);
          objects[y][x] = min;
          
          if (a!=0) label.set( a, min );
          if (b!=0) label.set( b, min );
          if (c!=0) label.set( c, min ); 
          if (d!=0) label.set( d, min ); 
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
}

int findMin( int a, int b, int c, int d ) {
  ArrayList<Integer> cont = new ArrayList<Integer>();
  if (a!=0) cont.add(a);
  if (b!=0) cont.add(b);
  if (c!=0) cont.add(c);
  if (d!=0) cont.add(d);

  int ret = cont.get(0);
  for (int i = 1; i < cont.size (); i++) {
    if (cont.get(i) < ret) ret = cont.get(i);
  }
  return ret;
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
  oleCOG[frCo] = ans; 
  frCo++;
  return ans;
}

void blur() {
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
