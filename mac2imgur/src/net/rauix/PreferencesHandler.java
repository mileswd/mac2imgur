package net.rauix;

import java.awt.BorderLayout;
import java.awt.EventQueue;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.util.prefs.Preferences;

import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JSeparator;
import javax.swing.JSlider;
import javax.swing.JTabbedPane;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import javax.swing.filechooser.FileFilter;
import javax.swing.JRadioButton;

public class PreferencesHandler {

	public static Preferences prefs = Preferences.userRoot().node(PreferencesHandler.class.getClass().getName());

	private JFrame frame;
	JRadioButton deleteAfterBtn;
	JRadioButton moveAfterBtn;
	JRadioButton doNothingAfterBtn;

	public static void LaunchGUI(){
		EventQueue.invokeLater(new Runnable(){
			public void run(){
				try {
					PreferencesHandler window = new PreferencesHandler();
					window.frame.setVisible(true);
					window.frame.setVisible(true);
					window.frame.setAlwaysOnTop(true);

				} catch (Exception e){
					e.printStackTrace();
				}
			}
		});
	}

	public PreferencesHandler(){
		initialize();
	}

	private void initialize(){
		frame = new JFrame();
		frame.setBounds(100, 100, 300, 450);
		frame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		JTabbedPane tabbedPane = new JTabbedPane(JTabbedPane.TOP);
		frame.getContentPane().add(tabbedPane, BorderLayout.CENTER);

		JPanel preferencesPanel = new JPanel();
		preferencesPanel.setOpaque(false);
		tabbedPane.addTab("Preferences", null, preferencesPanel, null);
		GridBagLayout gbl_preferencesPanel = new GridBagLayout();
		gbl_preferencesPanel.columnWidths = new int[]{0, 0};
		gbl_preferencesPanel.rowHeights = new int[]{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
		gbl_preferencesPanel.columnWeights = new double[]{1.0, Double.MIN_VALUE};
		gbl_preferencesPanel.rowWeights = new double[]{0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, Double.MIN_VALUE};
		preferencesPanel.setLayout(gbl_preferencesPanel);
		preferencesPanel.setOpaque(false);

		final JCheckBox directLinkChk = new JCheckBox("Use direct link (i.imgur.com)");
		directLinkChk.setSelected(PreferencesHandler.prefs.getBoolean("directlink", true));
		directLinkChk.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e){
				if (directLinkChk.isSelected()){
					PreferencesHandler.prefs.putBoolean("directlink", true);
				} else {
					PreferencesHandler.prefs.putBoolean("directlink", false);
				}
			}
		});
		GridBagConstraints gbc_useDirectLinkChk = new GridBagConstraints();
		gbc_useDirectLinkChk.insets = new Insets(0, 0, 5, 0);
		gbc_useDirectLinkChk.gridx = 0;
		gbc_useDirectLinkChk.gridy = 0;
		preferencesPanel.add(directLinkChk, gbc_useDirectLinkChk);

		final JFileChooser folderChooser = new JFileChooser();
		folderChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
		FileFilter folderFilter = new FileFilter(){
			public boolean accept(File f){
				return f.isDirectory();
			}

			@Override
			public String getDescription(){
				return "Folders";
			}

		};

		final JCheckBox openBrowserChk = new JCheckBox("Open images in browser ");
		openBrowserChk.setSelected(PreferencesHandler.prefs.getBoolean("openbrowser", false));
		openBrowserChk.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e){
				if (openBrowserChk.isSelected()){
					PreferencesHandler.prefs.putBoolean("openbrowser", true);
				} else {
					PreferencesHandler.prefs.putBoolean("openbrowser", false);
				}
			}
		});
		GridBagConstraints gbc_openBrowserChk = new GridBagConstraints();
		gbc_openBrowserChk.insets = new Insets(0, 0, 5, 0);
		gbc_openBrowserChk.gridx = 0;
		gbc_openBrowserChk.gridy = 1;
		preferencesPanel.add(openBrowserChk, gbc_openBrowserChk);

		JSeparator separator_1 = new JSeparator();
		GridBagConstraints gbc_separator_1 = new GridBagConstraints();
		gbc_separator_1.weighty = 1;
		gbc_separator_1.fill = GridBagConstraints.HORIZONTAL;
		gbc_separator_1.insets = new Insets(0, 0, 5, 0);
		gbc_separator_1.gridx = 0;
		gbc_separator_1.gridy = 2;
		preferencesPanel.add(separator_1, gbc_separator_1);

		final JButton chooseFolderBtn = new JButton("Choose folder");
		chooseFolderBtn.setEnabled(PreferencesHandler.prefs.get("post-upload", "delete").contains("move"));
		chooseFolderBtn.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e){
				if (e.getSource() == chooseFolderBtn){
					int returnVal = folderChooser.showOpenDialog(chooseFolderBtn);
					if (returnVal == JFileChooser.APPROVE_OPTION){
						File file = folderChooser.getSelectedFile();
						PreferencesHandler.prefs.put("folderpath", file.getAbsolutePath());
					} else {
						PreferencesHandler.prefs.put("post-upload", "delete");
					}
				}
			}
		});

		deleteAfterBtn = new JRadioButton("Delete after upload");
		deleteAfterBtn.setSelected(PreferencesHandler.prefs.get("post-upload", "delete").contains("delete"));
		deleteAfterBtn.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e){
				if (deleteAfterBtn.isSelected()){
					moveAfterBtn.setSelected(false);
					doNothingAfterBtn.setSelected(false);
					chooseFolderBtn.setEnabled(false);
					PreferencesHandler.prefs.put("post-upload", "delete");
				}
			}
		});

		doNothingAfterBtn = new JRadioButton("Do nothing after upload");
		doNothingAfterBtn.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e){
				if (doNothingAfterBtn.isSelected()){
					moveAfterBtn.setSelected(false);
					deleteAfterBtn.setSelected(false);
					chooseFolderBtn.setEnabled(false);
					PreferencesHandler.prefs.put("post-upload", "nothing");
				}
			}
		});
		GridBagConstraints gbc_doNothingAfterBtn = new GridBagConstraints();
		gbc_doNothingAfterBtn.insets = new Insets(0, 0, 5, 0);
		gbc_doNothingAfterBtn.gridx = 0;
		gbc_doNothingAfterBtn.gridy = 3;
		preferencesPanel.add(doNothingAfterBtn, gbc_doNothingAfterBtn);
		GridBagConstraints gbc_deleteAfterBtn = new GridBagConstraints();
		gbc_deleteAfterBtn.insets = new Insets(0, 0, 5, 0);
		gbc_deleteAfterBtn.gridx = 0;
		gbc_deleteAfterBtn.gridy = 4;
		preferencesPanel.add(deleteAfterBtn, gbc_deleteAfterBtn);

		moveAfterBtn = new JRadioButton("Move after upload");
		moveAfterBtn.setSelected(PreferencesHandler.prefs.get("post-upload", "delete").contains("move"));
		moveAfterBtn.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e){
				deleteAfterBtn.setSelected(false);
				doNothingAfterBtn.setSelected(false);
				chooseFolderBtn.setEnabled(true);
				PreferencesHandler.prefs.put("post-upload", "move");
			}
		});
		GridBagConstraints gbc_moveAfterBtn = new GridBagConstraints();
		gbc_moveAfterBtn.insets = new Insets(0, 0, 5, 0);
		gbc_moveAfterBtn.gridx = 0;
		gbc_moveAfterBtn.gridy = 5;
		preferencesPanel.add(moveAfterBtn, gbc_moveAfterBtn);


		GridBagConstraints gbc_chooseFolderBtn = new GridBagConstraints();
		gbc_chooseFolderBtn.insets = new Insets(0, 0, 5, 0);
		gbc_chooseFolderBtn.gridx = 0;
		gbc_chooseFolderBtn.gridy = 6;
		preferencesPanel.add(chooseFolderBtn, gbc_chooseFolderBtn);

		JSeparator separator = new JSeparator();
		GridBagConstraints gbc_separator = new GridBagConstraints();
		gbc_separator.weighty = 1;
		gbc_separator.fill = GridBagConstraints.HORIZONTAL;
		gbc_separator.insets = new Insets(0, 0, 5, 0);
		gbc_separator.gridx = 0;
		gbc_separator.gridy = 7;
		preferencesPanel.add(separator, gbc_separator);


		final JLabel checkIntervalLbl = new JLabel("Check for screenshots every 2 seconds");
		GridBagConstraints gbc_checkIntervalLbl = new GridBagConstraints();
		gbc_checkIntervalLbl.insets = new Insets(0, 0, 5, 0);
		gbc_checkIntervalLbl.gridx = 0;
		gbc_checkIntervalLbl.gridy = 8;
		preferencesPanel.add(checkIntervalLbl, gbc_checkIntervalLbl);

		final JSlider intervalSlider = new JSlider();
		intervalSlider.setValue(PreferencesHandler.prefs.getInt("interval", 2));
		intervalSlider.addChangeListener(new ChangeListener(){
			public void stateChanged(ChangeEvent e){
				PreferencesHandler.prefs.putInt("interval", intervalSlider.getValue());
				if (Integer.valueOf(intervalSlider.getValue()).equals(1)){
					checkIntervalLbl.setText("Check for screenshots every second");
				} else {
					checkIntervalLbl.setText("Check for screenshots every " + String.valueOf(intervalSlider.getValue()) + " seconds");
				}
			}
		});

		intervalSlider.setMinimum(1);
		intervalSlider.setMaximum(10);
		intervalSlider.setValue(PreferencesHandler.prefs.getInt("interval", 2));
		intervalSlider.setSnapToTicks(true);
		GridBagConstraints gbc_intervalSlider = new GridBagConstraints();
		gbc_intervalSlider.insets = new Insets(0, 0, 5, 0);
		gbc_intervalSlider.gridx = 0;
		gbc_intervalSlider.gridy = 9;
		preferencesPanel.add(intervalSlider, gbc_intervalSlider);

		JSeparator separator_2 = new JSeparator();
		GridBagConstraints gbc_separator_2 = new GridBagConstraints();
		gbc_separator_2.fill = GridBagConstraints.HORIZONTAL;
		gbc_separator_2.insets = new Insets(0, 0, 5, 0);
		gbc_separator_2.gridx = 0;
		gbc_separator_2.gridy = 10;
		preferencesPanel.add(separator_2, gbc_separator_2);

		final JCheckBox trayIconChk = new JCheckBox("Tray icon notification");
		trayIconChk.setSelected(PreferencesHandler.prefs.getBoolean("tray-notify", false));
		trayIconChk.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e){
				if (trayIconChk.isSelected()){
					PreferencesHandler.prefs.putBoolean("tray-notify", true);
				} else {
					PreferencesHandler.prefs.putBoolean("tray-notify", false);	
				}
			}
		});
		GridBagConstraints gbc_trayIconChk = new GridBagConstraints();
		gbc_trayIconChk.insets = new Insets(0, 0, 5, 0);
		gbc_trayIconChk.gridx = 0;
		gbc_trayIconChk.gridy = 11;
		preferencesPanel.add(trayIconChk, gbc_trayIconChk);

		final JCheckBox notificationCenterChk = new JCheckBox("Notification center (10.8+)");
		notificationCenterChk.setSelected(PreferencesHandler.prefs.getBoolean("center-notify", true));
		notificationCenterChk.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e){
				if (notificationCenterChk.isSelected()){
					PreferencesHandler.prefs.putBoolean("center-notify", true);
				} else {
					PreferencesHandler.prefs.putBoolean("center-notify", false);
				}
			}
		});
		GridBagConstraints gbc_notificationCenterChk = new GridBagConstraints();
		gbc_notificationCenterChk.insets = new Insets(0, 0, 5, 0);
		gbc_notificationCenterChk.gridx = 0;
		gbc_notificationCenterChk.gridy = 12;
		preferencesPanel.add(notificationCenterChk, gbc_notificationCenterChk);

		folderChooser.setFileFilter(folderFilter);
		GridBagLayout gridBagLayout = new GridBagLayout();
		gridBagLayout.columnWidths = new int[]{0, 0, 0};
		gridBagLayout.rowHeights = new int[]{0, 0, 0, 0, 0};
		gridBagLayout.columnWeights = new double[]{0.0, 1.0, Double.MIN_VALUE};
		gridBagLayout.rowWeights = new double[]{0.0, 0.0, 0.0, 1.0, Double.MIN_VALUE};
	}

}
