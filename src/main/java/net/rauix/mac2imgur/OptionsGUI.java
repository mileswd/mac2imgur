package net.rauix.mac2imgur;

import com.intellij.uiDesigner.core.GridConstraints;
import com.intellij.uiDesigner.core.GridLayoutManager;
import com.intellij.uiDesigner.core.Spacer;
import net.rauix.teensy.Detail;

import javax.swing.*;
import javax.swing.filechooser.FileFilter;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;

public class OptionsGUI extends JDialog {
    private JPanel contentPane;
    private JTabbedPane tabbedPane;
    private JCheckBox useDirectLinkICheckBox;
    private JRadioButton doNothingAfterUploadRadioButton;
    private JRadioButton deleteAfterUploadRadioButton;
    private JRadioButton moveAfterUploadRadioButton;
    private JButton chooseDirectoryButton;
    private JCheckBox debugLoggingCheckBox;
    private JButton chooseDirectoryButton1;
    private JButton resetToDefaultDirectoryButton;
    private JCheckBox openImagesInBrowserCheckBox;
    private JPanel optionsPanel;
    private JPanel advancedPanel;

    public OptionsGUI() {
        setContentPane(contentPane);
        setModal(true);
        setTitle("mac2imgur");
        setAlwaysOnTop(true);
        optionsPanel.setOpaque(false);
        advancedPanel.setOpaque(false);

        useDirectLinkICheckBox.setSelected(Main.prefs.getBoolean("DIRECT-LINK", true));
        openImagesInBrowserCheckBox.setSelected(Main.prefs.getBoolean("OPEN-IMAGE", false));
        doNothingAfterUploadRadioButton.setSelected(Main.prefs.get("TIDY", "IGNORE").equals("IGNORE"));
        deleteAfterUploadRadioButton.setSelected(Main.prefs.get("TIDY", "IGNORE").equals("DELETE"));
        moveAfterUploadRadioButton.setSelected(Main.prefs.get("TIDY", "IGNORE").equals("MOVE"));
        chooseDirectoryButton.setEnabled(Main.prefs.get("TIDY", "IGNORE").equals("MOVE"));
        debugLoggingCheckBox.setSelected(Main.logger.getLogDetail().equals(Detail.DEBUG));

        setDefaultCloseOperation(DISPOSE_ON_CLOSE);

        final JFileChooser fileChooser = new JFileChooser();
        fileChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
        fileChooser.addChoosableFileFilter(new FileFilter() {
            public boolean accept(File f) {
                return f.isDirectory() && !Main.DIR.equals(f.getAbsolutePath() + "/");
            }

            @Override
            public String getDescription() {
                return "Folders";
            }

        });
        debugLoggingCheckBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                if (debugLoggingCheckBox.isSelected()) {
                    Main.logger.setLogDetail(Detail.DEBUG);
                    Main.prefs.putBoolean("DEBUG", true);
                } else {
                    Main.logger.setLogDetail(Detail.SEVERE);
                    Main.prefs.putBoolean("DEBUG", false);
                }
            }
        });
        useDirectLinkICheckBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                if (useDirectLinkICheckBox.isSelected()) {
                    Main.prefs.putBoolean("DIRECT-LINK", true);
                } else {
                    Main.prefs.putBoolean("DIRECT-LINK", false);
                }
            }
        });
        doNothingAfterUploadRadioButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                if (doNothingAfterUploadRadioButton.isSelected()) {
                    chooseDirectoryButton.setEnabled(false);
                    Main.prefs.put("TIDY", "IGNORE");
                }
            }
        });
        deleteAfterUploadRadioButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                if (deleteAfterUploadRadioButton.isSelected()) {
                    chooseDirectoryButton.setEnabled(false);
                    Main.prefs.put("TIDY", "DELETE");
                }
            }
        });
        moveAfterUploadRadioButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                if (moveAfterUploadRadioButton.isSelected()) {
                    chooseDirectoryButton.setEnabled(true);
                    Main.prefs.put("TIDY", "MOVE");
                }
            }
        });
        chooseDirectoryButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                if (e.getSource() == chooseDirectoryButton) {
                    if (fileChooser.showOpenDialog(chooseDirectoryButton) == JFileChooser.APPROVE_OPTION) {
                        File file = fileChooser.getSelectedFile();
                        Main.prefs.put("MOVE-DIR", file.getAbsolutePath() + "/");
                    } else {
                        Main.prefs.put("TIDY", "IGNORE");
                    }
                }
            }
        });
        debugLoggingCheckBox.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                if (debugLoggingCheckBox.isSelected()) {
                    Main.logger.setLogDetail(Detail.DEBUG);
                } else {
                    Main.logger.setLogDetail(Detail.SEVERE);
                }
            }
        });
        chooseDirectoryButton1.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                if (fileChooser.showOpenDialog(chooseDirectoryButton1) == JFileChooser.APPROVE_OPTION) {
                    File file = fileChooser.getSelectedFile();
                    Main.prefs.put("MONITOR-DIR", file.getAbsolutePath() + "/");
                    Main.logger.debug("Will monitor: " + file.getAbsolutePath() + "/");
                    Utils.displayPopup("You must restart mac2imgur to apply this change!", JOptionPane.INFORMATION_MESSAGE);
                }
            }
        });
        resetToDefaultDirectoryButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                Main.prefs.put("MONITOR-DIR", System.getProperty("user.home") + "/Desktop/");
                Main.logger.debug("Will monitor: " + System.getProperty("user.home") + "/Desktop/");
            }

        });
    }

    public static void open() {
        OptionsGUI dialog = new OptionsGUI();
        dialog.pack();
        dialog.setVisible(true);
    }

    {
// GUI initializer generated by IntelliJ IDEA GUI Designer
// >>> IMPORTANT!! <<<
// DO NOT EDIT OR ADD ANY CODE HERE!
        $$$setupUI$$$();
    }

    /**
     * Method generated by IntelliJ IDEA GUI Designer
     * >>> IMPORTANT!! <<<
     * DO NOT edit this method OR call it in your code!
     *
     * @noinspection ALL
     */
    private void $$$setupUI$$$() {
        contentPane = new JPanel();
        contentPane.setLayout(new GridLayoutManager(1, 1, new Insets(10, 10, 10, 10), -1, -1));
        tabbedPane = new JTabbedPane();
        contentPane.add(tabbedPane, new GridConstraints(0, 0, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_BOTH, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, null, new Dimension(200, 200), null, 0, false));
        optionsPanel = new JPanel();
        optionsPanel.setLayout(new GridLayoutManager(8, 2, new Insets(0, 0, 0, 0), -1, -1));
        tabbedPane.addTab("Options", optionsPanel);
        useDirectLinkICheckBox = new JCheckBox();
        useDirectLinkICheckBox.setText("Use direct link (i.imgur.com)");
        optionsPanel.add(useDirectLinkICheckBox, new GridConstraints(0, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        final Spacer spacer1 = new Spacer();
        optionsPanel.add(spacer1, new GridConstraints(0, 1, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_HORIZONTAL, GridConstraints.SIZEPOLICY_WANT_GROW, 1, null, null, null, 0, false));
        final Spacer spacer2 = new Spacer();
        optionsPanel.add(spacer2, new GridConstraints(7, 0, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_VERTICAL, 1, GridConstraints.SIZEPOLICY_WANT_GROW, null, null, null, 0, false));
        openImagesInBrowserCheckBox = new JCheckBox();
        openImagesInBrowserCheckBox.setText("Open images in browser");
        optionsPanel.add(openImagesInBrowserCheckBox, new GridConstraints(1, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        final JSeparator separator1 = new JSeparator();
        optionsPanel.add(separator1, new GridConstraints(2, 0, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_BOTH, GridConstraints.SIZEPOLICY_WANT_GROW, GridConstraints.SIZEPOLICY_WANT_GROW, null, null, null, 0, false));
        doNothingAfterUploadRadioButton = new JRadioButton();
        doNothingAfterUploadRadioButton.setText("Do nothing after upload");
        optionsPanel.add(doNothingAfterUploadRadioButton, new GridConstraints(3, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        deleteAfterUploadRadioButton = new JRadioButton();
        deleteAfterUploadRadioButton.setText("Delete after upload");
        optionsPanel.add(deleteAfterUploadRadioButton, new GridConstraints(4, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        moveAfterUploadRadioButton = new JRadioButton();
        moveAfterUploadRadioButton.setText("Move after upload");
        optionsPanel.add(moveAfterUploadRadioButton, new GridConstraints(5, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        chooseDirectoryButton = new JButton();
        chooseDirectoryButton.setEnabled(true);
        chooseDirectoryButton.setText("Choose directory");
        optionsPanel.add(chooseDirectoryButton, new GridConstraints(6, 0, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_HORIZONTAL, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        advancedPanel = new JPanel();
        advancedPanel.setLayout(new GridLayoutManager(6, 2, new Insets(0, 0, 0, 0), -1, -1));
        tabbedPane.addTab("Advanced", advancedPanel);
        debugLoggingCheckBox = new JCheckBox();
        debugLoggingCheckBox.setText("Debug logging");
        advancedPanel.add(debugLoggingCheckBox, new GridConstraints(0, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        final Spacer spacer3 = new Spacer();
        advancedPanel.add(spacer3, new GridConstraints(0, 1, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_HORIZONTAL, GridConstraints.SIZEPOLICY_WANT_GROW, 1, null, null, null, 0, false));
        final JSeparator separator2 = new JSeparator();
        advancedPanel.add(separator2, new GridConstraints(1, 0, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_HORIZONTAL, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_WANT_GROW, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_WANT_GROW, null, null, null, 0, false));
        chooseDirectoryButton1 = new JButton();
        chooseDirectoryButton1.setText("Choose directory");
        advancedPanel.add(chooseDirectoryButton1, new GridConstraints(3, 0, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_HORIZONTAL, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        final JLabel label1 = new JLabel();
        label1.setText("Change monitored directory:");
        advancedPanel.add(label1, new GridConstraints(2, 0, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_FIXED, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        resetToDefaultDirectoryButton = new JButton();
        resetToDefaultDirectoryButton.setText("Reset to default directory");
        advancedPanel.add(resetToDefaultDirectoryButton, new GridConstraints(4, 0, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_HORIZONTAL, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        final Spacer spacer4 = new Spacer();
        advancedPanel.add(spacer4, new GridConstraints(5, 0, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_VERTICAL, 1, GridConstraints.SIZEPOLICY_WANT_GROW, null, null, null, 0, false));
        ButtonGroup buttonGroup;
        buttonGroup = new ButtonGroup();
        buttonGroup.add(doNothingAfterUploadRadioButton);
        buttonGroup.add(deleteAfterUploadRadioButton);
        buttonGroup.add(moveAfterUploadRadioButton);
    }

    /**
     * @noinspection ALL
     */
    public JComponent $$$getRootComponent$$$() {
        return contentPane;
    }
}
