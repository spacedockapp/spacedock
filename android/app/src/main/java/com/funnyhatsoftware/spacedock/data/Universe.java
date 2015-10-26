package com.funnyhatsoftware.spacedock.data;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.res.AssetManager;
import android.os.AsyncTask;
import android.os.Environment;
import android.support.v4.util.ArrayMap;
import android.util.Log;

import com.funnyhatsoftware.spacedock.activity.RootTabActivity;
import com.funnyhatsoftware.spacedock.data.Captain.CaptainComparator;
import com.funnyhatsoftware.spacedock.data.Flagship.FlagshipComparator;
import com.funnyhatsoftware.spacedock.data.FleetCaptain.FleetCaptainComparator;
import com.funnyhatsoftware.spacedock.data.Reference.ReferenceComparator;
import com.funnyhatsoftware.spacedock.data.Resource.ResourceComparator;
import com.funnyhatsoftware.spacedock.data.Set.SetComparator;
import com.funnyhatsoftware.spacedock.data.Ship.ShipComparator;
import com.funnyhatsoftware.spacedock.data.Squad.SquadComparator;
import com.funnyhatsoftware.spacedock.data.Upgrade.UpgradeComparitor;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;
import org.xml.sax.SAXException;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;

import javax.xml.parsers.ParserConfigurationException;

public class Universe {
    private static final String SQUADS_FILE_NAME = "squads.spacedocksquads";

    ArrayMap<String, Ship> ships = new ArrayMap<String, Ship>();
    ArrayMap<String, ShipClassDetails> shipClassDetails = new ArrayMap<String, ShipClassDetails>();
    ArrayMap<String, ShipClassDetails> shipClassDetailsByName = new ArrayMap<String, ShipClassDetails>();

    ArrayMap<String, Set> sets = new ArrayMap<String, Set>();

    // set item maps
    ArrayMap<String, Admiral> admirals = new ArrayMap<String, Admiral>();
    ArrayMap<String, Captain> captains = new ArrayMap<String, Captain>();
    ArrayMap<String, FleetCaptain> fleetCaptains = new ArrayMap<String, FleetCaptain>();
    ArrayMap<String, Upgrade> upgrades = new ArrayMap<String, Upgrade>();
    ArrayMap<String, Resource> resources = new ArrayMap<String, Resource>();
    ArrayMap<String, Flagship> flagships = new ArrayMap<String, Flagship>();
    private ArrayMap<String, Officer> mOfficers = new ArrayMap<String, Officer>();
    ArrayMap<String, Reference> referenceItems = new ArrayMap<String, Reference>();

    // map of all set item maps
    ArrayMap<String, ArrayMap<String, ? extends SetItem>> mSetItemMaps
            = new ArrayMap<String, ArrayMap<String, ? extends SetItem>>();

    final ArrayMap<String, Upgrade> placeholders = new ArrayMap<String, Upgrade>();
    private java.util.Set<Set> mIncludedSets = new HashSet<Set>();
    private ArrayList<Squad> mSquads = new ArrayList<Squad>();
    private ArrayList<String> mAllFactions;
    private String mSelectedFaction;
    private Ship mShipPlaceholder;
    private Flagship mFlagshipPlaceholder;
    private Admiral mAdmiralPlaceholder;
    private FleetCaptain mFleetCaptainPlaceholder;

    public boolean updateAvailable;

    static Universe sUniverse;
    static String sVersion;

    private class DownloadUpdate extends AsyncTask<String,String,String> {
        private String mVersion;
        public Activity activity;
        public Context context;
        ProgressDialog pd;
        @Override
        protected String doInBackground(String... strings) {
            try {
                File dataDir = context.getFilesDir();
                File newData = new File(dataDir + "/new-data.xml");

                URL url = new URL("http://spacedockapp.org/Data.xml");
                URLConnection urlConnection = url.openConnection();
                int fileSize = urlConnection.getContentLength();
                InputStream in = new BufferedInputStream(urlConnection.getInputStream());
                FileOutputStream fileStream = new FileOutputStream(newData);
                OutputStream out = new BufferedOutputStream(fileStream);
                byte[] buffer = new byte[1024];
                int read;

                while ((read = in.read(buffer)) != -1) {
                    out.write(buffer,0,read);
                }
                out.flush();
                out.close();
            } catch (MalformedURLException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
            return null;
        }

        @Override
        protected void onPreExecute() {
            if (activity != null) {
                pd = new ProgressDialog(activity);
                pd.setMessage("Loading Updated Game Data");
                pd.show();
            }
        }

        @Override
        protected void onCancelled() {
            pd.dismiss();
            super.onCancelled();
        }

        @Override
        protected void onPostExecute(String s) {
            super.onPostExecute(s);
            File dataDir = context.getFilesDir();
            File newData = new File(dataDir + "/new-data.xml");
            File newDataXML = new File(dataDir + "/data.xml");

            try {
                InputStream in = new FileInputStream(newData);
                DataLoader loader = new DataLoader(sUniverse, in);
                loader.load();
                sVersion = loader.dataVersion;
                updateAvailable = false;
            } catch (SAXException e) {
                e.printStackTrace();
            } catch (ParserConfigurationException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
            if (newDataXML.exists()) {
                newDataXML.delete();
            }
            if (activity != null) {
                if (activity.getClass().equals(RootTabActivity.class)) {
                    RootTabActivity act = (RootTabActivity)activity;
                    act.checkForUpdates(true);
                }
            }
            if (pd != null) {
                pd.dismiss();
            }
            newData.renameTo(newDataXML);
        }
    }

    public static Universe getUniverse(Context context) throws ParserConfigurationException,
            SAXException, IOException {
        if (sUniverse == null) {
            String version;
            Universe newUniverse = new Universe();
            AssetManager am = context.getAssets();
            InputStream is = am.open("data.xml");
            DataLoader loader = new DataLoader(newUniverse, is);
            loader.load();
            version = loader.dataVersion;
            sVersion = version;
            sUniverse = newUniverse;
            File dataDir = context.getFilesDir();
            File newData = new File(dataDir + "/data.xml");
            if (newData.exists()) {
                is = new FileInputStream(newData);
                loader = new DataLoader(newUniverse, is);
                loader.load();
                if (loader.dataVersion.compareTo(version) > 0) {
                    sVersion = loader.dataVersion;
                    sUniverse = newUniverse;
                } else {
                    newData.delete();
                    is = am.open("data.xml");
                    loader = new DataLoader(newUniverse, is);
                    loader.load();
                }
            }
        }
        return sUniverse;
    }

    public String getVersion() {
        return sVersion;
    }

    public void installUpdate(Context context, Activity activity) {
        DownloadUpdate downloadUpdate = new DownloadUpdate();
        downloadUpdate.activity = activity;
        downloadUpdate.context = context;
        downloadUpdate.execute();
    }

    public Universe() {
        mSetItemMaps.put("Admirals", admirals);
        mSetItemMaps.put("Captains", captains);
        mSetItemMaps.put("Fleet Captains", fleetCaptains);
        mSetItemMaps.put("Upgrades", upgrades);
        mSetItemMaps.put("Resources", resources);
        mSetItemMaps.put("Flagships", flagships);
        mSetItemMaps.put("Reference Items", referenceItems);
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

    public void save(Context context, File targetFile) throws JSONException, IOException {
        FileOutputStream outputStream = new FileOutputStream(targetFile);
        JSONArray allSquads = allSquadsAsJSON();
        String jsonString = allSquads.toString();
        outputStream.write(jsonString.getBytes());
        outputStream.close();
    }

    public void save(Context context) throws JSONException, IOException {
        File filesDir = context.getFilesDir();
        File file = getAllSquadsSaveFile(filesDir);
        save(context, file);
    }

    public boolean restore(Context context) throws FileNotFoundException, JSONException {
        boolean worked = true;
        File filesDir = context.getFilesDir();
        File allSquadsFile = getAllSquadsSaveFile(filesDir);
        try {
            FileInputStream inputStream = new FileInputStream(allSquadsFile);
            loadSquadsFromStream(inputStream, false);
            inputStream.close();
        } catch (Exception e) {
            worked = false;
            Log.e("spacedock","Error loading data:" + e.getMessage());
        }

        if (!worked) {
            File stashDir = Environment
                    .getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
            File brokenFile = new File(stashDir, "broken.spacedocksquads");
            if(!allSquadsFile.renameTo(brokenFile)) {
                File sharedSquads = new File(context.getFilesDir(), "shared_squads");
                brokenFile = new File(sharedSquads, "broken.spacedocksquads");
                InputStream in = new FileInputStream(allSquadsFile);
                OutputStream out = new FileOutputStream(brokenFile);
                byte[] buf = new byte[1024];
                int len;
                try {
                    while ((len = in.read(buf)) > 0) {
                        out.write(buf, 0, len);
                    }
                    in.close();
                    out.close();
                } catch (Exception e) {
                    allSquadsFile.renameTo(brokenFile);
                    Log.e("spacedock", "Could not copy bad squads, had to rename it.");
                }
            }
            Log.e("spacedock", "Renamed file to" + brokenFile.getAbsolutePath());
        }
        Collections.sort(mSquads, new SquadComparator());
        return worked;
    }

    public void loadSquadsFromStream(InputStream is, boolean strict) throws JSONException {
        String savedJSON = DataUtils.convertStreamToString(is);

        JSONTokener tokenizer = new JSONTokener(savedJSON);
        JSONArray jsonArray = new JSONArray(tokenizer);
        int count = jsonArray.length();
        for (int i = 0; i < count; ++i) {
            JSONObject oneSquad = jsonArray.getJSONObject(i);
            String squadUUID = oneSquad.optString("uuid");

            Squad squad = null;
            if (squadUUID.length() > 0) {
                squad = getSquadByUUID(squadUUID);
            }

            if (squad == null) {
                squad = new Squad();
                mSquads.add(squad);
            }
            squad.importFromObject(this, false, oneSquad, strict);
        }

    }

    public static Universe getUniverse() {
        if (sUniverse == null)
            throw new IllegalStateException();
        return sUniverse;
    }

    public Admiral getOrCreateAdmiralPlaceholder() {
        Admiral placeholder = mAdmiralPlaceholder;
        if (placeholder == null) {
            placeholder = new Admiral();
            placeholder.setTitle("");
            placeholder.setPlaceholder(true);
            mAdmiralPlaceholder = placeholder;
        }
        return placeholder;
    }

    public Admiral getAdmiral(String admiralId) {
        return admirals.get(admiralId);
    }

    public Captain getCaptain(String captainId) {
        return captains.get(captainId);
    }

    public Upgrade getUpgrade(String upgradeId) {
        return upgrades.get(upgradeId);
    }

    public Upgrade getUpgradeLikeItem(String upgradeId) {
        Upgrade maybeAdmiral = admirals.get(upgradeId);
        if (maybeAdmiral != null) {
            return maybeAdmiral;
        }
        Upgrade maybeFleetCaptain = fleetCaptains.get(upgradeId);
        if (maybeFleetCaptain != null) {
            return maybeFleetCaptain;
        }
        Upgrade maybeOfficer = mOfficers.get(upgradeId);
        if (maybeOfficer != null) {
            return maybeOfficer;
        }
        Upgrade maybeCaptain = captains.get(upgradeId);
        if (maybeCaptain != null) {
            return maybeCaptain;
        }
        return getUpgrade(upgradeId);
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
        return new ArrayList<Set>(sets.values());
    }

    public java.util.Set<String> getAllSetIds() {
        return new HashSet<String>(sets.keySet());
    }

    public String getSetChangeString(java.util.Set<String> prevSeenIds) {
        java.util.Set<String> newSetIds = new HashSet<String>();

        for (String availableSetId : sets.keySet()) {
            if (!prevSeenIds.contains(availableSetId)) {
                // unseen set, add to string
                newSetIds.add(availableSetId);
            }
        }

        String firstSetName = null;
        for (String newSetId : newSetIds) {
            String newSetName = getSet(newSetId).getProductName();

            if (firstSetName == null) {
                firstSetName = newSetName;
            } else if (newSetIds.size() == 2) {
                return firstSetName + " and " + newSetName;
            } else {
                return firstSetName + " and " + (newSetIds.size() - 1) + "other expansions";
            }
        }

        // Note: we'll just return null here if we can't find any new sets.
        return firstSetName;
    }

    public Map<String, List<SetItem>> getItemsForSet(String setId) {
        Set targetSet = getSet(setId);
        final ArrayMap<String, List<SetItem>> itemsForSet
                = new ArrayMap<String, List<SetItem>>();

        for (String setItemType : mSetItemMaps.keySet()) {
            Map<String, ? extends SetItem> currentMap = mSetItemMaps.get(setItemType);
            for (SetItem item : currentMap.values()) {
                if (item.isInSet(targetSet)) {
                    String typeName = setItemType;
                    if (currentMap == upgrades) {
                        typeName = ((Upgrade) item).getUpType();
                    }

                    List<SetItem> itemsOfType = itemsForSet.get(typeName);
                    if (itemsOfType == null) {
                        itemsOfType = new ArrayList<SetItem>();
                        itemsForSet.put(typeName, itemsOfType);
                    }
                    itemsOfType.add(item);
                }
            }
        }
        return itemsForSet;
    }


    /**
     * Builds a new java.util.Set of selected set ids, adding unseen Sets to the
     * previous selection
     */
    public java.util.Set<String> getSetSelectionPlusNewSets(java.util.Set<String> prevSetIds,
                                                            java.util.Set<String> prevSeenIds) {
        java.util.Set<String> newSetIds = new HashSet<String>();

        // Previously selected, still valid Sets (setsInUniverse &
        // prev_setSelection)
        for (String prevSetId : prevSetIds) {
            if (sets.containsKey(prevSetId)) {
                // previous, valid set, add
                newSetIds.add(prevSetId);
            }
        }

        // Previously unseen Sets (setsInUniverse - previouslySeen)
        for (String setId : sets.keySet()) {
            if (!prevSeenIds.contains(setId)) {
                // new set, add
                newSetIds.add(setId);
            }
        }
        return newSetIds;
    }

    public void includeAllSets() {
        mIncludedSets.clear();
        mIncludedSets.addAll(sets.values());
    }

    public void includeSetsById(java.util.Set<String> setIds) {
        mIncludedSets.clear();
        for (Set s : sets.values()) {
            if (setIds.contains(s.getExternalId())) {
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
            if ((ship.getFaction().equals(faction) || faction.equals(ship.getAdditionalFaction()))
                    && isMemberOfIncludedSet(ship)) {
                shipsCopy.add(ship);
            }
        }

        Collections.sort(shipsCopy, new ShipComparator());
        return shipsCopy;
    }

    public ArrayList<Admiral> getAdmirals() {
        ArrayList<Admiral> admiralsCopy = new ArrayList<Admiral>();
        admiralsCopy.addAll(admirals.values());
        return admiralsCopy;
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
            } else if (upType.equals("Borg")) {
                placeholder = new Borg();
            } else if (upType.equals("Talent")) {
                placeholder = new Talent();
            } else if (upType.equals("Captain")) {
                placeholder = new Captain();
            } else if (upType.equals("Crew")) {
                placeholder = new Crew();
            } else if (upType.equals("Admiral")) {
                placeholder = new Admiral();
            } else if (upType.equals("Squadron")) {
                placeholder = new Squadron();
            } else if (upType.equals("Officer")) {
                placeholder = new Officer();
            } else {
                return null; // placeholder type not supported
            }

            placeholder.update(new HashMap<String, Object>());
            placeholder.setTitle(upType);
            placeholder.setUpType(upType);
            placeholder.setPlaceholder(true);
            placeholders.put(upType, placeholder);
        }
        return placeholder;
    }

    public Ship getOrCreateShipPlaceholder() {
        Ship placeholder = mShipPlaceholder;
        if (placeholder == null) {
            placeholder = new Ship();
            placeholder.setTitle("");
            placeholder.setIsPlaceholder(true);
            mShipPlaceholder = placeholder;
        }
        return placeholder;
    }

    public Flagship getOrCreateFlagshipPlaceholder() {
        Flagship placeholder = mFlagshipPlaceholder;
        if (placeholder == null) {
            placeholder = new Flagship();
            placeholder.setTitle("");
            placeholder.setIsPlaceholder(true);
            mFlagshipPlaceholder = placeholder;
        }
        return placeholder;
    }

    public Flagship getFlagship(String flagshipId) {
        return flagships.get(flagshipId);
    }

    public FleetCaptain getOrCreateFleetCaptainPlaceholder() {
        FleetCaptain placeholder = mFleetCaptainPlaceholder;
        if (placeholder == null) {
            placeholder = new FleetCaptain();
            placeholder.setTitle("");
            placeholder.setIsPlaceholder(true);
            mFleetCaptainPlaceholder = placeholder;
        }
        return placeholder;
    }

    public FleetCaptain getFleetCaptain(String fleetCaptainId) {
        return fleetCaptains.get(fleetCaptainId);
    }

    public Officer getOfficer(String officerId) {
        return mOfficers.get(officerId);
    }

    public void putOfficer(String officerId, Officer officer) {
        mOfficers.put(officerId, officer);
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

            for (Captain captain : captains.values()) {
                factions.add(captain.getFaction());
            }

            mAllFactions = new ArrayList<String>();
            mAllFactions.addAll(factions);
        }
        return mAllFactions;
    }

    public ArrayList<Admiral> getAdmiralsForFaction(String s) {
        ArrayList<Admiral> factionAdmirals = new ArrayList<Admiral>();
        for (Admiral admiral : admirals.values()) {
            if (admiral.getFaction().equals(s) && isMemberOfIncludedSet(admiral)) {
                factionAdmirals.add(admiral);
            }
        }

        Collections.sort(factionAdmirals, new CaptainComparator());
        return factionAdmirals;
    }

    public ArrayList<Captain> getCaptainsForFaction(String s) {
        ArrayList<Captain> factionCaptains = new ArrayList<Captain>();
        for (Captain captain : captains.values()) {
            if ((captain.getFaction().equals(s) || captain.getAdditionalFaction().equals(s))
                    && isMemberOfIncludedSet(captain)) {
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
        if (upType == "Officer") {
            for (Officer officer : mOfficers.values()) {
                if (!isMemberOfIncludedSet(officer)) {
                    continue;
                }
                if (faction.equals(officer.getFaction()) || faction.equals(officer.getAdditionalFaction())) {
                    matchingUpgrades.add(officer);
                }
            }
        } else {
            for (Upgrade upgrade : upgrades.values()) {
                if (!isMemberOfIncludedSet(upgrade)) {
                    continue;
                }
                if ((upType == null || upgrade.getUpType().equals(upType))
                        && (faction.equals(upgrade.getFaction())
                        || faction.equals(upgrade.getAdditionalFaction()))) {
                    matchingUpgrades.add(upgrade);
                }
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

    public ArrayList<FleetCaptain> getFleetCaptainsForFaction(String faction) {
        ArrayList<FleetCaptain> matchingFleetCaptains = new ArrayList<FleetCaptain>();
        for (FleetCaptain fs : fleetCaptains.values()) {
            if (faction.equals(fs.getFaction()) && isMemberOfIncludedSet(fs)) {
                matchingFleetCaptains.add(fs);
            }
        }
        Collections.sort(matchingFleetCaptains, new FleetCaptainComparator());
        return matchingFleetCaptains;
    }

    public ArrayList<Set> getSets() {
        ArrayList<Set> setsCopy = new ArrayList<Set>();
        setsCopy.addAll(sets.values());
        Collections.sort(setsCopy, new SetComparator());
        return setsCopy;
    }

    public ArrayList<Set> getSetsForSection(String section) {
        if (section == null) {
            return getSets();
        }
        ArrayList<Set> setsCopy = new ArrayList<Set>();
        for (Set set : sets.values()) {
            if (set.getSection().equals(section)) {
                setsCopy.add(set);
            }
        }
        //setsCopy.addAll(sets.values());
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

    /**
     * Null indicates all factions
     */
    public String getSelectedFaction() {
        return mSelectedFaction;
    }

    public void setSelectedFaction(String faction) {
        mSelectedFaction = faction;
    }

    @Deprecated
    public Squad getSquadByIndex(int squadIndex) {
        return mSquads.get(squadIndex);
    }

    public Squad getSquadByUUID(String uuid) {
        for (Squad squad : mSquads) {
            if (squad.getUuid().equals(uuid)) {
                return squad;
            }
        }
        return null;
    }

    public void addSquad(Squad squad) {
        mSquads.add(squad);
        sortSquads();
    }

    public ArrayList<Squad> getAllSquads() {
        return mSquads;
    }

    public void removeAllSquads() {
        mSquads.clear();
    }

    public void sortSquads() {
        Collections.sort(mSquads, new SquadComparator());
    }

    public TreeSet<String> getAllSpecials() {
        TreeSet<String> allSpecials = new TreeSet<String>();
        for (Upgrade upgrade : upgrades.values()) {
            String s = upgrade.getSpecial();
            if (s != null && s.length() > 0) {
                allSpecials.add(s);
            }
        }
        for (Captain captain : captains.values()) {
            String s = captain.getSpecial();
            if (s != null && s.length() > 0) {
                allSpecials.add(s);
            }
        }
        for (Admiral admiral : admirals.values()) {
            String s = admiral.getSpecial();
            if (s != null && s.length() > 0) {
                allSpecials.add(s);
            }
        }
        return allSpecials;
    }

    public Reference getReference(String externalId) {
        return referenceItems.get(externalId);
    }

    public List<Reference> getReferenceItems() {
        ArrayList<Reference> referenceItemsCopy = new ArrayList<Reference>();
        for (Reference resource : referenceItems.values()) {
            if (isMemberOfIncludedSet(resource)) {
                referenceItemsCopy.add(resource);
            }
        }
        Collections.sort(referenceItemsCopy, new ReferenceComparator());
        return referenceItemsCopy;
    }
}
