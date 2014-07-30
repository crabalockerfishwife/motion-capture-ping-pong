import java.io.*;

public class PongClient {
    public static void main(String[] args) throws IOException {
        DataObj test = new DataObj();
        int time = 0;
        test.setX((float) 81);
        test.setY((float) 542);
        test.setZ((float) 21.21);
        new QuoteServerThread("Server").start();
        new ClientRec(test).start();
	while(!test.getPing()) {}
        new ClientSend(test).start();
        while (true) {
            if (time%700 == 0) {
                //System.out.println("Ball velocity has changed");
                //System.out.println(test.isChange());
                test.hit();
		
            }
            else {
              //System.out.println("Ball has unchanging velocity now");
            }
            time++;
        }
    }
}
