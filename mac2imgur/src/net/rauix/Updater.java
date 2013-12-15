package net.rauix;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;

import javax.swing.JFrame;
import javax.swing.JOptionPane;

public class Updater {

	final static double version = 1.2;

	public static void checkUpdates(){
		try {
			URL url = new URL("https://github.com/rauix/mac2imgur/raw/master/version.txt");
			BufferedReader in = new BufferedReader(new InputStreamReader(url.openStream()));
			String parse;
			while ((parse = in.readLine()) != null){
				// Don't bug people using future versions!
				if (Double.parseDouble(parse.replace("v", "")) > version){
					Object[] options = {"Sure!", "Not right now"};
					int updatedialog = JOptionPane.showOptionDialog(
							new JFrame(),
							"There is an update available for mac2imgur.\n\nWould you like to update?",
							"mac2imgur update available!",
							JOptionPane.YES_NO_OPTION,
							JOptionPane.QUESTION_MESSAGE,
							null,
							options,
							options[0]);
					if (updatedialog == JOptionPane.YES_OPTION){
						Utils.openBrowser("https://github.com/rauix/mac2imgur/releases");
					} 
				}
			}
			in.close();
		} catch (MalformedURLException e){
			e.printStackTrace();
		} catch (IOException e){
			e.printStackTrace();
		}
	}
}