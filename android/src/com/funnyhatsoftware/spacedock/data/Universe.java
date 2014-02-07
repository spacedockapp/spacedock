package com.funnyhatsoftware.spacedock.data;

import java.io.InputStream;
import java.util.HashMap;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

public class Universe {
	public HashMap<String, Ship> ships = new HashMap<String, Ship>();
	public HashMap<String, Captain> captains = new HashMap<String, Captain>();

	static Universe sUniverse;

	public static Universe getUniverse(Context context) {
		if (sUniverse == null) {
			//Debug.startMethodTracing();
			sUniverse = new Universe();
			AssetManager am = context.getAssets();
			try {
				InputStream is = am.open("data.xml");
				DataLoader loader = new DataLoader(sUniverse, is);
				loader.load();
			} catch (Exception e) {
				Log.e("spacedock", "Error while loading: " + e.toString());
			}
			//Debug.stopMethodTracing();
		}
		return sUniverse;
	}

}
