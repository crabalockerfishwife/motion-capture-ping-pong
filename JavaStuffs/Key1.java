import java.awt.event.*;
import javax.swing.*;


public class Key1 extends JFrame implements KeyListener{
    
    JTextField KeyCodeT = new JTextField("Key Code:");
    

    public Key1() {
	KeyCodeT.addKeyListener(this);
	KeyCodeT.setEditable(false);
	System.out.println("work?");
	add(KeyCodeT);
	setSize(300,300);
	setVisible(true);
    }

    public void keyPressed(KeyEvent e) {
	System.out.println("Key Pressed!!!");
	/*if (e.getKeyCode() == 27) {
	    JOptionPane.showMessageDialog(null, " Goodbye ");
	    System.exit(0);
	    }*/
    }

    public void keyReleased(KeyEvent e) {
	System.out.println("Key Released!!!");
    }

    public void keyTyped(KeyEvent e) {
    }


    public static void main(String[] args) {
	Key1 key = new Key1();   
    }

}

