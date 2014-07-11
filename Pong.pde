PImage background;
float score;
float ballX,ballY,ballZ;
float xVel,yVel,zVel;

void setup(){
  size(800,600); 
  score=0; 
  background=loadImage("Background.png");
  ballZ=0.01;
  zVel=0.0015;
  xVel=random(5)-2.5;
  yVel=random(5)-2.5;
}

void draw(){
  translate(width/2,height/2);
  imageMode(CENTER);
  tint(255,45);
  image(background,0,0,width,height);
  textSize(15);
  fill(0);
  text("Score: "+score,-380,-280);
  fill(255*ballZ);
  ellipse(ballX*ballZ,ballY*ballZ,50*ballZ,50*ballZ);
  fill(150,50,25,100);
  rectMode(CENTER);
  rect(mouseX-width/2,mouseY-height/2,50,50);
  if(mousePressed){
    fill(255,255,0,100);
    rectMode(CENTER);
    rect(mouseX-width/2,mouseY-height/2,50,50);
  }
  ballX+=xVel;
  ballY+=yVel;
 ballZ+=zVel;
  if(ballZ<=0.001){
    zVel=abs(zVel);
  }
  if(ballZ>=1.1){
    background(0);
    fill(128,0,0);
    textSize(50);
    text("GAME OVER\nScore: "+score,0,0);
  }
  if(ballX<=width/-2){
    xVel=abs(xVel);
  }
  if(ballX>=width/2){
    xVel=abs(xVel)*-1;
  }
  if(ballY<=height/-2){
    yVel=abs(yVel);
  }
  if(ballY>=height/2){
   yVel=abs(yVel)*-1; 
  }
  println(ballZ+","+zVel);
}

void mouseClicked(){
  if(ballZ>0.8 && ballZ<1.1){
    if(mouseX-width/2>ballX-25 && mouseX-width/2<ballX+25 && mouseY-height/2>ballY-25 && mouseY-height/2<ballY+25){
      println("hit");
      zVel=(0.7-ballZ)/100;
      xVel+=(ballX-(mouseX-width/2))/10;
      yVel+=(ballY-(mouseY-height/2))/10;
      score++;
    }
  }else{
      score-=0.05;
    }
}
