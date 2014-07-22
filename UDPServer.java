import java.io.*;
import java.net.*;

class UDPServer
{
    int clieOne = -1;
    int clieTwo = -1;
    
    InetAddress IPOne;
    InetAddress IpTwo;

    float ballXO, ballYO, ballZO;
    float xVelO, yVelO, zVelO;

    float baXT, baYT, baZT;
    float xVeT, yVeT, zVeT;

    public static void main(String args[]) throws Exception
    {
	//DatagramSocket serverSocket = new DatagramSocket(9876);
	//byte[] receiveData = new byte[1024];
	//byte[] sendData = new byte[1024];  
	while(true)
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
		setup(res, capitalizedSentence);
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
	float[] out = new float[6];
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

    public void action (String clOnIn) {
	float[] inpOne = getVals(clOnIn);
	float[] twoInp = swap(inpOne);
	ballXO = inpOne[0];
	ballYO = inpOne[1];
	ballZO = inpOne[2];
	xVelO = inpOne[3];
	yVelO = inpOne[4];
	zVelO = inpOne[5];
	baXT = twoInp[0];
	baYT = twoInp[1];
	baZT = twoInp[2];
	xVeT = twoInp[3];
	yVeT = twoInp[4];
	zVeT = twoInp[5];
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
	else {
	    return 0;
	}
    }

    public void setup (int aCR, String datPak) {
	if (aCR == 1) {
	    IPOne = receivePacket.getAddress();
	    action(datPak);
	}
	else if (aCR == 2) {
	    IPTwo = receivePacket.getAddress();
	    action(datPak);
	}
    }
	    
    
}
