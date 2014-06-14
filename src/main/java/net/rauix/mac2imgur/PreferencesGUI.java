package net.rauix.mac2imgur;

import com.intellij.uiDesigner.core.GridConstraints;
import com.intellij.uiDesigner.core.GridLayoutManager;

import javax.swing.*;
import javax.swing.filechooser.FileFilter;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;

public class PreferencesGUI extends JDialog {
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
    private JCheckBox JPEGJPGCheckBox;
    private JCheckBox GIFCheckBox;
    private JCheckBox PNGCheckBox;
    private JCheckBox APNGCheckBox;
    private JCheckBox TIFFCheckBox;
    private JCheckBox BMPCheckBox;
    private JCheckBox PDFCheckBox;
    private JCheckBox XCFCheckBox;
    private JPanel formatsPanel;
    private JPanel accountPanel;
    private JButton openBrowserForAuthenticationButton;
    private JButton authorizeButton;
    private JLabel pinLabel;
    private JTextField pinField;
    private JCheckBox anonymousUploadCheckBox;

    public PreferencesGUI() {
        setContentPane(contentPane);
        setModal(true);
        setTitle("mac2imgur");
        setAlwaysOnTop(true);
        optionsPanel.setOpaque(false);
        formatsPanel.setOpaque(false);
        advancedPanel.setOpaque(false);

        useDirectLinkICheckBox.setSelected(Utils.getPrefs().getBoolean("DIRECT-LINK", true));
        openImagesInBrowserCheckBox.setSelected(Utils.getPrefs().getBoolean("OPEN-IMAGE", false));
        doNothingAfterUploadRadioButton.setSelected(Utils.getPrefs().get("TIDY", "IGNORE").equals("IGNORE"));
        deleteAfterUploadRadioButton.setSelected(Utils.getPrefs().get("TIDY", "IGNORE").equals("DELETE"));
        moveAfterUploadRadioButton.setSelected(Utils.getPrefs().get("TIDY", "IGNORE").equals("MOVE"));
        chooseDirectoryButton.setEnabled(Utils.getPrefs().get("TIDY", "IGNORE").equals("MOVE"));
        debugLoggingCheckBox.setSelected(Utils.getLogger().getLogLevel().equals(Level.DEBUG));
        JPEGJPGCheckBox.setSelected(Utils.getPrefs().getBoolean("JPG", false));
        GIFCheckBox.setSelected(Utils.getPrefs().getBoolean("GIF", false));
        PNGCheckBox.setSelected(Utils.getPrefs().getBoolean("PNG", true));
        APNGCheckBox.setSelected(Utils.getPrefs().getBoolean("APNG", false));
        TIFFCheckBox.setSelected(Utils.getPrefs().getBoolean("TIFF", false));
        BMPCheckBox.setSelected(Utils.getPrefs().getBoolean("BMP", false));
        PDFCheckBox.setSelected(Utils.getPrefs().getBoolean("PDF", false));
        XCFCheckBox.setSelected(Utils.getPrefs().getBoolean("XCF", false));
        anonymousUploadCheckBox.setSelected(Utils.getPrefs().getBoolean("ANONYMOUS", true));

        openBrowserForAuthenticationButton.setEnabled(!Utils.getPrefs().getBoolean("ANONYMOUS", false));
        authorizeButton.setEnabled(!Utils.getPrefs().getBoolean("ANONYMOUS", false));
        pinField.setEnabled(!Utils.getPrefs().getBoolean("ANONYMOUS", false));
        pinLabel.setEnabled(!Utils.getPrefs().getBoolean("ANONYMOUS", false));


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
                    Utils.getLogger().setLogLevel(Level.DEBUG);
                    Utils.getPrefs().putBoolean("DEBUG", true);
                } else {
                    Utils.getLogger().setLogLevel(Level.SEVERE);
                    Utils.getPrefs().putBoolean("DEBUG", false);
                }
            }
        });
        useDirectLinkICheckBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                if (useDirectLinkICheckBox.isSelected()) {
                    Utils.getPrefs().putBoolean("DIRECT-LINK", true);
                } else {
                    Utils.getPrefs().putBoolean("DIRECT-LINK", false);
                }
            }
        });
        openImagesInBrowserCheckBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                if (openImagesInBrowserCheckBox.isSelected()) {
                    Utils.getPrefs().putBoolean("OPEN-IMAGE", true);
                } else {
                    Utils.getPrefs().putBoolean("OPEN-IMAGE", false);
                }
            }
        });
        doNothingAfterUploadRadioButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                if (doNothingAfterUploadRadioButton.isSelected()) {
                    chooseDirectoryButton.setEnabled(false);
                    Utils.getPrefs().put("TIDY", "IGNORE");
                }
            }
        });
        deleteAfterUploadRadioButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                if (deleteAfterUploadRadioButton.isSelected()) {
                    chooseDirectoryButton.setEnabled(false);
                    Utils.getPrefs().put("TIDY", "DELETE");
                }
            }
        });
        moveAfterUploadRadioButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                if (moveAfterUploadRadioButton.isSelected()) {
                    chooseDirectoryButton.setEnabled(true);
                    Utils.getPrefs().put("TIDY", "MOVE");
                }
            }
        });
        chooseDirectoryButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                if (e.getSource() == chooseDirectoryButton) {
                    if (fileChooser.showOpenDialog(chooseDirectoryButton) == JFileChooser.APPROVE_OPTION) {
                        File file = fileChooser.getSelectedFile();
                        Utils.getPrefs().put("MOVE-DIR", file.getAbsolutePath() + "/");
                    } else {
                        Utils.getPrefs().put("TIDY", "IGNORE");
                    }
                }
            }
        });
        debugLoggingCheckBox.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                if (debugLoggingCheckBox.isSelected()) {
                    Utils.getLogger().setLogLevel(Level.DEBUG);
                    Utils.getPrefs().putBoolean("DEBUG-LOGGING", true);
                } else {
                    Utils.getLogger().setLogLevel(Level.SEVERE);
                    Utils.getPrefs().putBoolean("DEBUG-LOGGING", false);
                }
            }
        });
        chooseDirectoryButton1.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                if (fileChooser.showOpenDialog(chooseDirectoryButton1) == JFileChooser.APPROVE_OPTION) {
                    File file = fileChooser.getSelectedFile();
                    Utils.getPrefs().put("MONITOR-DIR", file.getAbsolutePath() + "/");
                    Utils.getLogger().debug("Will monitor: " + file.getAbsolutePath() + "/");
                    new PopupDialog("You must restart mac2imgur to apply this change!", JOptionPane.INFORMATION_MESSAGE);
                }
            }
        });
        resetToDefaultDirectoryButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                Utils.getPrefs().put("MONITOR-DIR", System.getProperty("user.home") + "/Desktop/");
                Utils.getLogger().debug("Will monitor: " + System.getProperty("user.home") + "/Desktop/");
            }

        });

        JPEGJPGCheckBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                Utils.getPrefs().putBoolean("JPG", JPEGJPGCheckBox.isSelected());
            }
        });
        GIFCheckBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                Utils.getPrefs().putBoolean("GIF", GIFCheckBox.isSelected());
            }
        });
        PNGCheckBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                Utils.getPrefs().putBoolean("png", PNGCheckBox.isSelected());
            }
        });
        APNGCheckBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                Utils.getPrefs().putBoolean("APNG", APNGCheckBox.isSelected());
            }
        });
        TIFFCheckBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                Utils.getPrefs().putBoolean("TIFF", TIFFCheckBox.isSelected());
            }
        });
        BMPCheckBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                Utils.getPrefs().putBoolean("BMP", BMPCheckBox.isSelected());
            }
        });
        PDFCheckBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                Utils.getPrefs().putBoolean("PDF", PDFCheckBox.isSelected());
            }
        });
        XCFCheckBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                Utils.getPrefs().putBoolean("XCF", XCFCheckBox.isSelected());
            }
        });

        anonymousUploadCheckBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e){
                boolean isSelected = anonymousUploadCheckBox.isSelected();
                Utils.getPrefs().putBoolean("ANONYMOUS", isSelected);

                openBrowserForAuthenticationButton.setEnabled(!isSelected);
            }
        });
        openBrowserForAuthenticationButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                Authorize.startBrowserForAuthorization();
                pinLabel.setEnabled(true);
                pinField.setEnabled(true);
                authorizeButton.setEnabled(true);
            }
        });
        authorizeButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String pin = pinField.getText();

                Authorize auth = new Authorize();
                try {
                    auth.makePinTokenRequest(pin);

                    if(auth.wasSuccessful()){
                        auth.saveRefreshToken();
                        new PopupDialog("Pairing done. Ready to go!", JOptionPane.INFORMATION_MESSAGE);
                    }
                } catch (Exception exc){
                    exc.printStackTrace();
                }
            }
        });

    }

    public static void open() {
        PreferencesGUI dialog = new PreferencesGUI();
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
        optionsPanel.setLayout(new GridLayoutManager(7, 1, new Insets(0, 0, 0, 0), -1, -1));
        tabbedPane.addTab("Options", optionsPanel);
        useDirectLinkICheckBox = new JCheckBox();
        useDirectLinkICheckBox.setText("Use direct link (i.imgur.com)");
        optionsPanel.add(useDirectLinkICheckBox, new GridConstraints(0, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        openImagesInBrowserCheckBox = new JCheckBox();
        openImagesInBrowserCheckBox.setText("Open images in browser");
        optionsPanel.add(openImagesInBrowserCheckBox, new GridConstraints(1, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        final JSeparator separator1 = new JSeparator();
        optionsPanel.add(separator1, new GridConstraints(2, 0, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_HORIZONTAL, GridConstraints.SIZEPOLICY_WANT_GROW, GridConstraints.SIZEPOLICY_WANT_GROW, null, null, null, 0, false));
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
        formatsPanel = new JPanel();
        formatsPanel.setLayout(new GridLayoutManager(8, 1, new Insets(0, 0, 0, 0), -1, -1));
        tabbedPane.addTab("Formats", formatsPanel);
        JPEGJPGCheckBox = new JCheckBox();
        JPEGJPGCheckBox.setText("JPEG / JPG");
        formatsPanel.add(JPEGJPGCheckBox, new GridConstraints(0, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        GIFCheckBox = new JCheckBox();
        GIFCheckBox.setText("GIF");
        formatsPanel.add(GIFCheckBox, new GridConstraints(1, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        PNGCheckBox = new JCheckBox();
        PNGCheckBox.setText("PNG");
        formatsPanel.add(PNGCheckBox, new GridConstraints(2, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        APNGCheckBox = new JCheckBox();
        APNGCheckBox.setText("APNG");
        formatsPanel.add(APNGCheckBox, new GridConstraints(3, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        TIFFCheckBox = new JCheckBox();
        TIFFCheckBox.setText("TIFF");
        formatsPanel.add(TIFFCheckBox, new GridConstraints(4, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        BMPCheckBox = new JCheckBox();
        BMPCheckBox.setText("BMP");
        formatsPanel.add(BMPCheckBox, new GridConstraints(5, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        PDFCheckBox = new JCheckBox();
        PDFCheckBox.setText("PDF");
        formatsPanel.add(PDFCheckBox, new GridConstraints(6, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        XCFCheckBox = new JCheckBox();
        XCFCheckBox.setText("XCF");
        formatsPanel.add(XCFCheckBox, new GridConstraints(7, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        advancedPanel = new JPanel();
        advancedPanel.setLayout(new GridLayoutManager(5, 1, new Insets(0, 0, 0, 0), -1, -1));
        tabbedPane.addTab("Advanced", advancedPanel);
        debugLoggingCheckBox = new JCheckBox();
        debugLoggingCheckBox.setText("Debug logging");
        advancedPanel.add(debugLoggingCheckBox, new GridConstraints(0, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
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

    private void createUIComponents() {
        // TODO: place custom component creation code here
    }
}
