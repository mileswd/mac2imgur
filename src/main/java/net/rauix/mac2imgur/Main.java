package net.rauix.mac2imgur;

import net.rauix.teensy.Detail;
import net.rauix.teensy.Logger;
import org.apache.commons.io.monitor.FileAlterationListener;
import org.apache.commons.io.monitor.FileAlterationListenerAdaptor;
import org.apache.commons.io.monitor.FileAlterationMonitor;
import org.apache.commons.io.monitor.FileAlterationObserver;

import javax.swing.*;
import java.io.File;
import java.util.prefs.Preferences;

public class Main {

    static Preferences prefs = Preferences.userRoot().node("net.rauix.mac2imgur");

    static Logger logger;

    // Constants
    static final double VERSION = 2.0;

    static final String DIR = prefs.get("MONITOR-DIR", System.getProperty("user.home") + "/Desktop/");

    public static void main(String[] args) {

        logger = new Logger(prefs.getBoolean("DEBUG", false) ? Detail.DEBUG : Detail.SEVERE, new File(Utils.getDataDirectory() + "mac2imgur.log"));

        logger.debug("Launching mac2imgur v" + VERSION);
        logger.debug("Monitoring DIRectory: " + DIR);

        // Check for updates
        Utils.checkUpdates();

        // Add system tray icon
        Tray.addSystemTray();

        // Set up notification bridge
        Notifier.setupDylib();

        File monitorDir = new File(DIR);

        if (!monitorDir.exists()) {
            // It should exist, as it's a system folder
            Utils.displayPopup("The Desktop folder (" + DIR + ") does not exist.\n\nmac2imgur will now close.", JOptionPane.ERROR_MESSAGE);
            System.exit(0);
        }

        // Not using NIO, as the default Java on Macs is Java 6
        FileAlterationObserver observer = new FileAlterationObserver(monitorDir);
        FileAlterationMonitor monitor = new FileAlterationMonitor(1000);
        FileAlterationListener listener = new FileAlterationListenerAdaptor() {
            @Override
            public void onFileCreate(File f) {
                // Make sure the file is a screenshot, don't want to upload anything else!
                // Also check that the file exists, to prevent double uploads when the file is tidied
                if (f.getName().startsWith("Screen Shot") && f.getName().endsWith(".png") && new File(DIR + f.getName()).exists()) {
                    logger.debug("Found " + f.getName() + ", uploading!");
                    ImgurUploader.upload(f);
                }
            }
        };

        observer.addListener(listener);
        monitor.addObserver(observer);
        try {
            monitor.start();
        } catch (Exception e) {
            Utils.displayPopup("The folder monitor could not start.\n\nmac2imgur will now close.", JOptionPane.ERROR_MESSAGE);
            System.exit(0);
            logger.severe(e);
        }
    }

}
