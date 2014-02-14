
package com.funnyhatsoftware.spacedock.data;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;

import android.content.Context;
import android.content.res.AssetManager;
import android.support.v4.util.ArrayMap;
import android.util.Log;

public class Universe {
    public ArrayMap<String, Ship> ships = new ArrayMap<String, Ship>();
    public ArrayMap<String, ShipClassDetails> shipClassDetails = new ArrayMap<String, ShipClassDetails>();
    public ArrayMap<String, Captain> captains = new ArrayMap<String, Captain>();
    public ArrayMap<String, Upgrade> upgrades = new ArrayMap<String, Upgrade>();
    public ArrayMap<String, Resource> resources = new ArrayMap<String, Resource>();
    public ArrayMap<String, Flagship> flagships = new ArrayMap<String, Flagship>();
    public ArrayMap<String, Set> sets = new ArrayMap<String, Set>();
    public ArrayMap<String, Set> selectedSets = new ArrayMap<String, Set>();
    public ArrayMap<String, Upgrade> placeholders = new ArrayMap<String, Upgrade>();
    public ArrayList<Squad> squads = new ArrayList<Squad>();

    static Universe sUniverse;

    public static Universe getUniverse(Context context) throws ParserConfigurationException, SAXException, IOException {
        if (sUniverse == null) {
            Universe newUniverse = new Universe();
            AssetManager am = context.getAssets();
            InputStream is = am.open("data.xml");
            DataLoader loader = new DataLoader(newUniverse, is);
            loader.load();
            sUniverse = newUniverse;
        }
        return sUniverse;
    }

    public static Universe getUniverse() {
        if (sUniverse == null)
            throw new IllegalStateException();
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

    public ArrayList<Set> getAllSets() {
        ArrayList<Set> setsCopy = new ArrayList<Set>();
        setsCopy.addAll(sets.values());
        return setsCopy;
    }

    public ArrayList<Set> includedSets() {
        ArrayList<Set> selectedSetsCopy = new ArrayList<Set>();
        selectedSetsCopy.addAll(selectedSets.values());
        return selectedSetsCopy;
    }

    public ArrayList<Ship> getShips() {
        ArrayList<Ship> shipsCopy = new ArrayList<Ship>();
        shipsCopy.addAll(ships.values());
        return shipsCopy;
    }

    public Upgrade findOrCreatePlaceholder(String upType) {
        Upgrade placeholder = placeholders.get(upType);
        if (placeholder == null) {
            if (upType.equals("Weapon")) {
                placeholder = new Weapon();
            } else if (upType.equals("Tech")) {
                placeholder = new Tech();
            } else if (upType.equals("Talent")) {
                placeholder = new Talent();
            } else if (upType.equals("Captain")) {
                placeholder = new Captain();
            } else if (upType.equals("Crew")) {
                placeholder = new Crew();
            }

            placeholder.setTitle(upType);
            placeholder.setUpType(upType);
            placeholder.setPlaceholder(true);
            placeholders.put(upType, placeholder);
        }
        return placeholder;
    }

    public Flagship getFlagship(String flagshipId) {
        return flagships.get(flagshipId);
    }
}
