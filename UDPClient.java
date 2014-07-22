import java.io.*;
import java.net.*;

class UDPClient
{
    DatagramSocket clientSocket;
    byte[] sendData;
    byte[] receiveData;

    
    /*public static void main(String args[]) throws Exception
    {
	DatagramSocket clientSocket = new DatagramSocket();
	byte[] sendData = new byte[1024];
	byte[] receiveData = new byte[1024];
	while (true) {
	    BufferedReader inFromUser =
		new BufferedReader(new InputStreamReader(System.in));
	    InetAddress IPAddress = InetAddress.getByName("localhost");
	    String sentence = inFromUser.readLine();
	    sendData = sentence.getBytes();
	    DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, IPAddress, 9876);
	    clientSocket.send(sendPacket);
	    DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
	    clientSocket.receive(receivePacket);
	    String modifiedSentence = new String(receivePacket.getData());
	    System.out.println("FROM SERVER:" + modifiedSentence);
	    //clientSocket.close();
	}
	}*/

    public void setup() throws Exception {
	clientSocket = new DatagramSocket();
	sendData = new byte[1024];
	receiveData = new byte[1024];
    }

    public String recPak() throws Exception {
	BufferedReader inFromUser =
	    new BufferedReader(new InputStreamReader(System.in));
	InetAddress IPAddress = InetAddress.getByName("localhost");
	String sentence = inFromUser.readLine();
	sendData = sentence.getBytes();
	DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, IPAddress, 9876);
	clientSocket.send(sendPacket);
	DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
	clientSocket.receive(receivePacket);
	String modifiedSentence = new String(receivePacket.getData());
	System.out.println("FROM SERVER:" + modifiedSentence);
	return(modifiedSentence);
	//clientSocket.close();
    }
}
