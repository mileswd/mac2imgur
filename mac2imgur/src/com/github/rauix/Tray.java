package com.github.rauix;

import java.awt.MenuItem;
import java.awt.PopupMenu;
import java.awt.SystemTray;
import java.awt.TrayIcon;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;

import javax.imageio.ImageIO;

public class Tray {

	static TrayIcon trayIcon;

	public static void addSystemTray() {
		try {
			trayIcon = new TrayIcon(ImageIO.read(Tray.class.getClassLoader().getResourceAsStream("res/inactive.png")));
			ActionListener listener = new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					//Open the popup menu
					popupMenu().dispatchEvent(e);
				}
			};
			SystemTray.getSystemTray().add(trayIcon);
			trayIcon.setPopupMenu(popupMenu());
			trayIcon.addActionListener(listener);
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	public static PopupMenu popupMenu() {
		PopupMenu popup = new PopupMenu();
		MenuItem about = new MenuItem("Website");
		ActionListener launchAbout = new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				Utils.openBrowser("https://github.com/rauix/mac2imgur");
			}
		};
		about.addActionListener(launchAbout);
		MenuItem options = new MenuItem("Options");
		ActionListener launchOptions = new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				PreferencesGUI.LaunchGUI();
			}
		};
		options.addActionListener(launchOptions);
		MenuItem exit = new MenuItem("Quit");
		ActionListener launchQuit = new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				System.exit(0);
			}
		};
		exit.addActionListener(launchQuit);
		popup.add(about);
		popup.addSeparator();
		popup.add(options);
		popup.addSeparator();
		popup.add(exit);
		return popup;
	}

	public static void uploadWasSuccessful(boolean b){
		try{
			if (b){
				System.out.println("Screenshot successfully uploaded!");
				//Set the icon to green
				trayIcon.setImage(ImageIO.read(Tray.class.getClassLoader().getResourceAsStream("res/success.png")));
			} else {
				System.out.println("Screenshot failed to upload!");
				//Set the icon to red
				trayIcon.setImage(ImageIO.read(Tray.class.getClassLoader().getResourceAsStream("res/fail.png")));
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			java.util.Timer timer = new java.util.Timer();
			java.util.TimerTask task = new java.util.TimerTask() {
				public void run() {
					try {
						trayIcon.setImage(ImageIO.read(Tray.class.getClassLoader().getResourceAsStream("res/inactive.png")));
					} catch (IOException e) {
						e.printStackTrace();
					}
				}
			};
			//Wait 15 seconds then put the icon back to inactive
			timer.schedule(task, 15000);
		}
	}
}
