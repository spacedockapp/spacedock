
package com.funnyhatsoftware.spacedock.data;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.TreeSet;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;

import android.content.Context;
import android.content.res.AssetManager;
import android.support.v4.util.ArrayMap;

import com.funnyhatsoftware.spacedock.data.Captain.CaptainComparator;
import com.funnyhatsoftware.spacedock.data.Flagship.FlagshipComparator;
import com.funnyhatsoftware.spacedock.data.Resource.ResourceComparator;
import com.funnyhatsoftware.spacedock.data.Ship.ShipComparator;
import com.funnyhatsoftware.spacedock.data.Upgrade.UpgradeComparitor;

public class Universe {
    public ArrayMap<String, Ship> ships = new ArrayMap<String, Ship>();
    public ArrayMap<String, ShipClassDetails> shipClassDetails = new ArrayMap<String, ShipClassDetails>();
    public ArrayMap<String, ShipClassDetails> shipClassDetailsByName = new ArrayMap<String, ShipClassDetails>();
    public ArrayMap<String, Captain> captains = new ArrayMap<String, Captain>();
    public ArrayMap<String, Upgrade> upgrades = new ArrayMap<String, Upgrade>();
    public ArrayMap<String, Resource> resources = new ArrayMap<String, Resource>();
    public ArrayMap<String, Flagship> flagships = new ArrayMap<String, Flagship>();
    public ArrayMap<String, Set> sets = new ArrayMap<String, Set>();
    public ArrayMap<String, Set> selectedSets = new ArrayMap<String, Set>();
    public ArrayMap<String, Upgrade> placeholders = new ArrayMap<String, Upgrade>();
    public ArrayList<Squad> squads = new ArrayList<Squad>();
    private ArrayList<String> mAllFactions;

    static Universe sUniverse;

    public static Universe getUniverse(Context context) throws ParserConfigurationException,
            SAXException, IOException {
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

    public ArrayList<Resource> getResources() {
        ArrayList<Resource> resourcesCopy = new ArrayList<Resource>();
        resourcesCopy.addAll(resources.values());
        Collections.sort(resourcesCopy, new ResourceComparator());
        return resourcesCopy;
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

    public ArrayList<Ship> getShipsForFaction(String faction) {
        ArrayList<Ship> shipsCopy = new ArrayList<Ship>();
        for (Ship ship : ships.values()) {
            if (ship.getFaction().equals(faction)) {
                shipsCopy.add(ship);
            }
        }
        
        Collections.sort(shipsCopy, new ShipComparator());
        return shipsCopy;
    }

    public ArrayList<Captain> getCaptains() {
        ArrayList<Captain> captainsCopy = new ArrayList<Captain>();
        captainsCopy.addAll(captains.values());
        return captainsCopy;
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

    public void addShipClassDetails(ShipClassDetails details) {
        shipClassDetails.put(details.getExternalId(), details);
        shipClassDetailsByName.put(details.getName(), details);
    }

    public ShipClassDetails getShipClassDetailsByName(String shipClass) {
        return shipClassDetailsByName.get(shipClass);
    }

    public ArrayList<String> getAllFactions() {
        if (mAllFactions == null) {
            TreeSet<String> factions = new TreeSet<String>();

            for (Ship ship : ships.values()) {
                factions.add(ship.getFaction());
            }
            
            mAllFactions = new ArrayList<String>();
            mAllFactions.addAll(factions);
        }
        return mAllFactions;
    }

    public ArrayList<Captain> getCaptainsForFaction(String s) {
        ArrayList<Captain> factionCaptains = new ArrayList<Captain>();
        for (Captain captain : captains.values()) {
            if (captain.getFaction().equals(s)) {
                factionCaptains.add(captain);
            }
        }
        
        Collections.sort(factionCaptains, new CaptainComparator());
        return factionCaptains;
    }

    public ArrayList<Upgrade> getUpgradesForFaction(String upType, String faction) {
        ArrayList<Upgrade> matchingUpgrades = new ArrayList<Upgrade>();
        for (Upgrade upgrade: upgrades.values()) {
            if ((upType == null || upgrade.getUpType().equals(upType)) && faction.equals(upgrade.getFaction())) {
                matchingUpgrades.add(upgrade);
            }
        }
        Collections.sort(matchingUpgrades, new UpgradeComparitor());
        return matchingUpgrades;
    }

    public ArrayList<Upgrade> getCrewForFaction(String faction) {
        return getUpgradesForFaction("Crew", faction);
    }

    public ArrayList<Upgrade> getTalentsForFaction(String faction) {
        return getUpgradesForFaction("Talent", faction);
    }

    public ArrayList<Flagship> getFlagshipsForFaction(String faction) {
        ArrayList<Flagship> matchingFlagships = new ArrayList<Flagship>();
        for (Flagship fs: flagships.values()) {
            if (faction.equals(fs.getFaction())) {
                matchingFlagships.add(fs);
            }
        }
        Collections.sort(matchingFlagships, new FlagshipComparator());
        return matchingFlagships;
    }


}
