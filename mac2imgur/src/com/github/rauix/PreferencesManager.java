package com.github.rauix;

import java.util.prefs.Preferences;

public class PreferencesManager {
	
	public static Preferences getPreferences(){
		Preferences prefs = Preferences.userRoot().node(PreferencesManager.class.getClass().getName());
		return prefs;
	}

}
