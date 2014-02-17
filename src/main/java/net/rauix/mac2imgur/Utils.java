package net.rauix.mac2imgur;

import org.apache.commons.io.FileUtils;

import javax.swing.*;
import java.awt.*;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.StringSelection;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URL;

import static net.rauix.mac2imgur.Main.*;

public final class Utils {

    private Utils() {/* Block unnecessary instantiation */}

    static void tidyUp(File f) {

		/*
         * SKIP = Do nothing
		 * MOVE = Move to Directory
		 * DELETE = Delete screenshot
		 */
        String moveDir = prefs.get("MOVE-DIR", DIR);

        if (prefs.get("TIDY", "IGNORE").equals("MOVE") && !moveDir.equals(DIR)) {

            try {
                Main.logger.debug("Moving screenshot to " + moveDir);
                FileUtils.moveFileToDirectory(f, new File(moveDir), false);
            } catch (IOException e) {
                JOptionPane.showMessageDialog(null, "The screenshot could not be moved!\n\nTry changing the folder in the options menu.", "mac2imgur", JOptionPane.WARNING_MESSAGE);
                logger.severe(e);
            }

        } else if (prefs.get("TIDY", "IGNORE").equals("DELETE")) {
            FileUtils.deleteQuietly(f);
        }
    }

    static void checkUpdates() {
        try {
            URL url = new URL("https://github.com/rauix/mac2imgur/raw/master/version.txt");
            BufferedReader in = new BufferedReader(new InputStreamReader(url.openStream()));
            String raw;
            double latest = (raw = in.readLine()) != null ? Double.valueOf(raw) : VERSION;
            // Don't bug people using future versions!
            if (latest > VERSION) {
                Object[] options = {"Sure, update now!", "No thanks"};
                int dialog = JOptionPane.showOptionDialog(new JFrame(),
                        "There is an update available for mac2imgur.\n\nWould you like to update?\n\n",
                        "mac2imgur", JOptionPane.YES_NO_OPTION, JOptionPane.QUESTION_MESSAGE, null,
                        options, options[0]);
                if (dialog == JOptionPane.YES_OPTION) {
                    Utils.openBrowser("https://github.com/rauix/mac2imgur/releases");
                }
            }
            in.close();
        } catch (MalformedURLException e) {
            logger.debug(e);
        } catch (IOException e) {
            logger.debug(e);
        }
    }

    static void copyToClipboard(String s) {
        StringSelection selection = new StringSelection(s);
        Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
        clipboard.setContents(selection, selection);
    }

    static void openBrowser(String url) {
        try {
            Desktop.getDesktop().browse(new URI(url));
        } catch (Exception e) {
            displayPopup("Could not open website, try going to " + url + " manually.", JOptionPane.WARNING_MESSAGE);
            logger.warning(e);
        }
    }

    static String getDataDirectory() {
        String dataDir = System.getProperty("user.home") + "/Library/Application Support/mac2imgur/";
        if (!new File(dataDir).exists()) {
            new File(dataDir).mkdirs();
        }
        return dataDir;
    }

    static void displayPopup(String msg, int type) {
        JOptionPane.showMessageDialog(null, msg, "mac2imgur", type);
    }

}