package net.rauix;

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

	public static void addSystemTray(){
		try {
			trayIcon = new TrayIcon(ImageIO.read(Tray.class.getClassLoader().getResourceAsStream("res/inactive.png")));
			ActionListener listener = new ActionListener()
			{
				public void actionPerformed(ActionEvent e){
					Tray.popupMenu().dispatchEvent(e);
				}
			};
			SystemTray.getSystemTray().add(trayIcon);
			trayIcon.setPopupMenu(popupMenu());
			trayIcon.addActionListener(listener);
		} catch (Exception e){
			e.printStackTrace();
		}
	}

	public static PopupMenu popupMenu(){
		PopupMenu popup = new PopupMenu();
		MenuItem about = new MenuItem("Website");
		ActionListener launchAbout = new ActionListener(){
			public void actionPerformed(ActionEvent e){
				Utils.openBrowser("https://github.com/rauix/mac2imgur");
			}
		};
		about.addActionListener(launchAbout);
		MenuItem options = new MenuItem("Options");
		ActionListener launchOptions = new ActionListener(){
			public void actionPerformed(ActionEvent e){
				PreferencesHandler.LaunchGUI();
			}
		};
		options.addActionListener(launchOptions);
		MenuItem exit = new MenuItem("Quit");
		ActionListener launchQuit = new ActionListener(){
			public void actionPerformed(ActionEvent e){
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

	public static void setIconResult(boolean b){
		try {
			if (b){
				//Set the icon to green
				Tray.trayIcon.setImage(ImageIO.read(Tray.class.getClassLoader().getResourceAsStream("res/success.png")));
			} else {
				//Set the icon to red
				Tray.trayIcon.setImage(ImageIO.read(Tray.class.getClassLoader().getResourceAsStream("res/fail.png")));
			}
		} catch (IOException e){
			e.printStackTrace();
		} finally {
			java.util.Timer timer = new java.util.Timer();
			java.util.TimerTask task = new java.util.TimerTask(){
				public void run(){
					try {
						Tray.trayIcon.setImage(ImageIO.read(Tray.class.getClassLoader().getResourceAsStream("res/inactive.png")));
					} catch (IOException e){
						e.printStackTrace();
					}
				}
			};
			//Wait 15 seconds then put the icon back to inactive
			timer.schedule(task, 15000);
		}
	}
}