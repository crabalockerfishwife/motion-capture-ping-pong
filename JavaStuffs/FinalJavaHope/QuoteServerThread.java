import java.io.*;
import java.net.*;
import java.util.*;

public class QuoteServerThread extends Thread {


    int clieOne = -1;
    int clieTwo = -1;
    
    int clieRecO;
    int clieRecT;
    
    InetAddress IPOne;
    InetAddress IPTwo;

    protected DatagramSocket socket = null;
    protected BufferedReader in = null;
    protected boolean players = true;

    protected float[] nums = {(float) 42.78, (float)78.42,(float) 28.47,(float) 47.28 };


    public QuoteServerThread(String name) throws IOException {
	       super(name);
	       socket = new DatagramSocket(7742);


	/*try {
	    in = new BufferedReader(new FileReader("one-liners.txt"));
	}
	catch (FileNotFoundException e) {
	    System.err.println("Could not open quote file. Serving Time Instead");
	}*/
    }


    public float[] assignNums (float[] newNums) {
    	float [] old = nums;
    	nums = newNums;
    	return old;
    }

    public float[] getNums () {
    	return nums;
    }

    public void run () {

    	while (players) {
    	    try {
		
    		byte[] buf = new byte [256];

    		//recieving request
    		DatagramPacket packet = new DatagramPacket(buf, buf.length);
    		socket.receive(packet);
		System.out.println("At Server: Packet Received");
		int port = packet.getPort();
		InetAddress address = packet.getAddress();
		int res = assignClient(port);
		if (res == 1) {
		    IPOne = packet.getAddress();
		    System.out.println("First Receiver Registered");
		}
		else if (res == 2) {
		    IPTwo = packet.getAddress();
		    /* String coord = new String(packet.getData());
		    //assignNums(getVals(coord));
		    System.out.println("FROM CLIENT AT PORT " + port + ": " + coord);
		    port = pickPort(address);

		    String response = Arrays.toString(nums);
		    
		    buf = response.getBytes();
		    
		    //send response to client address and port
		    packet = new DatagramPacket(buf, buf.length, address, port);
		    socket.send(packet);*/
		    System.out.println("Second Receiver Registered");
		}
		else if (res == 3) {
		    //IPTwo = receivePacket.getAddress();
		    String coord = new String(packet.getData());
		    //assignNums(getVals(coord));
		    System.out.println("FROM CLIENT AT PORT " + port + ": " + coord);
		    int portDest = pickPort(address);
		    InetAddress dest = pickIP(address);
		    String response = "";
		    for (int c = 0; c < nums.length; c++) {
			if (c == nums.length - 1) {
			    response += nums[c];
			}
			else {
			    response += nums[c] + ", ";
			}
		    }
		    //String response = Arrays.toString(nums);
		    
		    buf = coord.getBytes();
		    
		    //send response to client address and port
		    packet = new DatagramPacket(buf, buf.length, address, port);
		    socket.send(packet);
		    System.out.println("New Data Sent From Server");
		}
    	    } catch (IOException e) {
    		e.printStackTrace();
    		players = false;
    	    }
    	}
    	socket.close();
    }

    
    public int pickPort(InetAddress IP) {
	if (IP.equals(IPOne)) {
	    return clieTwo;
	}
	else if (IP.equals(IPTwo)) {
	    return clieOne;
	}
	else {
	    return clieOne;
	}
    }

       public InetAddress pickIP(InetAddress IP) {
	if (IP.equals(IPOne)) {
	    return IPTwo;
	}
	else if (IP.equals(IPTwo)) {
	    return IPOne;
	}
	else {
	    return IPOne;
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

    public int assignClient (int port) {
	if (clieOne == -1) {
	    clieOne = port;
	    return 1;
	}
	else if (clieTwo == -1) {
	    clieTwo = port;
	    return 2;
	}
	else if (clieTwo != -1 && clieOne != -1) {
	    return 3;
	}
	else {
	    return 0;
	}
    }

}
