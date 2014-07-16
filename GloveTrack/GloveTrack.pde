import processing.video.*;

Capture cam;
int[][] objects;
int l, h;
ArrayList<Integer> label;
ArrayList<Integer> unique;
int[][] edges;
ArrayList<Float> xLoc = new ArrayList<Float>();
ArrayList<Float> yLoc = new ArrayList<Float>();
float[] COG = new float[2];
float[][] oleCOG = new float[4][2];
int frCo = 0;

//int[][] matrix = {{1,2,1},{2,4,2},{1,2,1}};
int[][] matrix = {{1,1,1},{1,0,1},{1,1,1}};
void setup() {
  l = 640;
  h = 480;
  size(l, h);

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 480);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    cam = new Capture(this, cameras[0]);

    cam.start();
  }
}

void draw() {

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
  for (int c = 1; c < cam.width-1; c++) { // For each pixel in the cam frame...
    for (int r = 1; r < cam.height-1; r++) {
      int loc = c + r*width;
      /*color[][] cols = new color[matrix.length][matrix[0].length];
      for (int x = c-1; x <= c+1; x++) {
        for(int y = r-1; y <= r+1; y++) {
          int pla = x + y*width;
          /*if (((y + 1) - r) == -1) {
            println(y);
            println(r);
          }
          else { println("shit");}
          cols[(x + 1) - c][(y + 1) - r] = color(pixels[pla]);
        }
      }*/
      color neCo = convolve(matrix, c - 1, r - 1);
      pixels[loc] = neCo;
    }
  }
  updatePixels();
  //image(cam, 0, 0);
  objects = new int[h][l];
  label = new ArrayList<Integer>();
  label.add(0);
  unique = new ArrayList<Integer>();

  loadPixels();
  markBlobs();

  //updatePixels();
  
  markSeparate();
  findUnique();

  fillBiggest();
  findEdges();
  //updatePixels();
  //pause();
  fill(0, 255, 255);

  ellipse(COG(xLoc, yLoc)[0], COG(xLoc, yLoc)[1], 50, 50);
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
  if ((green/blue < (0.6307366 + 0.2)) && (green/blue > (0.6307366 - 0.2)) && (green/red > 1.5) && (blue/red > 2)) {
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
   println( edges[i][0] + " , " + edges[i][1] );
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
          if (b!=0) {
            label.set( b, min );
          }
          if (b!=0) {
            label.set( b, min );
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

float[] COG (ArrayList<Float> x, ArrayList<Float> y) {
  float[] ans = new float[2];
  newCOG(x,y);
  for (int h = 0; h < oleCOG.length; h++) {
    ans[0] += oleCOG[h][0];
    ans[1] += oleCOG[h][1];
  }
  ans[0] = ans[0]/oleCOG.length;
  ans[1] = ans[1]/oleCOG.length;
  return ans;
}

/*
//matrix and pixs are the same dimensions
color convolve (int[][] matrix, color[][] pixs) {
  float red =0;
  float green =0;
  float blue =0;
  int sum =0;
  for(int c = 0; c < matrix.length; c++) {
    for (int h = 0; h < matrix[c].length; h++) {
      red += (red(pixs[c][h]) * matrix[c][h]);
      green += (green(pixs[c][h]) * matrix[c][h]);
      blue += (blue(pixs[c][h]) * matrix[c][h]);
      sum += matrix[c][h];
    }
  }
  red /= sum;
  green /= sum;
  blue /= sum;
  return color(red,green,blue);
} */

color convolve (int[][] matrix, int x, int y) {
  float red =0;
  float green =0;
  float blue =0;
  int sum =0;
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
  

