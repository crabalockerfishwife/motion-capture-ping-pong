import processing.video.*;

Capture cam;
int[][] objects;
int l,h;
ArrayList<Integer> label;
ArrayList<Integer> unique;
int[][] edges;
ArrayList<Float> xLoc = new ArrayList<Float>();
ArrayList<Float> yLoc = new ArrayList<Float>();

void setup() {
  l = 640;
  h = 480;
  size(l, h);

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 480);
  } if (cameras.length == 0) {
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
  image(cam, 0, 0);
  objects = new int[h][l];
  label = new ArrayList<Integer>();
  label.add(0);
  unique = new ArrayList<Integer>();
  
  loadPixels();
  markBlobs();
  updatePixels();
  
  markSeparate();
  findUnique();
  
  fillBiggest();
  findEdges();
  updatePixels();
<<<<<<< HEAD
  //pause();
  println(COG(xLoc, yLoc)[0] + ", " + COG(xLoc, yLoc)[1]);
=======
>>>>>>> 6e84a9c8ad111fe57616c8496b839d10fc56c40f
}

void fillBiggest() {

  int[] sizes = new int[ unique.get( unique.size() -1) + 1];
  for (int y = 0; y<h; y++) {
    for (int x = 0; x<l; x++) {
      int cur = y*l+x;
      if (objects[y][x] != 0) {
        int i = objects[y][x];
        while( ((int)label.get(i)) != i ) {
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
  for (int y = 0; y<h; y++) {
    for (int x = 0; x<l; x++) { 
      int cur = y*l+x;
      if (objects[y][x] != 0) {
        int i = objects[y][x];
        while( ((int)label.get(i)) != i ) {
          i = label.get(i);
        } 
        if (i == biggest) {
          pixels[cur] = color(255);
          xLoc.add((float)x);
          yLoc.add((float)y);
        }
        else {
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
      }
      else {
        pixels[ y * l + x ] = color(0);
        objects[y][x] = 0;
      }
        
    }
  }
}

boolean isHand(color c) {
  float green = green(c);
  float blue = blue(c);
  if ((green/blue < (0.6307366 + 0.15)) && (green/blue > (0.6307366 - 0.15))) {
    return true;
  }
  else {
    return false;
  }
}

void findEdges() {
  edges = new int[4][2];
  // find top
  A:for (int y = 0; y<h; y++) {
    B: for (int x = 0; x < l; x++) {
        if (pixels[ y*l + x] != color(0) ) {
          edges[0][0] = y;
          edges[0][1] = x;
          break A;
        }
    }
  }
  
  // find bottom
  C: for (int y = h-1; y > -1; y--) {
     D: for (int x = 0; x < l; x++) {
        if (pixels[ y*l + x] != color(0) ) {
          edges[1][0] = y;
          edges[1][1] = x;
          break C;
        }
      }
  }
  
    // find left
  E: for (int x = 0; x < l; x++) {
     F: for (int y = 0; y < h; y++)  {
        if (pixels[ y*l + x] != color(0) ) {
          edges[2][0] = y;
          edges[2][1] = x;
          break E;
        }
      }
  }
  
  // right
  G: for (int x = (l-1); x > -1; x--) {
     H: for (int y = 0; y < h; y++)  {
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
  stroke(255,0,0);
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
        }
        else {
          int min = findMin(a,b,c,d);
          objects[y][x] = min;
          if (a!=0){
            label.set( a, min ); 
          }
          if (b!=0){
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
  for (int i =0; i<label.size(); i++) {
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
  for (int i = 1; i < cont.size(); i++) {
    if (cont.get(i) < ret) {
      ret = cont.get(i);
    }
  }
  
  return ret;
}

void pause (int s) {
  int mili = millis();
  while (millis() < mili + 1000 * s) {
  }
}

float[] COG (ArrayList<Float> x, ArrayList<Float> y) {
  float[] ans = new float[2];
  for (int h = 0; h < x.size(); h++) {
    ans[0] += x.get(h);
  }
  for (int c = 0; c < y.size(); c++) {
    ans[1] += y.get(c);
  }
  ans[0] = ans[0]/x.size();
  ans[1] = ans[1]/y.size();
  return ans;
}
