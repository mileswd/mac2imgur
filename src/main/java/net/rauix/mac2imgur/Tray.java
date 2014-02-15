package net.rauix.mac2imgur;

import javax.imageio.ImageIO;
import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.IOException;

import static net.rauix.mac2imgur.Main.logger;

public class Tray {

    static TrayIcon trayIcon = new TrayIcon(new BufferedImage(1, 1, BufferedImage.TYPE_INT_ARGB));

    static void addSystemTray() {

        if (!SystemTray.isSupported()) {
            // To be perfectly honest, I'm not sure there's any purpose to this check...
            Utils.displayPopup("The system tray is unsupported", JOptionPane.ERROR_MESSAGE);
            return;
        }

        try {

            final SystemTray tray = SystemTray.getSystemTray();

            final PopupMenu popup = new PopupMenu();

            setTrayIcon(Status.INACTIVE);

            MenuItem options = new MenuItem("Options");
            options.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    OptionsGUI.open();
                }
            });

            MenuItem support = new MenuItem("Support");
            support.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    Utils.openBrowser("https://github.com/rauix/mac2imgur");
                }
            });

            MenuItem quit = new MenuItem("Quit mac2imgur");
            quit.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    System.exit(0);
                }
            });

            popup.add(options);
            popup.addSeparator();
            popup.add(support);
            popup.addSeparator();
            popup.add(quit);

            trayIcon.setPopupMenu(popup);

            tray.add(trayIcon);

        } catch (AWTException e) {
            logger.severe(e);
        }
    }

    enum Status {ACTIVE, INACTIVE}

    static void setTrayIcon(Status status) {
        try {

            Image i = ImageIO.read(Tray.class.getClassLoader().getResourceAsStream("resources/" + status.name().toLowerCase() + ".png"));

            // Scale the image according (fixes blurriness on retina displays)
            TrayIcon temp = new TrayIcon(i);
            trayIcon.setImage(i.getScaledInstance(temp.getSize().width, temp.getSize().height, Image.SCALE_SMOOTH));

        } catch (IOException e) {
            logger.severe(e);
        }
    }


}