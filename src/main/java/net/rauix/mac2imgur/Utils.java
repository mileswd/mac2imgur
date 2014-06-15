package net.rauix.mac2imgur;

import org.joda.time.DateTime;

import javax.swing.*;
import java.awt.*;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.StringSelection;
import java.io.File;
import java.net.URI;
import java.util.prefs.Preferences;

public final class Utils {

    private static Logger logger;
    private static String lastToken;
    private static DateTime lastTokenTime = DateTime.now();

    /**
     * Gets the preference node for mac2imgur
     *
     * @return mac2imgur Preferences
     */
    public static Preferences getPrefs() {
        return Preferences.userRoot().node("net.rauix.mac2imgur");
    }

    /**
     * Returns the logger if it has been initialized, otherwise tries to initialize the logger and set up the logging
     * directory, in the event of the latter failing, it resorts to not logging to a file.
     *
     * @return application logger
     */
    public static Logger getLogger() {
        Level lvl = Utils.getPrefs().getBoolean("DEBUG-LOGGING", false) ? Level.DEBUG : Level.SEVERE;
        if (logger == null) {
            String logPath = System.getProperty("user.home") + "/Library/Application Support/mac2imgur/mac2imgur.log";
            File logFile = new File(logPath);
            // Check log dir exists
            if (!logFile.exists() && !logFile.mkdirs()) {
                logger = new Logger(lvl);
                new PopupDialog("Could not create log directory", JOptionPane.WARNING_MESSAGE);
                return logger;
            } else {
                logger = new Logger(lvl, logFile);
                return logger;
            }
        } else {
            return logger;
        }
    }

    /**
     * Copies a string of text to the user's clipboard, ready to be pasted
     *
     * @param s String to copy to the clipboard
     */

    public static void copyToClipboard(String s) {
        StringSelection selection = new StringSelection(s);
        Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
        clipboard.setContents(selection, selection);
    }

    /**
     * Opens a URL in the users browser
     *
     * @param url URL to open in browser
     */
    public static void openBrowser(String url) {
        try {
            Desktop.getDesktop().browse(new URI(url));
        } catch (Exception e) {
            new PopupDialog("Could not open website, try going to " + url + " manually.", JOptionPane.WARNING_MESSAGE);
            logger.warning(e);
        }
    }

    public static void setLastToken(String token){
        lastTokenTime = DateTime.now().plusSeconds(3600);
        lastToken = token;
    }

    public static String getLastToken(){
        return lastToken;
    }

    public static boolean isTokenStillValid(){

        return (DateTime.now().isBefore(lastTokenTime));

    }

}