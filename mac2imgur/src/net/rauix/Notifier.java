package net.rauix;

import java.io.File;

import org.apache.commons.io.FileUtils;

import com.sun.jna.Library;
import com.sun.jna.Native;

interface NotificationsBridge extends Library {

	String path = FileUtils.getTempDirectoryPath() + File.separator + "NotificationsBridge.dylib";
	NotificationsBridge instance = (NotificationsBridge)
			Native.loadLibrary(path, Notifier.class);

	public int sendNotification(String title, String subtitle, String text, int timeoffset);
}

public class Notifier {

	public static void uploadWasSuccessful(boolean b){
		Utils.logger.info("Upload successful: " + b);
		if (PreferencesHandler.prefs.getBoolean("tray-notify", false)){
			Tray.setIconResult(b);
		} 

		if (PreferencesHandler.prefs.getBoolean("center-notify", true)){
			if (b){
				NotificationsBridge.instance.sendNotification("mac2imgur", "", "Screenshot uploaded!", 0);
			} else {
				NotificationsBridge.instance.sendNotification("mac2imgur", "", "Screenshot failed to upload!", 0);
			}
		} 
	}

}