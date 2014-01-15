package net.rauix.mac2imgur;

import java.io.File;

import org.apache.commons.io.monitor.FileAlterationListener;
import org.apache.commons.io.monitor.FileAlterationListenerAdaptor;
import org.apache.commons.io.monitor.FileAlterationMonitor;
import org.apache.commons.io.monitor.FileAlterationObserver;

public class Main {

	public static final String dir = System.getProperty("user.home") + File.separator + "Desktop";

	public static void main(String[] args) throws Exception {
		
		Utils.setupLogger();

		Updater.checkUpdates();

		Utils.setupDylib();

		Tray.addSystemTray();

		// Check the desktop for screenshots every X amount of seconds
		final long interval = PreferencesHandler.prefs.getInt("interval", 1) * 1000;

		File folder = new File(dir);


		if (!folder.exists()){
			// It should exist, as it's a system folder
			Utils.fatalError("Desktop folder does not exist (" + dir + ")");
		}

		// Not using NIO, as the default Java on Macs is Java 6
		FileAlterationObserver observer = new FileAlterationObserver(folder);
		FileAlterationMonitor monitor = new FileAlterationMonitor(interval);
		FileAlterationListener listener = new FileAlterationListenerAdaptor(){
			@Override
			public void onFileCreate(File f){
				// Make sure the file is a screenshot, don't want to upload anything else!
				if ((f.getName().contains(".png"))
						&& (f.getName().contains("Screen Shot"))
						// Extra check to prevent double uploads when the file is moved
						&& (new File(dir + File.separator + f.getName()).exists())){
					Utils.logger.info("Screen shot found! Proceeding to upload!");
					ImgurUploader.upload(f);
				}
			}
		};

		observer.addListener(listener);
		monitor.addObserver(observer);
		monitor.start();
	}

}
