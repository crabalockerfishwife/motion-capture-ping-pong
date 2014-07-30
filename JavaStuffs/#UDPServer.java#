import java.io.*;
import java.net.*;
import java.util.*;

class UDPServer
{
    int clieOne = -1;
    int clieTwo = -1;
    
    InetAddress IPOne;
    InetAddress IPTwo;

    float ballXO, ballYO, ballZO;
    float xVelO, yVelO, zVelO;

    float baXT, baYT, baZT;
    float xVeT, yVeT, zVeT;

    public static void main(String args[]) throws Exception
    {
	//DatagramSocket serverSocket = new DatagramSocket(9876);
	//byte[] receiveData = new byte[1024];
	//byte[] sendData = new byte[1024];  
	/*while(true)
	    {
		DatagramSocket serverSocket = new DatagramSocket(9876);
		byte[] receiveData = new byte[1024];
		byte[] sendData = new byte[1024];
		DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
		serverSocket.receive(receivePacket);
		int port = receivePacket.getPort();
		int res = assignClient(port);
		String sentence = new String( receivePacket.getData());
		System.out.println("RECEIVED: " + sentence);
		InetAddress IPAddress = receivePacket.getAddress();
		String capitalizedSentence = sentence.toUpperCase();
		capitalizedSentence += port;
		System.out.println(capitalizedSentence);
		if (res == 1) {
		    IPOne = receivePacket.getAddress();
		    action(capitalizedSentence);
		}
		else if (res == 2) {
		    IPTwo = receivePacket.getAddress();
		    action(capitalizedSentence);
		}
                sendData = capitalizedSentence.getBytes();
                DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, IPAddress, port);
		System.out.println("Data sent");
                serverSocket.send(sendPacket);
		serverSocket.close();
		}*/
	UDPServer server = new UDPServer();
	server.work();
	
      }

    public void work() throws Exception {
	while(true)
	    {
		DatagramSocket serverSocket = new DatagramSocket(9876);
		byte[] receiveData = new byte[1024];
		byte[] sendData = new byte[1024];
		//byte[] senDatO = new byte[1024];
		//byte[] senDatT = new byte[1024];
		DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
		serverSocket.receive(receivePacket);
		int port = receivePacket.getPort();
		int res = assignClient(port);
		String sentence = new String( receivePacket.getData());
		System.out.println("RECEIVED: " + sentence);
		InetAddress IPAddress = receivePacket.getAddress();
		String capitalizedSentence = sentence.toUpperCase();
		System.out.println(capitalizedSentence);
		if (res == 1) {
		    IPOne = receivePacket.getAddress();
		    //action(capitalizedSentence);
		}
		else if (res == 2) {
		    IPTwo = receivePacket.getAddress();
		    String outTwo = /*Arrays.toString(swap(getVals(*/capitalizedSentence + "Send One"/*)))*/;
		    sendData = capitalizedSentence.getBytes();
		    System.out.println(capitalizedSentence);
		    System.out.println(clieOne);
		    DatagramPacket senPac = new DatagramPacket(sendData, sendData.length, IPOne, clieOne);
		    serverSocket.send(senPac);
		    System.out.println("Client One Sent");
		    //serverSocket.close();
		    //serverSocket = new DatagramSocket(9876);
		    sendData = outTwo.getBytes();
		    System.out.println(outTwo);
		    System.out.println(clieTwo);
		    DatagramPacket sedPak = new DatagramPacket(sendData, sendData.length, IPTwo, clieTwo);
		    serverSocket.send(sedPak);
		    System.out.println("Client Two Sent");
		    //serverSocket.close();
		    //serverSocket = new DatagramSocket(9876);
		}
		capitalizedSentence += port;
		System.out.println(capitalizedSentence);
		System.out.println(port);
                sendData = capitalizedSentence.getBytes();
                DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, IPAddress, port);
		System.out.println("Data sent");
                serverSocket.send(sendPacket);
		serverSocket.close();
	    }
    }
	


    private float[] swap (float[] vals) {
	float[] ans = new float[vals.length];
	for(int c = 0; c < vals.length; c++) {
	    if (c == 2) {
		ans[c] = 1 - vals[c];
	    }
	    else {
		ans[c] = -1 * vals[c];
	    }
	}
	return ans;
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
	else if (port == clieTwo || port == clieOne) {
	    return 2;
	}
	else {
	    return 0;
	}
    }

	    
    
}
