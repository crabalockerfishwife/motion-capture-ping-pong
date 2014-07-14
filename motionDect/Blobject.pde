public class Blobject {
 
 int labelNum;
 float[][] pixs = new float[500][2];
 int fin;
 float eps = 0.00001;

 Blobject (int label) {
    labelNum = label;
    fin = 0;
 }
 
 Blobject() {
  labelNum = 0;
  fin = 0;
 }
 
 float[][] getPixs() {
   return pixs;
 }
 
 int getLabel() {
   return labelNum;
 }
 
 int size() {
   return fin;
 }
 
 void add(float x, float y) {
   resize();
   pixs[fin][0] = x;
   pixs[fin][1] = y;
   fin++;
 }
 
 int find (float x, float y, int label) {
   for (int c = 0; c < fin; c++) {
     if ((Math.abs(pixs[c][0] - x) < eps) &&
        (Math.abs(pixs[c][1] - y) < eps) &&
        (label == labelNum)) {
       return c;
        }
   }
   return -1;
 }
 
 float[] remove (int ind) {
   float[] remd = new float[2];
   pixs[ind][0] = remd[0];
   pixs[ind][1] = remd[1];
   for (int c = ind; c < fin; c++) {
     pixs[c][0] = pixs[c+1][0];
     pixs[c][1] = pixs[c+1][1];
   }
   fin--;
   return remd;
 }
   
   
 
 //false means they are different blobs, true is the same blob
 boolean comBlo (Blobject fresh, float thresh) {
   int samePixs = pixs.length;
   if (fresh.getLabel() == labelNum) {
     for(int c = 0; c < pixs.length; c++) {
       if( c > fresh.getPixs().length) {
         samePixs--;
       }
       if (!(pixs[c][0] == fresh.getPixs()[c][0] &&
           pixs[c][1] == fresh.getPixs()[c][1])) {
             samePixs--;
           }
     }
     float perSame = samePixs/pixs.length;
     if (perSame < thresh) {
       return false;
     }
     else {
       return true;
     }
   }
   else {
     return false;
   }
 }
 
 
 void resize() {
    if (fin >= pixs.length) {
        float[][] newPix = new float[pixs.length * 2][pixs[0].length];
        copTwoD(pixs,newPix);
        pixs = newPix;
    }
    else if (pixs.length >= 50) {
        if (fin <= (pixs.length * 0.25)) {
          float[][] newPix = new float[pixs.length/2][pixs[0].length];
          copTwoD(newPix,pixs);
          pixs = newPix;
        }
    }
  }
  
  void copTwoD ( float[][] fromSmal, float[][] toBig ) {
    for (int r = 0; r < fromSmal.length; r++) {
      for (int c = 0; c < fromSmal[r].length; c++) {
         toBig[r][c] = fromSmal[r][c];
      }
    }
  }
 
}
