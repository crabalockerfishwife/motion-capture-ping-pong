public class SimpleThreads {
    
    //displau a message, preceded by
    //hte name of the current thread
    static void threadMessage (String message) {
	String threadName =
	    Thread.currentThread().getName();
	System.out.format("%s: %s%n", threadName, message);
    }

    private static class MessageLoop implements Runnable {
	public void run() {
	    String importantInfo[] = {
		"Mares eat oats",
		"Does eat oats",
		"Eh im not a big fan of oats",
		"Perhaps you like oats, your weird"};
	    try {
		for (int i = 0; i < importantInfo.length; i++ ) {
		    Thread.sleep(4321);
		    threadMessage(importantInfo[i]);
		}
	    }
	    catch (InterruptedException e) {
		threadMessage("I wasnt done!");
	    }
	}
    }

    public static void main (String args[]) throws InterruptedException {
	
	//Delay in milliseconds before
	//MessageLoop is interruped
	//Default == one hour
	long patience = 1000 * 60 * 60;

	
	//if command line other wise specifies
	//change patience to that
	if (args.length > 0) {
	    try {
		patience = Long.parseLong(args[0]) * 1000;
	    }
	    catch (NumberFormatException e) {
		System.err.println("Argument must be an integer.");
		System.exit(1);
	    }
	}

	threadMessage("Starting MessageLoop thread");
	long startTime = System.currentTimeMillis();
	Thread t = new Thread(new MessageLoop());
	t.start();

	threadMessage("Waiting for messageLoop thread to finish");
	//loop until mL  exits
	while (t.isAlive()) {
	    threadMessage("still waiting...");
	    //waits max of 1 second
	    t.join(1000);
	    if (((System.currentTimeMillis() - startTime) > patience) && t.isAlive()) {
		threadMessage("Tired of waiting");
		t.interrupt();
		//shouldnt be long now
		// -- wait indefinitely
		t.join();
	    }
	}
	threadMessage("Finally!");
    }
}
