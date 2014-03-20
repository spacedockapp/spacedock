package com.funnyhatsoftware.spacedock.activity;

import android.os.Bundle;
import android.preference.PreferenceActivity;

import com.funnyhatsoftware.spacedock.R;

public class SettingsActivity extends PreferenceActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //noinspection deprecation
        addPreferencesFromResource(R.xml.preferences);
    }
}