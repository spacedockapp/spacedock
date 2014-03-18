
package com.funnyhatsoftware.spacedock.data;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

public class Squad extends SquadBase {

    private static final String JSON_LABEL_SHIP_ID = "shipId";
    private static final String JSON_LABEL_SIDEBOARD = "sideboard";
    private static final String JSON_LABEL_SHIPS = "ships";
    private static final String JSON_LABEL_RESOURCE = "resource";
    private static final String JSON_LABEL_UUID = "uuid";
    private static final String JSON_LABEL_ADDITIONAL_POINTS = "additionalPoints";
    private static final String JSON_LABEL_NAME = "name";
    private static final String JSON_LABEL_NOTES = "notes";

    public Squad() {
        setUuid(UUID.randomUUID().toString());
    }
    
    

    @Override
    public boolean equals(Object o) {
        if (o == null) {
            return false;
        }
        
        if (o.getClass() != Squad.class) {
            return false;
        }
        
        Squad os = (Squad)o;
        
        if (!mName.equals(os.mName)) {
            return false;
        }

        return true;
    }



    static String convertStreamToString(InputStream is) {
        java.util.Scanner s = new java.util.Scanner(is);
        s.useDelimiter("\\A");
        String value = s.hasNext() ? s.next() : "";
        s.close();
        return value;
    }

    static private HashSet<String> allNames() {
        ArrayList<Squad> allSquads = Universe.getUniverse().squads;
        HashSet<String> names = new HashSet<String>();
        for (Squad squad : allSquads) {
            names.add(squad.getName());
        }
        return names;
    }

    public EquippedShip getSideboard() {
        EquippedShip sideboard = null;

        for (EquippedShip target : mEquippedShips) {
            if (target.getIsResourceSideboard()) {
                sideboard = target;
                break;
            }
        }
        return sideboard;
    }

    public EquippedShip addSideboard() {
        EquippedShip sideboard = getSideboard();
        if (sideboard == null) {
            sideboard = new Sideboard();
            mEquippedShips.add(sideboard);
        }
        return sideboard;
    }

    EquippedShip removeSideboard() {
        EquippedShip sideboard = getSideboard();

        if (sideboard != null) {
            mEquippedShips.remove(sideboard);
        }

        return sideboard;
    }

    public void importFromStream(Universe universe, InputStream is)
            throws JSONException {
        JSONTokener tokenizer = new JSONTokener(convertStreamToString(is));
        JSONObject jsonObject = new JSONObject(tokenizer);
        setNotes(jsonObject.getString(JSON_LABEL_NOTES));
        setName(jsonObject.getString(JSON_LABEL_NAME));
        setAdditionalPoints(jsonObject.optInt(JSON_LABEL_ADDITIONAL_POINTS));
        setUuid(jsonObject.optString(JSON_LABEL_UUID, UUID.randomUUID().toString()));
        String resourceId = jsonObject.optString(JSON_LABEL_RESOURCE);
        if (resourceId != null) {
            Resource resource = universe.resources.get(resourceId);
            setResource(resource);
        }

        JSONArray ships = jsonObject.getJSONArray(JSON_LABEL_SHIPS);
        for (int i = 0; i < ships.length(); ++i) {
            JSONObject shipData = ships.getJSONObject(i);
            boolean shipIsSideboard = shipData.optBoolean(JSON_LABEL_SIDEBOARD);
            EquippedShip currentShip;
            if (shipIsSideboard) {
                currentShip = getSideboard();
            } else {
                String shipId = shipData.optString(JSON_LABEL_SHIP_ID);
                Ship targetShip = universe.getShip(shipId);
                currentShip = new EquippedShip(targetShip);
            }
            currentShip.importUpgrades(universe, shipData);
            addEquippedShip(currentShip);
        }
    }

    public JSONObject asJSON() throws JSONException {
        JSONObject o = new JSONObject();
        o.put(JSON_LABEL_NAME, getName());
        o.put(JSON_LABEL_NOTES, getNotes());
        o.put(JSON_LABEL_ADDITIONAL_POINTS, getAdditionalPoints());
        o.put(JSON_LABEL_UUID, getUuid());
        Resource resource = getResource();
        if (resource != null) {
            o.put(JSON_LABEL_RESOURCE, resource.getExternalId());
        }
        ArrayList<EquippedShip> equippedShips = getEquippedShips();
        JSONArray shipsArray = new JSONArray();
        int index = 0;
        for (EquippedShip ship : equippedShips) {
            shipsArray.put(index++, ship.asJSON());
        }
        o.put(JSON_LABEL_SHIPS, shipsArray);
        return o;
    }

    public void addEquippedShip(String shipId) {
        EquippedShip es = new EquippedShip(Universe.getUniverse().getShip(shipId));
        es.establishPlaceholders();
        addEquippedShip(es);
    }

    public void addEquippedShip(EquippedShip ship) {
        mEquippedShips.add(ship);
        ship.setSquad(this);
        // Sort to make sure the sideboard is always the last ship
        Comparator<EquippedShip> comparator = new Comparator<EquippedShip>() {
            @Override
            public int compare(EquippedShip arg0, EquippedShip arg1) {
                if (arg0.getIsResourceSideboard() == arg1.getIsResourceSideboard()) {
                    return 0;
                }

                if (arg0.getIsResourceSideboard()) {
                    return 1;
                }

                return -1;
            }
        };
        Collections.sort(mEquippedShips, comparator);
    }

    public void removeEquippedShip(EquippedShip ship) {
        mEquippedShips.remove(ship);
    }

    public int calculateCost() {
        int cost = 0;

        Resource resource = getResource();
        if (resource != null) {
            cost += resource.getCost();
        }

        cost += getAdditionalPoints();

        for (EquippedShip ship : mEquippedShips) {
            cost += ship.calculateCost();
        }

        return cost;
    }

    EquippedUpgrade containsUpgrade(Upgrade theUpgrade) {
        for (EquippedShip ship : mEquippedShips) {
            EquippedUpgrade existing = ship.containsUpgrade(theUpgrade);
            if (existing != null) {
                return existing;
            }
        }
        return null;
    }

    EquippedUpgrade containsUpgradeWithName(String theName) {
        for (EquippedShip ship : mEquippedShips) {
            EquippedUpgrade existing = ship.containsUpgradeWithName(theName);
            if (existing != null) {
                return existing;
            }
        }
        return null;
    }

    private static String namePrefix(String originalName) {
        Pattern p = Pattern.compile(" copy *\\d*");
        Matcher matcher = p.matcher(originalName);
        if (matcher.find()) {
            return originalName.substring(0, matcher.start());
        }
        return originalName;
    }

    public Squad duplicate() {
        Squad squad = new Squad();
        String originalNamePrefix = namePrefix(mName);
        String newName = originalNamePrefix + " copy";
        HashSet<String> names = allNames();
        int index = 2;

        while (names.contains(newName)) {
            newName = originalNamePrefix + " copy " + Integer.toString(index);
            index += 1;
        }
        squad.setName(newName);
        for (EquippedShip ship : mEquippedShips) {
            EquippedShip dup = ship.duplicate();
            squad.addEquippedShip(dup);
        }
        squad.setResource(getResource());
        squad.setNotes(getNotes());
        squad.setAdditionalPoints(getAdditionalPoints());
        return squad;
    }

    Explanation addCaptain(Captain captain, EquippedShip targetShip) {
        Captain existingCaptain = targetShip.getCaptain();
        if (existingCaptain == captain) {
            return Explanation.SUCCESS;
        }

        if (captain.getUnique()) {
            EquippedUpgrade existing = containsUpgradeWithName(captain.getTitle());
            if (existing != null) {
                String result = String.format("Can't add %s to the selected squadron",
                        captain.getTitle());
                String explanation = "This Captain is unique and one with the same name already exists in the squadron.";
                return new Explanation(false, result, explanation);
            }
        }
        return Explanation.SUCCESS;
    }

    Explanation canAddUpgrade(Upgrade upgrade, EquippedShip targetShip) {
        if (upgrade.getUnique()) {
            EquippedUpgrade existing = containsUpgradeWithName(upgrade.getTitle());
            if (existing != null) {
                String result = String.format("Can't add %s to the selected squadron",
                        upgrade.getTitle());
                String explanation = String
                        .format("This %s is unique and one with the same name already exists in the squadron.",
                                upgrade.getUpType());
                return new Explanation(false, result, explanation);
            }
        }

        return targetShip.canAddUpgrade(upgrade);
    }

    public SquadBase setResource(Resource resource) {
        Resource oldResource = super.getResource();
        if (oldResource != resource) {
            if (oldResource != null) {
                if (oldResource.getIsSideboard()) {
                    removeSideboard();
                } else if (oldResource.getIsFlagship()) {
                    removeFlagship();
                }
            }

            super.setResource(resource);

            if (resource != null && resource.getIsSideboard()) {
                addSideboard();
            }
        }
        return this;
    }

    void removeFlagship() {
        for (EquippedShip ship : mEquippedShips) {
            ship.removeFlagship();
        }
    }

    Flagship flagship() {
        for (EquippedShip ship : mEquippedShips) {
            Flagship flagship = ship.getFlagship();
            if (flagship != null) {
                return flagship;
            }
        }
        return null;
    }

    public void getFactions(HashSet<String> factions) {
        for (EquippedShip mEquippedShip : mEquippedShips) {
            mEquippedShip.getFactions(factions);
        }
    }
}
