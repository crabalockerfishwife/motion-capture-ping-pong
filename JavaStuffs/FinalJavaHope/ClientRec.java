import java.io.*;
import java.net.*;
import java.util.*;


public class ClientRec extends Thread{

    float[] nums = new float[3];
    DataObj source;

    public ClientRec (DataObj data) {
       super();
       source = data;
       nums[0] = data.getX();
       nums[1] = data.getY();
       nums[2] = data.getZ();
    }

    public float[] assignNums (float[] newNums) {
         float [] old = nums;
         nums = newNums;
         return old;
    }

    public void updNums () {
        nums[0] = source.getX();
        nums[1] = source.getY();
        nums[2] = source.getZ();
    }


    public float[] getNums () {
       return nums;
    }

    public static void main (String[] args) throws IOException{

      /*if (args.length != 1) {
        System.out.println("Usage: java QuoteClient <hostname>");
        return;
        }*/

      //ClientSend thisOne = new ClientSend();
      //thisOne.work();

    }

    public DatagramSocket ping() {
	try {
	    byte[] test = new byte[256];
	    DatagramSocket socket = new DatagramSocket();
	    InetAddress address = InetAddress.getByName("localhost");
	    DatagramPacket pinger = new DatagramPacket(test, test.length, address, 7742);
	    socket.send(pinger);
	    System.out.println("Server Pinged");
	    return socket;
	} catch (Exception e) {
	    System.out.println("Failed to ping server to establish client addresses");
	    return null;
	}
    }

    public void run(){
	DatagramSocket socket = ping();
           while (true) {
             try {

		 //DatagramSocket socket = new DatagramSocket();

              //sending data
		 byte[] buf = new byte[256];
              //byte[] send = new byte[256];
              String vals = "";
              //updNums();
              for (int c = 0; c < nums.length; c++) {
                  if (c == nums.length - 1) {
                      vals += nums[c];
                  }
                  else {
                      vals += nums[c] + ", ";
                  }
              }
              System.out.println("ORIG VALS: " + vals);
              //send = vals.getBytes();

              InetAddress address = InetAddress.getByName("localhost");
              /*DatagramPacket packet = new DatagramPacket(send, send.length, address, 7891);
              socket.send(packet);
              System.out.println("New Data Sent");*/

              //recieve data
              DatagramPacket packet = new DatagramPacket(buf, buf.length);
              socket.receive(packet);

              //display response
              String received = new String(packet.getData());
              float[] imp = getVals(received);
              System.out.println("New Coordinate Values from Server: " + received);
              source.setX(imp[0]);
              source.setY(imp[1]);
              source.setZ(imp[2]);
              updNums();

              //socket.close();
            } catch (IOException e) {
                System.out.println("Ben you done messed up, make this work...");
            }
          }
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
