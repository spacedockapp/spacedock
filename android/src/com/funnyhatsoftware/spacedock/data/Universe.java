
package com.funnyhatsoftware.spacedock.data;

import java.io.InputStream;
import java.util.ArrayList;

import android.content.Context;
import android.content.res.AssetManager;
import android.support.v4.util.ArrayMap;
import android.util.Log;

public class Universe {
    public ArrayMap<String, Ship> ships = new ArrayMap<String, Ship>();
    public ArrayMap<String, Captain> captains = new ArrayMap<String, Captain>();
    public ArrayMap<String, Upgrade> upgrades = new ArrayMap<String, Upgrade>();
    public ArrayMap<String, Resource> resources = new ArrayMap<String, Resource>();
    public ArrayMap<String, Flagship> flagships = new ArrayMap<String, Flagship>();
    public ArrayMap<String, Set> sets = new ArrayMap<String, Set>();
    public ArrayMap<String, Set> selectedSets = new ArrayMap<String, Set>();

    static Universe sUniverse;

    public static Universe getUniverse(Context context) {
        if (sUniverse == null) {
            // Debug.startMethodTracing();
            sUniverse = new Universe();
            AssetManager am = context.getAssets();
            try {
                InputStream is = am.open("data.xml");
                DataLoader loader = new DataLoader(sUniverse, is);
                loader.load();
            } catch (Exception e) {
                Log.e("spacedock", "Error while loading: " + e.toString());
            }
            // Debug.stopMethodTracing();
        }
        return sUniverse;
    }

    public static Universe getUniverse() {
        if (sUniverse == null) throw new IllegalStateException();
        return sUniverse;
    }

    public Captain getCaptain(String captainId) {
        return captains.get(captainId);
    }

    public Upgrade getUpgrade(String upgradeId) {
        return upgrades.get(upgradeId);
    }

    public Ship getShip(String shipId) {
        return ships.get(shipId);
    }

    public Resource getResource(String externalId) {
        return resources.get(externalId);
    }

    public Set getSet(String setId) {
        return sets.get(setId);
    }

    @SuppressWarnings("unchecked")
    public ArrayList<Set> getAllSets() {
        ArrayList<Set> setsCopy = new ArrayList<Set>();
        setsCopy.addAll(sets.values());
        return setsCopy;
    }

    @SuppressWarnings("unchecked")
    public ArrayList<Set> includedSets() {
        ArrayList<Set> selectedSetsCopy = new ArrayList<Set>();
        selectedSetsCopy.addAll(selectedSets.values());
        return selectedSetsCopy;
    }

    @SuppressWarnings("unchecked")
    public ArrayList<Ship> getShips() {
        ArrayList<Ship> shipsCopy = new ArrayList<Ship>();
        shipsCopy.addAll(ships.values());
        return shipsCopy;
    }
}
