package net.rauix.mac2imgur;

import javax.swing.*;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;

import static net.rauix.mac2imgur.Main.VERSION;

public class Updater {

    private double latest;

    public Updater() {
    }

    /**
     * Reads the latest version number from the remote version file
     *
     * @throws IOException
     */
    public void checkUpdates() throws IOException {
        URL url = new URL("https://github.com/rauix/mac2imgur/raw/master/version.txt");
        BufferedReader in = new BufferedReader(new InputStreamReader(url.openStream()));
        String raw;
        latest = (raw = in.readLine()) != null ? Double.valueOf(raw) : VERSION;
        in.close();
    }

    /**
     * Compares the latest version to the current version
     *
     * @return update available
     */
    public boolean updatesAvailable() {
        return latest > VERSION;
    }

    /**
     * Displays a dialog giving the user the opportunity to update
     */
    public void offerUpdate() {
        Object[] options = {"Sure, update now!", "No thanks"};
        int dialog = JOptionPane.showOptionDialog(new JFrame(),
                "There is an update available for mac2imgur.\n\nWould you like to update?\n\n", "mac2imgur",
                JOptionPane.YES_NO_OPTION, JOptionPane.QUESTION_MESSAGE, null, options, options[0]);
        if (dialog == JOptionPane.YES_OPTION) {
            Utils.openBrowser("https://github.com/rauix/mac2imgur/releases");
        }
    }
}
