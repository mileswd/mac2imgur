package net.rauix;

import java.io.File;

import org.apache.commons.io.monitor.FileAlterationListener;
import org.apache.commons.io.monitor.FileAlterationListenerAdaptor;
import org.apache.commons.io.monitor.FileAlterationMonitor;
import org.apache.commons.io.monitor.FileAlterationObserver;

public class Main {

	public static final String dir = System.getProperty("user.home") + File.separator + "Desktop";

	public static void main(String[] args) throws Exception {

		System.out.println("Launching mac2imgur - v" + Updater.version);

		Updater.checkUpdates();

		Utils.setupDylib();

		Tray.addSystemTray();

		final long interval = PreferencesManager.getPreferences().getInt("interval", 2) * 1000;
		// Check the desktop for screenshots every X amount of seconds

		File folder = new File(dir);


		if (!folder.exists()){
			throw new RuntimeException("Desktop folder does not exist (" + dir + ")");
			// It should exist, as it's a system folder; but always assume the input is wrong
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
					System.out.println("Screen shot found! Proceeding to upload!");
					ImgurUploader.upload(f);
				}
			}
		};

		observer.addListener(listener);
		monitor.addObserver(observer);
		monitor.start();
	}

}
