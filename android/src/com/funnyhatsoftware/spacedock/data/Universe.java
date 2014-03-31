
package com.funnyhatsoftware.spacedock.data;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.TreeSet;

import javax.xml.parsers.ParserConfigurationException;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;
import org.xml.sax.SAXException;

import android.content.Context;
import android.content.res.AssetManager;
import android.os.Environment;
import android.support.v4.util.ArrayMap;

import com.funnyhatsoftware.spacedock.data.Captain.CaptainComparator;
import com.funnyhatsoftware.spacedock.data.Flagship.FlagshipComparator;
import com.funnyhatsoftware.spacedock.data.Resource.ResourceComparator;
import com.funnyhatsoftware.spacedock.data.Set.SetComparator;
import com.funnyhatsoftware.spacedock.data.Ship.ShipComparator;
import com.funnyhatsoftware.spacedock.data.Upgrade.UpgradeComparitor;

public class Universe {
    private static final String SQUADS_FILE_NAME = "squads.spacedocksquads";

    ArrayMap<String, Ship> ships = new ArrayMap<String, Ship>();
    public ArrayMap<String, ShipClassDetails> shipClassDetails = new ArrayMap<String, ShipClassDetails>();
    public ArrayMap<String, ShipClassDetails> shipClassDetailsByName = new ArrayMap<String, ShipClassDetails>();
    public ArrayMap<String, Captain> captains = new ArrayMap<String, Captain>();
    public ArrayMap<String, Upgrade> upgrades = new ArrayMap<String, Upgrade>();
    public ArrayMap<String, Resource> resources = new ArrayMap<String, Resource>();
    public ArrayMap<String, Flagship> flagships = new ArrayMap<String, Flagship>();
    public ArrayMap<String, Set> sets = new ArrayMap<String, Set>();
    private java.util.Set<Set> mIncludedSets = new HashSet<Set>();
    public ArrayMap<String, Upgrade> placeholders = new ArrayMap<String, Upgrade>();
    private ArrayList<Squad> mSquads = new ArrayList<Squad>();
    private ArrayList<String> mAllFactions;
    private String mSelectedFaction;

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

    public JSONArray allSquadsAsJSON() throws JSONException {
        JSONArray squadsArray = new JSONArray();
        int index = 0;
        for (Squad squad : mSquads) {
            JSONObject squadAsJSON = squad.asJSON();
            squadsArray.put(index++, squadAsJSON);
        }
        return squadsArray;
    }

    private File getAllSquadsSaveFile(File filesDir) {
        return new File(filesDir, SQUADS_FILE_NAME);
    }

    public void save(Context context) throws JSONException, IOException {
        File filesDir = context.getFilesDir();
        File file = getAllSquadsSaveFile(filesDir);
        FileOutputStream outputStream = new FileOutputStream(file);
        JSONArray allSquads = allSquadsAsJSON();
        String jsonString = allSquads.toString();
        outputStream.write(jsonString.getBytes());
        outputStream.close();
    }

    public boolean restore(Context context) throws FileNotFoundException, JSONException {
        boolean worked = true;
        File filesDir = context.getFilesDir();
        File allSquadsFile = getAllSquadsSaveFile(filesDir);
        try {
            FileInputStream inputStream = new FileInputStream(allSquadsFile);
            loadSquadsFromStream(inputStream);
            inputStream.close();
        } catch (Exception e) {
            worked = false;
        }
        
        if (!worked) {
            File stashDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
            File brokenFile = new File(stashDir, "broken.spacedocksquads");
            allSquadsFile.renameTo(brokenFile);
        }
        return worked;
    }

    public void loadSquadsFromStream(InputStream is) throws JSONException {
        String savedJSON = DataUtils.convertStreamToString(is);

        JSONTokener tokenizer = new JSONTokener(savedJSON);
        JSONArray jsonArray = new JSONArray(tokenizer);
        int count = jsonArray.length();
        for (int i = 0; i < count; ++i) {
            JSONObject oneSquad = jsonArray.getJSONObject(i);
            Squad squad = new Squad();
            squad.importFromObject(this, false, oneSquad);
            mSquads.add(squad);
        }
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
        for (Resource resource : resources.values()) {
            if (isMemberOfIncludedSet(resource)) {
                resourcesCopy.add(resource);
            }
        }
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

    public void includeAllSets() {
        mIncludedSets.clear();
        mIncludedSets.addAll(sets.values());
    }

    public void includeSetsByName(java.util.Set<String> setNames) {
        mIncludedSets.clear();
        for (Set s : sets.values()) {
            if (setNames.contains(s.getProductName())) {
                mIncludedSets.add(s);
            }
        }
    }

    private boolean isMemberOfIncludedSet(SetItem item) {
        for (Set set : item.getSets()) {
            if (mIncludedSets.contains(set)) {
                return true;
            }
        }
        return false;
    }

    public void addShip(Ship ship) {
        ships.put(ship.getExternalId(), ship);
    }

    public ArrayList<Ship> getShips() {
        ArrayList<Ship> shipsCopy = new ArrayList<Ship>();
        for (Ship ship : ships.values()) {
            if (isMemberOfIncludedSet(ship)) {
                shipsCopy.add(ship);
            }
        }
        return shipsCopy;
    }

    public ArrayList<Ship> getShipsForFaction(String faction) {
        ArrayList<Ship> shipsCopy = new ArrayList<Ship>();
        for (Ship ship : ships.values()) {
            if (ship.getFaction().equals(faction) && isMemberOfIncludedSet(ship)) {
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
            } else {
                return null; // placeholder type not supported
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
            if (captain.getFaction().equals(s) && isMemberOfIncludedSet(captain)) {
                factionCaptains.add(captain);
            }
        }

        Collections.sort(factionCaptains, new CaptainComparator());
        return factionCaptains;
    }

    public ArrayList<Upgrade> getUpgradesForFaction(String upType, String faction) {
        if (faction == null)
            throw new IllegalArgumentException();

        ArrayList<Upgrade> matchingUpgrades = new ArrayList<Upgrade>();
        for (Upgrade upgrade : upgrades.values()) {
            if (!isMemberOfIncludedSet(upgrade)) {
                continue;
            }
            if ((upType == null || upgrade.getUpType().equals(upType))
                    && faction.equals(upgrade.getFaction())) {
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
        for (Flagship fs : flagships.values()) {
            if (faction.equals(fs.getFaction()) && isMemberOfIncludedSet(fs)) {
                matchingFlagships.add(fs);
            }
        }
        Collections.sort(matchingFlagships, new FlagshipComparator());
        return matchingFlagships;
    }

    public ArrayList<Set> getSets() {
        ArrayList<Set> setsCopy = new ArrayList<Set>();
        setsCopy.addAll(sets.values());
        Collections.sort(setsCopy, new SetComparator());
        return setsCopy;
    }

    public List<String> getSelectedFactions() {
        if (mSelectedFaction == null) {
            return getAllFactions();
        }
        ArrayList<String> l = new ArrayList<String>();
        l.add(mSelectedFaction);
        return l;
    }

    public void setSelectedFaction(String faction) {
        mSelectedFaction = faction;
    }

    public Squad getSquad(int squadIndex) {
        return mSquads.get(squadIndex);
    }

    public void addSquad(Squad squad) {
        mSquads.add(squad);
    }

    public ArrayList<Squad> getAllSquads() {
        return mSquads;
    }

    public void removeAllSquads() {
        mSquads.clear();
    }

}
