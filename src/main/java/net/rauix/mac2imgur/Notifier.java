package net.rauix.mac2imgur;

import com.sun.jna.Library;
import com.sun.jna.Native;
import org.apache.commons.io.FileUtils;

import javax.swing.*;
import java.io.File;
import java.io.IOException;

import static net.rauix.mac2imgur.Main.logger;

interface NotificationBridge extends Library {

    String path = FileUtils.getTempDirectoryPath() + "/NotificationBridge.dylib";
    NotificationBridge instance = (NotificationBridge) Native.loadLibrary(path, NotificationBridge.class);

    public int sendNotification(String title, String subtitle, String text, int offset);
}

public final class Notifier {

    private Notifier() {/* Block unnecessary instantiation */}

    static void sendNotification(Notification n) {
        if (n.equals(Notification.SUCCESS)) {
            NotificationBridge.instance.sendNotification("mac2imgur", "", "Screenshot uploaded successfully!", 0);
        } else {
            NotificationBridge.instance.sendNotification("mac2imgur", "", "Screenshot upload failed", 0);
        }
    }

    static void setupDylib() {
        try {
            FileUtils.copyInputStreamToFile(Notifier.class.getClassLoader().getResourceAsStream("resources/NotificationBridge.dylib"), new File(FileUtils.getTempDirectoryPath() + "/NotificationBridge.dylib"));
            logger.debug("Dylib dir: " + FileUtils.getTempDirectoryPath());
        } catch (IOException e) {
            Utils.displayPopup("Notification Center integration could not be setup. No notifications will be displayed.", JOptionPane.WARNING_MESSAGE);
            logger.severe(e);
        }
    }

    enum Notification {SUCCESS, FAILURE}
}
