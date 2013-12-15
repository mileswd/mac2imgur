package net.rauix;

import java.awt.Desktop;
import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.StringSelection;
import java.io.File;
import java.io.IOException;
import java.net.URL;

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
		}
	}

	public static void displayError(String msg){
		JOptionPane.showMessageDialog(null,
				"An error occured:\n\n" + msg,
				"mac2imgur",
				JOptionPane.ERROR_MESSAGE);
	}

}