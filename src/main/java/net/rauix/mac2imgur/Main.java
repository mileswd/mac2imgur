package net.rauix.mac2imgur;

import com.barbarysoftware.watchservice.*;
import net.rauix.teensy.Detail;
import net.rauix.teensy.Logger;

import javax.swing.*;
import java.io.File;
import java.io.IOException;
import java.util.prefs.Preferences;

import static com.barbarysoftware.watchservice.StandardWatchEventKind.OVERFLOW;

public class Main {

    static Preferences prefs = Preferences.userRoot().node("net.rauix.mac2imgur");

    static Logger logger;

    // Constants
    static final double VERSION = 2.0;

    static final String DIR = prefs.get("MONITOR-DIR", System.getProperty("user.home") + "/Desktop/");

    public static void main(String[] args) {

        logger = new Logger(prefs.getBoolean("DEBUG", false) ? Detail.DEBUG : Detail.SEVERE, new File(Utils.getDataDirectory() + "mac2imgur.log"));

        logger.debug("Launching mac2imgur v" + VERSION);
        logger.debug(System.getProperty("java.version") + " (" + System.getProperty("java.vendor") + ") on " + System.getProperty("os.name")
                + " - " + System.getProperty("os.version") + " (" + System.getProperty("os.arch") + ")");
        logger.debug("Monitoring Directory: " + DIR);

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
            System.exit(1);
        }

        final WatchService watch = WatchService.newWatchService();
        final WatchableFile watchableFile = new WatchableFile(monitorDir);
        try {
            watchableFile.register(watch, StandardWatchEventKind.ENTRY_CREATE);
        } catch (IOException e) {
            logger.severe(e);
            Utils.displayPopup("Could not start folder watcher.\n\nmac2imgur will now close.", JOptionPane.ERROR_MESSAGE);
            System.exit(1);
        }

        Runnable runnable = createRunnable(watch);
        final Thread consumer = new Thread(runnable);
        consumer.start();

    }

    private static Runnable createRunnable(final WatchService watcher) {
        return new Runnable() {
            public void run() {
                for (; ; ) {

                    WatchKey key;

                    try {
                        key = watcher.take();
                    } catch (InterruptedException e) {
                        return;
                    }

                    for (WatchEvent<?> event : key.pollEvents()) {
                        WatchEvent.Kind<?> kind = event.kind();

                        if (kind == OVERFLOW) {
                            continue;
                        }

                        @SuppressWarnings({"unchecked"})
                        WatchEvent<File> e = (WatchEvent<File>) event;
                        File sc = new File(String.valueOf(e.context()));
                        String name = sc.getName();

                        // Check the file is a screenshot in the right place
                        if (name.startsWith("Screen Shot") && name.endsWith(".png") && new File(DIR + name).exists()) {
                            logger.debug(e.context() + " found, now uploading.");
                            ImgurUploader.upload(sc);
                        }
                    }

                    boolean valid = key.reset();
                    if (!valid) {
                        break;
                    }
                }
            }
        };
    }
}
