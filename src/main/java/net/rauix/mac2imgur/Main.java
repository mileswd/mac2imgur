package net.rauix.mac2imgur;

import com.barbarysoftware.watchservice.*;
import com.mashape.unirest.http.exceptions.UnirestException;
import org.apache.commons.io.FilenameUtils;
import org.json.JSONObject;

import javax.swing.*;
import java.awt.*;
import java.io.File;
import java.io.IOException;

public class Main {

    public static final double VERSION = 2.3;

    static final String DIR = Utils.getPrefs().get("MONITOR-DIR", System.getProperty("user.home") + "/Desktop/");

    static Tray tray;

    public static void main(String[] args) {

        // Log system information for debugging purposes
        Utils.getLogger().debug("Launching mac2imgur v" + VERSION);
        Utils.getLogger().debug(System.getProperty("java.version") + " (" + System.getProperty("java.vendor") + ") on " + System.getProperty("os.name")
                + " - " + System.getProperty("os.version") + " (" + System.getProperty("os.arch") + ")");
        Utils.getLogger().debug("Monitoring Directory: " + DIR);

        // Check for updates
        Updater updater = new Updater();
        try {
            updater.checkUpdates();

            if (updater.updatesAvailable()) {
                updater.offerUpdate();
            }

        } catch (IOException e) {
            Utils.getLogger().debug(e);
        }

        try {
            tray = new Tray();
        } catch (IOException e) {
            Utils.getLogger().debug(e);
        } catch (AWTException e) {
            Utils.getLogger().debug(e);
        }

        File monitorDir = new File(DIR);

        if (!monitorDir.exists()) {
            // It should exist, as it's a system folder
            new PopupDialog("The Desktop folder (" + DIR + ") does not exist.\n\nmac2imgur will now close.", JOptionPane.ERROR_MESSAGE);
            System.exit(1);
        }

        final WatchService watch = WatchService.newWatchService();
        final WatchableFile watchableFile = new WatchableFile(monitorDir);
        try {
            watchableFile.register(watch, StandardWatchEventKind.ENTRY_CREATE);
        } catch (IOException e) {
            Utils.getLogger().severe(e);
            new PopupDialog("Could not start folder watcher.\n\nmac2imgur will now close.", JOptionPane.ERROR_MESSAGE);
            System.exit(1);
        }

        final Thread t = new Thread(createRunnable(watch));
        t.start();

    }

    public static Runnable createRunnable(final WatchService watcher) {
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

                        if (kind.equals(StandardWatchEventKind.OVERFLOW)) {
                            continue;
                        }

                        @SuppressWarnings({"unchecked"})
                        WatchEvent<File> ev = (WatchEvent<File>) event;
                        File file = new File(String.valueOf(ev.context()));

                        // Check that uploads haven't been paused and the file is in the right place
                        if (!tray.uploadsPaused() && new File(DIR + file.getName()).exists()) {

                            String extension = FilenameUtils.getExtension(file.getName());
                            ImageType it = ImageType.getTypeByName(extension.toUpperCase());

                            // Check the file is a supported image
                            if (!it.equals(ImageType.INVALID) && it.isEnabled()) {
                                Image img = new Image(file);

                                Utils.getLogger().debug(ev.context() + " found, now uploading.");
                                ImgurUpload upload;

                                // Check if the user wants to use the anonymous or the account upload
                                if(Utils.getPrefs().getBoolean("ANONYMOUS", true))
                                    upload = new AnonymousUpload(img);

                                else
                                    upload = new AccountUpload(img);


                                // Change icon to indicate activity has started and begin the upload
                                tray.setTrayIconActive(true);
                                try {
                                    upload.start();
                                } catch (UnirestException e) {
                                    Utils.getLogger().debug(e);
                                } catch (IOException e) {
                                    Utils.getLogger().debug(e);
                                }

                                if (upload.wasSuccessful()) {

                                    JSONObject json = upload.getResponse();

                                    // Check whether the user wants the gallery or direct link
                                    String url = Utils.getPrefs().getBoolean("DIRECT-LINK", true) ? json.getJSONObject("data").getString("link") : "https://imgur.com/" + json.getJSONObject("data").getString("id");

                                    // Check if the user wants the image automatically opened
                                    if (Utils.getPrefs().getBoolean("OPEN-IMAGE", false)) {
                                        Utils.openBrowser(url);
                                    }

                                    // Copy url to clipboard
                                    Utils.copyToClipboard(url);

                                    // Notify the user
                                    Notification notification = new Notification("mac2imgur", "", "Screenshot uploaded successfully!", 0);
                                    notification.display();

                                    try {
                                        img.tidyUp(Utils.getPrefs());
                                    } catch (IOException e) {
                                        Utils.getLogger().debug(e);
                                        JOptionPane.showMessageDialog(null, "The screenshot could not be moved!\n\nTry changing the folder in the options menu.", "mac2imgur", JOptionPane.WARNING_MESSAGE);
                                    }
                                } else {
                                    // Notify the user
                                    Notification notification = new Notification("mac2imgur", "", "Screenshot failed to upload", 0);
                                    notification.display();
                                }

                                // Change icon to indicate activity has ceased
                                tray.setTrayIconActive(false);
                            }
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
