/**
 * Bounce. 
 * 
 * When the shape hits the edge of the window, it reverses its direction. 
 */
 
int rad = 60;        // Width of the shape
float xpos, ypos;    // Starting position of shape    

float xspeed = 2.8;  // Speed of the shape
float yspeed = 2.2;  // Speed of the shape

int xdirection = 1;  // Left or Right
int ydirection = 1;  // Top to Bottom

int[][] objects;
int l,h;
ArrayList<Integer> label;
ArrayList<Integer> unique;
color[] blobs;
int[][] edges;


void setup() 
{
  l = 640;
  h = 360;
  size(l, h);
  noStroke();
  frameRate(30);
  ellipseMode(RADIUS);
  // Set the starting position of the shape
  xpos = width/2;
  ypos = height/2;

}

void draw() 
{
  background(0);
  // Update the position of the shape
  xpos = xpos + ( xspeed * xdirection );
  ypos = ypos + ( yspeed * ydirection );
  
  // Test to see if the shape exceeds the boundaries of the screen
  // If it does, reverse its direction by multiplying by -1
  if (xpos > width-rad || xpos < rad) {
    xdirection *= -1;
  }
  if (ypos > height-rad || ypos < rad) {
    ydirection *= -1;
  }

  // Draw the shape
  
  
  ellipse(xpos, ypos, rad, rad);
  
  
  objects = new int[h][l];
  label = new ArrayList<Integer>();
  label.add(0);
  unique = new ArrayList<Integer>();
  
  loadPixels();
  markBlobs();
  
  
  markBlobs();
  updatePixels();
  
  //markSeparate();
  //findUnique();
  //markColors();
  updatePixels();
  findEdges();
  //pause(1);
  //updatePixels();
  
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
          

void markBlobs() {
  for (int y = 0; y < h; y++) {
    for (int x = 0; x <l; x++) {
      if (pixels[ y * l + x] > color(40)) {
        pixels[ y * l + x ] = color(255);
        objects[y][x] = 255;
      }
      else {
        pixels[y*l+x] = color(0);
      }
    }
  }
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

void markColors() {
  int cur;
  for (int y = 0; y<h; y++) {
    for (int x = 0; x<l; x++) {
      cur = y*l+x;
      if (objects[y][x] != 0) {
        int i = objects[y][x];
        while( ((int)label.get(i)) != i ) {
          i = label.get(i);
        } 
        for (int n = 0; n < unique.size(); n++) {
          if ( unique.get(n) == i ) {
            pixels[cur] = blobs[n];
          }
        }
          
      }
      /*
      if ( objects[y][x] == 1 ) {
        pixels[cur] = color(255,0,0);
      }
      if (objects[y][x] == 2) {
        pixels[cur] = color(0,255,0);
      }
      */
    }
  }
}


void findUnique() {
  for (int i =0; i<label.size(); i++) {
    if ( ((int)label.get(i)) == i ) {
      unique.add(i);
    }
  }
  //if (start) {
    blobs = new color[ unique.size() ];
    for (int i = 0; i < blobs.length; i++) {
        blobs[i] = color( random(255), random(255), random(255 ) );
    }
    //start = false;
  //}
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
