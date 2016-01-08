package com.funnyhatsoftware.spacedock.data;

import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Squad extends SquadBase {

    public static final String JSON_LABEL_SHIP_ID = "shipId";
    public static final String JSON_LABEL_SIDEBOARD = "sideboard";
    public static final String JSON_LABEL_SHIPS = "ships";
    public static final String JSON_LABEL_RESOURCE = "resource";
    public static final String JSON_LABEL_RESOURCE_ATTRIBUTES = "resourceAttributes";
    public static final String JSON_LABEL_UUID = "uuid";
    public static final String JSON_LABEL_ADDITIONAL_POINTS = "additionalPoints";
    public static final String JSON_LABEL_NAME = "name";
    public static final String JSON_LABEL_NOTES = "notes";
    public static final String JSON_LABEL_COST = "cost";
    public static final String JSON_LABEL_CAPTAIN = "captain";
    public static final String JSON_LABEL_SHIP_TITLE = "shipTitle";
    public static final String JSON_LABEL_FLAGSHIP = "flagship";
    public static final String JSON_LABEL_UPGRADES = "upgrades";

    static class SquadComparator implements Comparator<Squad> {
        @Override
        public int compare(Squad o1, Squad o2) {
            return o1.getName().compareToIgnoreCase(o2.getName());
        }
    }

    public Squad() {
        assignNewUuid();
    }

    public void assignNewUuid() {
        setUuid(UUID.randomUUID().toString());
    }

    static private HashSet<String> allNames() {
        List<Squad> allSquads = Universe.getUniverse().getAllSquads();
        HashSet<String> names = new HashSet<String>();
        for (Squad squad : allSquads) {
            names.add(squad.getName());
        }
        return names;
    }

    public EquippedShip getSideboard() {
        EquippedShip sideboard = null;

        for (EquippedShip target : mEquippedShips) {
            if (target.isResourceSideboard()) {
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
            sideboard.establishPlaceholders();
            mEquippedShips.add(sideboard);
            sideboard.setSquad(this);
        }
        return sideboard;
    }

    EquippedShip removeSideboard() {
        EquippedShip sideboard = getSideboard();

        if (sideboard != null) {
            mEquippedShips.remove(sideboard);
            sideboard.setSquad(null);
        }

        return sideboard;
    }

    public EquippedShip getFighterSquadron() {
        EquippedShip fighters = null;

        for (EquippedShip target : mEquippedShips) {
            if (target.isFighterSquadron()) {
                fighters = target;
                break;
            }
        }
        return fighters;
    }

    public EquippedShip addFighterSquadron(Resource resource) {
        EquippedShip fighters = getFighterSquadron();
        if (fighters == null) {
            fighters = new EquippedShip(resource.associatedShip());
            mEquippedShips.add(fighters);
            fighters.setSquad(this);
        }
        return fighters;
    }

    EquippedShip removeFighterSquadron() {
        EquippedShip fighters = getFighterSquadron();

        if (fighters != null) {
            mEquippedShips.remove(fighters);
            fighters.setSquad(null);
        }

        return fighters;
    }

    public void importFromObject(Universe universe, boolean replaceUuid, JSONObject jsonObject,
                                 boolean strict)
            throws JSONException {
        removeAllEquippedShips();
        setNotes(jsonObject.optString(JSON_LABEL_NOTES, ""));
        setName(jsonObject.optString(JSON_LABEL_NAME, "Untitled"));
        setAdditionalPoints(jsonObject.optInt(JSON_LABEL_ADDITIONAL_POINTS));
        if (replaceUuid) {
            assignNewUuid();
        } else {
            setUuid(jsonObject.optString(JSON_LABEL_UUID, UUID.randomUUID()
                    .toString()));
        }
        String resourceId = jsonObject.optString(JSON_LABEL_RESOURCE, "");
        String resourceAttribs = jsonObject.optString(JSON_LABEL_RESOURCE_ATTRIBUTES, "");
        if (resourceId.length() > 0) {
            Resource resource = universe.resources.get(resourceId);
            if (strict && resource == null) {
                throw new RuntimeException("Can't find resource " + resourceId);
            }
            if (resourceAttribs.length() > 0) {
                setResourceAttributes(resourceAttribs);
            }
            setResource(resource);
        }

        JSONArray ships = jsonObject.getJSONArray(JSON_LABEL_SHIPS);

        boolean hasRomulanShip = false;
        EquippedShip shipWithTebok = null;
        JSONObject shipWithTebokData = null;

        for (int i = 0; i < ships.length(); ++i) {
            JSONObject shipData = ships.getJSONObject(i);
            boolean shipIsSideboard = shipData.optBoolean(JSON_LABEL_SIDEBOARD);
            EquippedShip currentShip = null;
            if (shipIsSideboard) {
                currentShip = getSideboard();
            } else {
                String shipId = shipData.optString(JSON_LABEL_SHIP_ID);
                Ship targetShip = universe.getShip(shipId);
                if (targetShip != null) {
                    currentShip = new EquippedShip(targetShip);
                } else if (strict && !shipId.isEmpty()) {
                    throw new RuntimeException("Can't find ship " + shipId);
                }
            }
            if (currentShip != null && !currentShip.isFighterSquadron()) {
                if (!hasRomulanShip) {
                    JSONObject captainObject = shipData
                            .optJSONObject(JSONLabels.JSON_LABEL_CAPTAIN);
                    if (captainObject != null && !shipIsSideboard) {
                        String captainId = captainObject
                                .optString(JSONLabels.JSON_LABEL_UPGRADE_ID);
                        Captain captain = universe.getCaptain(captainId);
                        if (!captain.getSpecial().equals("OneRomulanTalentDiscIfFleetHasRomulan")) {
                            if (currentShip.getShip().isRomulan()) {
                                hasRomulanShip = true;
                            }
                        } else {
                            shipWithTebok = currentShip;
                            shipWithTebokData = shipData;
                        }
                    }
                }
                if (shipWithTebok != null && shipWithTebok == currentShip && i < (ships.length() - 1)) {
                    if (hasRomulanShip) {
                        addEquippedShip(shipWithTebok);
                        shipWithTebok.importUpgrades(universe, shipWithTebokData, strict);
                        shipWithTebok = null;
                        shipWithTebokData = null;
                    }
                } else {
                    if (!shipIsSideboard) {
                        addEquippedShip(currentShip);
                    }
                    currentShip.importUpgrades(universe, shipData, strict);
                }
                if (shipWithTebok != null && shipWithTebok != currentShip) {
                    if (hasRomulanShip) {
                        addEquippedShip(shipWithTebok);
                        shipWithTebok.importUpgrades(universe, shipWithTebokData, strict);
                        shipWithTebok = null;
                        shipWithTebokData = null;
                    } else if (i == (ships.length() - 1)) {
                        addEquippedShip(shipWithTebok);
                        shipWithTebok.importUpgrades(universe, shipWithTebokData, strict);
                    }
                }
            }
        }
    }

    public void importFromStream(Universe universe, InputStream is, boolean replaceUuid,
                                 boolean strict)
            throws JSONException {
        JSONTokener tokenizer = new JSONTokener(DataUtils.convertStreamToString(is));
        JSONObject jsonObject = new JSONObject(tokenizer);
        importFromObject(universe, replaceUuid, jsonObject, strict);
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
            String resourceAttributes = getResourceAttributes();
            if (resourceAttributes != null) {
                o.put(JSON_LABEL_RESOURCE_ATTRIBUTES,resourceAttributes);
            }
        }
        ArrayList<EquippedShip> equippedShips = getEquippedShips();
        JSONArray shipsArray = new JSONArray();
        int index = 0;
        for (EquippedShip ship : equippedShips) {
            if (!ship.isFighterSquadron()) {
                shipsArray.put(index++, ship.asJSON());
            }
        }
        o.put(JSON_LABEL_SHIPS, shipsArray);
        return o;
    }

    public Explanation tryAddEquippedShip(String shipId) {
        if (shipId == null) {
            return Explanation.SUCCESS;
        }
        Ship ship = Universe.getUniverse().getShip(shipId);
        Explanation explanation = canAddShip(ship);
        if (explanation.canAdd) {
            EquippedShip es = new EquippedShip(ship);
            es.establishPlaceholders();
            addEquippedShip(es);
        }
        return explanation;
    }

    public void addEquippedShip(EquippedShip ship) {
        mEquippedShips.add(ship);
        if (ship.isFighterSquadron()) {
            setResource(ship.getShip().getAssociatedResource());
        }
        ship.setSquad(this);
        // Sort to make sure the sideboard is always the last ship
        Comparator<EquippedShip> comparator = new Comparator<EquippedShip>() {
            @Override
            public int compare(EquippedShip arg0, EquippedShip arg1) {
                if (arg0.isResourceSideboard()) {
                    if (arg1.isResourceSideboard()) {
                        return 0;
                    }
                    return 1;
                }
                if (arg1.isResourceSideboard()) {
                    return -1;
                }
                return 0;
            }
        };
        Collections.sort(mEquippedShips, comparator);
    }

    public void removeEquippedShip(EquippedShip ship) {
        mEquippedShips.remove(ship);
        if (ship.isFighterSquadron()) {
            setResource(null);
        }
        ship.setSquad(null);
    }

    public void removeAllEquippedShips() {
        ArrayList<EquippedShip> equippedShips = new ArrayList<EquippedShip>(mEquippedShips);
        for (EquippedShip ship : equippedShips) {
            removeEquippedShip(ship);
        }
    }

    public int calculateCost() {
        int cost = 0;

        Resource resource = getResource();

        if (resource != null && !resource.equippedIntoSquad(this)) {
            // flagship cost taken into account when assigned to EquippedShip
            // Fighters appear as ships
            //cost += resource.getCost();
            cost += resource.getCostForSquad(this);
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

    EquippedUpgrade containsUniqueUpgradeWithName(String theName) {
        for (EquippedShip ship : mEquippedShips) {
            EquippedUpgrade existing = ship.containsUniqueUpgradeWithName(theName);
            if (existing != null) {
                return existing;
            }
        }
        return null;
    }

    EquippedUpgrade containsMirrorUniverseUniqueUpgradeWithName(String theName) {
        for (EquippedShip ship : mEquippedShips) {
            EquippedUpgrade existing = ship.containsMirrorUniverseUniqueUpgradeWithName(theName);
            if (existing != null) {
                return existing;
            }
        }
        return null;
    }

    boolean containsShipWithName(String theName) {
        for (EquippedShip equippedShip : mEquippedShips) {
            if (equippedShip.getTitle().equals(theName)) {
                return true;
            }
        }
        return false;
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

    Explanation canAddShip(Ship ship) {
        if (ship.getUnique()) {
            if (containsShipWithName(ship.getTitle())) {
                String result = String.format(
                        "Can't add %s to the selected squadron",
                        ship.getTitle());
                String explanation = "This ship is unique and one with the same name already exists in the squadron.";
                return new Explanation(result, explanation);
            }
        }
        return Explanation.SUCCESS;
    }

    Explanation canAddCaptain(Captain captain, EquippedShip targetShip) {
        Captain existingCaptain = targetShip.getCaptain();
        if (existingCaptain == captain) {
            return Explanation.SUCCESS;
        }

        if (captain.getUnique()) {
            EquippedUpgrade existing = containsUniqueUpgradeWithName(captain
                    .getTitle());
            String result = String.format(
                    "Can't add %s to the selected squadron",
                    captain.getTitle());
            if (existing != null && !existing.getUpgrade().equals(targetShip.getCaptain())) {

                String explanation = "This Captain is unique and one with the same name already exists in the squadron.";
                return new Explanation(result, explanation);
            }
            if ("not_with_hugh".equalsIgnoreCase(captain.getSpecial()) && null != containsUpgradeWithName("Hugh")) {
                return new Explanation(result, "This Captain cannot be added to a squadron that contains Hugh");
            }
            if ("not_with_jean_luc_picard".equalsIgnoreCase(captain.getSpecial()) && null != containsUpgradeWithName("Jean-Luc Picard")) {
                return new Explanation(result, "This Captain cannot be added to a squadron that contains Jean-Luc Picard");
            }
            if ("Jean-Luc Picard".equals(captain.getTitle()) && null != containsUpgradeWithName("Locutus")) {
                return new Explanation(result, "This Captain cannot be added to a squadron that contains Locutus");
            }
            if ("hugh_71522".equalsIgnoreCase(captain.getSpecial()) && null != containsUpgradeWithName("Third of Five")) {
                return new Explanation(result, "This Captain cannot be added to a squadron that contains Third of Five");
            }
            if (null != targetShip.containsUpgrade(Universe.getUniverse().getUpgrade("romulan_hijackers_71802"))) {
                if (!captain.isRomulan()) {
                    return new Explanation(result, "You may only deploy a Romulan captain while this ship is equipped with the Romulan Hijackers Upgrade.");
                }
            }
            if (targetShip.getShip().getShipClass().equals("Romulan Drone Ship")) {
                if (targetShip.getCaptain() != null && !targetShip.getCaptain().getExternalId().equals("gareb_71536")) {
                    if (!captain.getExternalId().equals("gareb_71536") && !captain.getExternalId().equals("romulan_drone_pilot_71536")) {
                        return new Explanation(result, "This ship may only be assigned Gareb or a Romulan Drone Pilot as its Captain.");
                    }
                }
            } else if (captain.getExternalId().equals("gareb_71536")) {
                return new Explanation(result,"Gareb may only be purchased for a Romulan Drone Ship.");
            } else if (captain.getExternalId().equals("romulan_drone_pilot_71536")) {
                return new Explanation(result,"Romulan Drone Pilot may only be purchased for a Romulan Drone Ship.");
            }
            if ("OnlyFerengiShip".equals(captain.getSpecial())) {
                if (!targetShip.getShip().isFerengi()) {
                    return new Explanation(result, "You may only deploy this Captain to a Ferengi ship.");
                }
            }
            if ("OnlySpecies8472Ship".equals(captain.getSpecial())) {
                if (!targetShip.getShip().isSpecies8472()) {
                    return new Explanation(result, "You may only deploy this Captain to a Species 8472 ship.");
                }
            }
        }

        if (captain.getMirrorUniverseUnique()) {
            EquippedUpgrade existing = containsMirrorUniverseUniqueUpgradeWithName(captain
                    .getTitle());
            String result = String.format(
                    "Can't add %s to the selected squadron",
                    captain.getTitle());
            if (existing != null && !existing.getUpgrade().equals(targetShip.getCaptain())) {

                String explanation = "This Captain is Mirror Universe unique and one with the same name already exists in the squadron.";
                return new Explanation(result, explanation);
            }
        }

        return Explanation.SUCCESS;
    }

    Explanation canAddUpgrade(Upgrade upgrade, EquippedShip targetShip) {
        String result = String.format(
                "Can't add %s to the selected squadron",
                upgrade.getTitle());
        if (upgrade.getUnique()) {
            EquippedUpgrade existing = containsUniqueUpgradeWithName(upgrade
                    .getTitle());
            if (existing != null) {

                String explanation = String
                        .format("This %s is unique and one with the same name already exists in the squadron.",
                                upgrade.getUpType());
                return new Explanation(result, explanation);
            }
        }
        if ("not_with_hugh".equalsIgnoreCase(upgrade.getSpecial()) && null != containsUpgradeWithName("Hugh")) {
            return new Explanation(result, "This Upgrade cannot be added to a squadron that contains Hugh");
        }
        if ("OnlyFerengiShip".equals(upgrade.getSpecial())) {
            if (!targetShip.getShip().isFerengi()) {
                return new Explanation(result, "You may only deploy this " + upgrade.getUpType() + " to a Ferengi ship.");
            }
        }

        if (upgrade.getMirrorUniverseUnique()) {
            EquippedUpgrade existing = containsMirrorUniverseUniqueUpgradeWithName(upgrade
                    .getTitle());
            if (existing != null) {

                String explanation = String
                        .format("This %s is Mirror Universe unique and one with the same name already exists in the squadron.",
                                upgrade.getUpType());
                return new Explanation(result, explanation);
            }
        }
        return targetShip.canAddUpgrade(upgrade, true);
    }

    public SquadBase setResource(Resource resource) {
        Resource oldResource = super.getResource();
        if (oldResource != resource) {
            if (oldResource != null) {
                if (oldResource.getIsSideboard()) {
                    removeSideboard();
                } else if (oldResource.getIsFlagship()) {
                    removeFlagship();
                } else if (oldResource.isFleetCaptain()) {
                    removeFleetCaptain();
                } else if (oldResource.getIsFighterSquadron()) {
                    removeFighterSquadron();
                } else if (oldResource.isOfficers()) {
                    removeOfficers();
                }
            }

            super.setResource(resource);

            if (resource != null) {
                if (resource.getIsSideboard()) {
                    addSideboard();
                } else if (resource.getIsFighterSquadron()) {
                    addFighterSquadron(resource);
                }
            }
        }
        return this;
    }

    void removeFlagship() {
        for (EquippedShip ship : mEquippedShips) {
            ship.removeFlagship();
        }
    }

    void removeFleetCaptain() {
        for (EquippedShip ship : mEquippedShips) {
            ship.removeFleetCaptain();
        }
    }

    void removeOfficers() {
        for (EquippedShip ship : mEquippedShips) {
            ship.removeOfficers();
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

    FleetCaptain getFleetCaptain() {
        FleetCaptain retVal = null;
        for (EquippedShip ship : mEquippedShips) {
            FleetCaptain fleetCaptain = ship.getFleetCaptain();
            if (null != fleetCaptain && !fleetCaptain.isPlaceholder()) {
                retVal = fleetCaptain;
                break;
            }
        }
        return retVal;
    }

    String getFleetCaptainSpecial() {
        String retVal = null;
        FleetCaptain fleetCaptain = getFleetCaptain();
        if (fleetCaptain != null) {
            retVal = fleetCaptain.getSpecial();
        }
        return retVal;
    }

    public void getFactions(HashSet<String> factions) {
        for (EquippedShip mEquippedShip : mEquippedShips) {
            mEquippedShip.getFactions(factions);
        }
    }

    public String asPlainTextFormat() {
        StringBuilder sb = new StringBuilder();
        Resource resource = getResource();
        for (EquippedShip es : getEquippedShips()) {
            sb.append(String.format("%s (%d)\n", es.getPlainDescription(),
                    es.getBaseCost()));
            Flagship flagship = es.getFlagship();
            if (flagship != null) {
                sb.append(String.format("%s (%d)\n",
                        flagship.getPlainDescription(), flagship.getCost()));
            }
            FleetCaptain fleetCaptain = es.getFleetCaptain();
            if (null != fleetCaptain) {
                sb.append(String.format("%s (%d)\n",
                        fleetCaptain.getPlainDescription(), fleetCaptain.getCost()));
            }
            for (EquippedUpgrade eu : es.getSortedUpgrades()) {
                if (!eu.isPlaceholder()) {
                    if (eu.getOverridden()) {
                        sb.append(String.format("%s (%d overridden to %d)\n",
                                eu.getTitle(),
                                eu.getNonOverriddenCost(), eu.getCost()));
                    } else {
                        sb.append(String.format("%s (%d)\n",
                                eu.getTitle(), eu.getCost()));
                    }
                }
            }
            if (!es.isResourceSideboard()) {
                sb.append(String.format("Total (%d)\n", es.calculateCost()));
            }
            sb.append("\n");
        }

        if (resource != null && !resource.getIsFlagship()
                && !resource.getIsFighterSquadron() && !resource.isFleetCaptain()) {
            sb.append(String.format("%s (%s)\n\n", resource.getTitle(), resource.getCost()));
        }

        String notes = getNotes();
        if (notes != null && notes.length() > 0) {
            sb.append(notes);
            sb.append("\n\n");
        }

        int otherCost = getAdditionalPoints();
        if (otherCost > 0) {
            sb.append(String.format("Other cost: %d\n\n", otherCost));
        }

        sb.append(String.format("Fleet total: %d\n\n", calculateCost()));

        sb.append("Generated by Space Dock for Android\nhttp://spacedockapp.org\n");
        return sb.toString();
    }
}
