package net.rauix.mac2imgur;

import com.sun.jna.Library;
import com.sun.jna.Native;
import org.apache.commons.io.FileUtils;

import javax.swing.*;
import java.io.File;
import java.io.IOException;

interface NotificationBridge extends Library {

    String path = FileUtils.getTempDirectoryPath() + "/NotificationBridge.dylib";
    NotificationBridge instance = (NotificationBridge) Native.loadLibrary(path, NotificationBridge.class);

    public int sendNotification(String title, String subtitle, String text, int offset);
}

public class Notification {

    private String title;
    private String subtitle;
    private String text;
    private int offset;

    public Notification(String title, String subtitle, String text, int offset) {
        this.title = title;
        this.subtitle = title;
        this.text = text;
        this.offset = offset;
    }

    /**
     * Displays the notification through the OS X Notification Center
     */
    public void display() {
        // If the Dylib has been set up successfully, send the notification
        if (isSetup()) {
            NotificationBridge.instance.sendNotification(title, subtitle, text, offset);
        }
    }

    /**
     * Checks whether the dylib has been moved to a temporary directory for use
     *
     * @return whether the dylib has been setup or not
     */
    public boolean isSetup() {
        File dylib = new File(FileUtils.getTempDirectoryPath() + "/NotificationBridge.dylib");
        if (!dylib.exists()) {
            try {
                FileUtils.copyInputStreamToFile(this.getClass().getClassLoader().getResourceAsStream("resources/NotificationBridge.dylib"), dylib);
                // Remove the dylib once we're done with it
                dylib.deleteOnExit();
                Utils.getLogger().debug("Dylib dir: " + FileUtils.getTempDirectoryPath());
                return dylib.exists();
            } catch (IOException e) {
                new PopupDialog("Notification Center integration could not be setup. No notifications will be displayed.", JOptionPane.WARNING_MESSAGE);
                Utils.getLogger().severe(e);
                return false;
            }
        } else {
            return true;
        }
    }
}
