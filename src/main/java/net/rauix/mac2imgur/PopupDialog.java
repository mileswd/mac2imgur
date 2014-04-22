package net.rauix.mac2imgur;

import javax.swing.*;

public class PopupDialog {

    public PopupDialog(String msg, int type) {
        JOptionPane.showMessageDialog(null, msg, "mac2imgur", type);
    }

}
