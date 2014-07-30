import java.io.*;
import java.net.*;
import java.util.*;


public class QuoteClient{
    
    float[] nums = {(float) 901,(float) 56.65,(float) 465.485,(float) 5.26};
    
    public float[] assignNums (float[] newNums) {
	float [] old = nums;
	nums = newNums;
	return old;
    }
    
    public float[] getNums () {
	return nums;
    }
    
    public static void main (String[] args) throws IOException{
	
	/*if (args.length != 1) {
	  System.out.println("Usage: java QuoteClient <hostname>");
	  return;
	  }*/
	
	QuoteClient thisOne = new QuoteClient();
	thisOne.work();
	
    }

    public void work() throws IOException{
	//make datagramSocket
	DatagramSocket socket = new DatagramSocket();
	
	//sending data 
	byte[] buf = new byte[256];
	byte[] send = new byte[256];
	
	String vals =  Arrays.toString(nums);
	System.out.println("ORIG VALS: " + vals);
	send = vals.getBytes();
	
	InetAddress address = InetAddress.getByName("localhost");
	DatagramPacket packet = new DatagramPacket(send, send.length, address, 7891);
	socket.send(packet);
	
	//recieve data
	packet = new DatagramPacket(buf, buf.length);
	socket.receive(packet);
	
	//display response
	String received = new String(packet.getData());
	System.out.println("New Coordinate Values from Server: " + received);
	
	socket.close();
    }

    private float[] getVals (String inp) {
	float[] out = new float[4];
	int st = 0;
	int ind = 0;
	for (int i = 0; i < inp.length(); i++) {
	    if (inp.substring(i, i + 1).equals(",")) {
		out[ind] = Float.parseFloat(inp.substring(st,i));
		ind++;
		st = i + 1;
	    }
	    else if (i == inp.length() - 1) {
		out[ind] = Float.parseFloat(inp.substring(st,inp.length()));
		ind++;
	    }
	}
	return out;
    }    

}
	
	
