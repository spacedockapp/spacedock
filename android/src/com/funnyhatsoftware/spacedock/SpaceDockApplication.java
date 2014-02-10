package com.funnyhatsoftware.spacedock;

import android.app.Application;

import com.funnyhatsoftware.spacedock.data.Universe;

public class SpaceDockApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        Universe.getUniverse(getApplicationContext());
    }
}
