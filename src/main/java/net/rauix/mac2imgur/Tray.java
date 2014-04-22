package net.rauix.mac2imgur;

import javax.imageio.ImageIO;
import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;

public class Tray {

    private TrayIcon trayIcon;
    CheckboxMenuItem pauseChk;
    java.awt.Image activeImg;
    java.awt.Image inactiveImg;

    public Tray() throws IOException, AWTException {

        activeImg = getScaledTrayIcon(ImageIO.read(this.getClass().getClassLoader().getResourceAsStream("resources/active.png")));
        inactiveImg = getScaledTrayIcon(ImageIO.read(this.getClass().getClassLoader().getResourceAsStream("resources/inactive.png")));

        trayIcon = new TrayIcon(inactiveImg);

        // To be perfectly honest, I'm not sure there's any purpose to this check...
        if (!SystemTray.isSupported()) {
            new PopupDialog("The system tray is unsupported", JOptionPane.ERROR_MESSAGE);
            return;
        }

        SystemTray tray = SystemTray.getSystemTray();

        PopupMenu popup = new PopupMenu();

        pauseChk = new CheckboxMenuItem("Pause monitoring");

        MenuItem prefs = new MenuItem("Preferences...");
        prefs.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                PreferencesGUI.open();
            }
        });

        MenuItem website = new MenuItem("Website");
        website.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                Utils.openBrowser("https://github.com/rauix/mac2imgur");
            }
        });

        MenuItem quit = new MenuItem("Quit");
        quit.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                System.exit(0);
            }
        });

        popup.add(pauseChk);
        popup.addSeparator();
        popup.add(prefs);
        popup.add(website);
        popup.addSeparator();
        popup.add(quit);

        trayIcon.setPopupMenu(popup);

        tray.add(trayIcon);

    }

    private java.awt.Image getScaledTrayIcon(java.awt.Image i) {
        // Scale the image according (fixes blurriness on retina displays)
        TrayIcon temp = new TrayIcon(i);
        // This is different to trayIcon.setImageAutoSize(true);
        return i.getScaledInstance(temp.getSize().width, temp.getSize().height, java.awt.Image.SCALE_SMOOTH);
    }

    /**
     * Changes the icon accordingly
     *
     * @param active Whether or not the icon should be active
     */
    public void setTrayIconActive(boolean active) {
        if (active) {
            trayIcon.setImage(activeImg);
        } else {
            trayIcon.setImage(inactiveImg);
        }
    }

    /**
     * Checks if the menu item 'Pause monitoring' has been clicked
     *
     * @return whether or not uploads should be paused
     */
    public boolean uploadsPaused() {
        return pauseChk.getState();
    }

}