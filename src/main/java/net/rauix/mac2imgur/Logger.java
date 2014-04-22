package net.rauix.mac2imgur;

import java.io.*;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class Logger {

    private File logFile;
    private Level logLevel;

    public Logger(Level logLevel, File logFile) {
        this.setFilePath(logFile);
        this.setLogLevel(logLevel);
    }

    public Logger(Level logLevel) {
        this.setLogLevel(logLevel);
        this.setFilePath(null);
    }

    public Logger(File logFile) {
        this.setLogLevel(Level.DEBUG);
        this.logFile = logFile;
    }

    public Logger() {
        this.setLogLevel(Level.DEBUG);
        this.setFilePath(null);
    }

    // Setters and Getters

    public File getFilePath() {
        return logFile;
    }

    public void setFilePath(File logFile) {
        this.logFile = logFile;
    }

    public Level getLogLevel() {
        return logLevel;
    }

    public void setLogLevel(Level logLevel) {
        this.logLevel = logLevel;
    }

    // Logging methods

    public void debug(String message) {
        Log(Level.DEBUG, message, null);
    }

    public void debug(Exception exception) {
        Log(Level.DEBUG, null, exception);
    }

    public void info(String message) {
        Log(Level.INFO, message, null);
    }

    public void info(Exception exception) {
        Log(Level.INFO, null, exception);
    }

    public void warning(String message) {
        Log(Level.WARNING, message, null);
    }

    public void warning(Exception exception) {
        Log(Level.WARNING, null, exception);
    }

    public void severe(String message) {
        Log(Level.SEVERE, message, null);
    }

    public void severe(Exception exception) {
        Log(Level.SEVERE, null, exception);
    }

    private void Log(Level Level, String message, Exception exception) {

        DateFormat sdf = new SimpleDateFormat("MM/dd/yy HH:mm:ss");
        Date now = Calendar.getInstance().getTime();
        String prefix = "[" + sdf.format(now) + "] [" + Level + "] ";

        // Ignore messages below the logger Level
        if (Level.getValue() >= this.logLevel.getValue()) {
            if (message != null) {
                System.out.println(prefix + message);
                if (logFile != null) {
                    try {
                        PrintWriter ps = new PrintWriter(new BufferedWriter(new FileWriter(logFile, true)));
                        ps.println(prefix + message);
                        ps.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            } else if (exception != null) {
                System.out.print(prefix);
                exception.printStackTrace(System.out);
                if (logFile != null) {
                    try {
                        PrintWriter ps = new PrintWriter(new BufferedWriter(new FileWriter(logFile, true)));
                        ps.print(prefix);
                        exception.printStackTrace(ps);
                        ps.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
}

enum Level {

    DEBUG(1), INFO(2), WARNING(3), SEVERE(4);

    private int value;

    Level(int value) {
        this.value = value;
    }

    public int getValue() {
        return value;
    }

}