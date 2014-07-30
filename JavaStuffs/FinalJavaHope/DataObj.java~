public class DataObj {

    private volatile float velX, velY, velZ;

    private volatile boolean hitOcc = false;


    public boolean isChange() {
	return hitOcc;
    }
    public synchronized void hit () {
	hitOcc = true;
	notifyAll();
    }
    public synchronized void movOff () {
	hitOcc = false;
	notifyAll();
    }

    public float getX () {
	return velX;
    }
    public void setX (float newX) {
	velX = newX;
    }



    public float getY () {
	return velY;
    }
    public void setY (float newY) {
	velY = newY;
    }



    public float getZ () {
	return velZ;
    }
    public void setZ (float newZ) {
	velZ = newZ;
    }

}
