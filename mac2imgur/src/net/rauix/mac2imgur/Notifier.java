package net.rauix.mac2imgur;

import java.io.File;

import org.apache.commons.io.FileUtils;

import com.sun.jna.Library;
import com.sun.jna.Native;

interface NotificationCenterBridge extends Library {

	String path = FileUtils.getTempDirectoryPath() + File.separator + "NotificationsBridge.dylib";
	NotificationCenterBridge instance = (NotificationCenterBridge)
			Native.loadLibrary(path, NotificationCenterBridge.class);

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
				NotificationCenterBridge.instance.sendNotification("mac2imgur", "", "Screenshot uploaded!", 0);
			} else {
				NotificationCenterBridge.instance.sendNotification("mac2imgur", "", "Screenshot failed to upload!", 0);
			}
		} 
	}

}