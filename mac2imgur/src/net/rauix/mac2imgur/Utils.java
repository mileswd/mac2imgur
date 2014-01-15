package net.rauix.mac2imgur;

import java.awt.Desktop;
import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.StringSelection;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.logging.FileHandler;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.swing.JOptionPane;

import org.apache.commons.io.FileUtils;

public class Utils {

	public static void copyToClipboard(String s){
		StringSelection selection = new StringSelection(s);
		Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
		clipboard.setContents(selection, selection);
	}

	public static void openBrowser(String url){
		try {
			Desktop.getDesktop().browse(new URL(url).toURI());
		} catch (Exception e){
			e.printStackTrace();
		}
	}

	public static void setupDylib(){
		try {
			FileUtils.copyInputStreamToFile(Utils.class.getClassLoader().getResourceAsStream("res/NotificationsBridge.dylib"), new File(FileUtils.getTempDirectoryPath() + File.separator + "NotificationsBridge.dylib"));
		} catch (IOException e){
			displayError("Failed to set up notification center bridge");
			Utils.logger.info("Failed to set up notification center bridge");
		}
	}

	public static void displayError(String msg){
		JOptionPane.showMessageDialog(null,
				"An error occured:\n\n" + msg,
				"mac2imgur",
				JOptionPane.ERROR_MESSAGE);
		logger.warning(msg);
	}

	public static void fatalError(String msg){
		JOptionPane.showMessageDialog(null,
				"An fatal error occured:\n\n" + msg + "\n\nmac2imgur will now close",
				"mac2imgur",
				JOptionPane.ERROR_MESSAGE);
		logger.severe(msg);
		System.exit(1);
	}

	public static String getDefaultDirectory() {
		String dir = System.getProperty("user.home") 
				+ "/Library/Application "
				+ "Support" 
				+ File.separator 
				+ "mac2imgur"
				+ File.separator;
		if (!new File(dir).exists()) {
			new File(dir).mkdirs();
		}
		return dir;
	}

	public static Logger logger = Logger.getLogger("mac2imgur");

	public static void setupLogger(){
		logger.setLevel(Level.FINE);
		try {
			String logfile = getDefaultDirectory() + "mac2imgur.log";
			Handler handler = new FileHandler(logfile);
			logger.addHandler(handler);
		} catch (SecurityException e1){
			Logger.getLogger("mac2imgur").log(Level.SEVERE, "Well, that escalated quickly", e1);
		} catch (IOException e2){
			Logger.getLogger("mac2imgur").log(Level.SEVERE, "Well, that escalated quickly", e2);
		}
		Logger.getLogger("mac2imgur").info("Starting mac2imgur - v" + Updater.version);
		Logger.getLogger("mac2imgur").info("Java version: " + System.getProperty("java.version"));
		Logger.getLogger("mac2imgur").info("Java vendor: " + System.getProperty("java.vendor"));
		Logger.getLogger("mac2imgur").info("Java home: " + System.getProperty("java.home"));
		Logger.getLogger("mac2imgur").info("Java specification: " + System.getProperty("java.vm.specification.name"));
		Logger.getLogger("mac2imgur").info("JVM: " + System.getProperty("java.vm.name"));
		Logger.getLogger("mac2imgur").info("OS: " + System.getProperty("os.arch") + " " + System.getProperty("os.name") + " " + System.getProperty("os.version"));
	}

}