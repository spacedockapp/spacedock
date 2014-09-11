
package com.funnyhatsoftware.spacedock.test;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import android.util.Log;

import com.funnyhatsoftware.spacedock.data.Captain;
import com.funnyhatsoftware.spacedock.data.DataUtils;
import com.funnyhatsoftware.spacedock.data.EquippedShip;
import com.funnyhatsoftware.spacedock.data.EquippedUpgrade;
import com.funnyhatsoftware.spacedock.data.JSONLabels;
import com.funnyhatsoftware.spacedock.data.Resource;
import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.Squad;

public class TestSquad extends BaseTest {
    public TestSquad() {
        super();
    }

    public void testImport() throws IOException, JSONException {
        InputStream is = getContext().getAssets().open("romulan_2_ship.spacedock");
        Squad squad = new Squad();
        squad.importFromStream(universe, is, false, true);
        assertEquals("Wrong notes", "Unified Force (0) Strike Force (5)", squad.getNotes());
        assertEquals("Wrong name", "Romulan 2 Ship", squad.getName());
        assertEquals("Wrong ship count", 2, squad.getEquippedShips().size());
        Resource resource = squad.getResource();
        assertNotNull("Missing resource", resource);
        assertEquals("Wrong resource", "4004", resource.getExternalId());
        EquippedShip es = squad.getEquippedShips().get(0);
        Ship ship = es.getShip();
        assertNotNull(ship);
        assertEquals("Wrong name", "I.R.W. Valdore", es.getShip().getTitle());
        assertEquals(1, es.getTalent());
        assertEquals(3, es.getCrew());
        assertEquals(1, es.getTech());
        assertEquals(2, es.getWeapon());
        assertEquals("Wrong upgrade count", 9, es.getUpgrades().size());
        assertEquals("Wrong cost", 100, squad.calculateCost());
    }

    static ArrayList<JSONObject> sort(JSONArray list) throws JSONException {
        ArrayList<JSONObject> sortedList = new ArrayList<JSONObject>();
        for (int i = 0; i < list.length(); ++i) {
            sortedList.add(list.getJSONObject(i));
        }
        Comparator<JSONObject> comparator = new Comparator<JSONObject>() {
            @Override
            public int compare(JSONObject jsonObject, JSONObject jsonObject2) {
                String uuid = jsonObject.optString(JSONLabels.JSON_LABEL_UUID, "");
                String uuid2 = jsonObject2.optString(JSONLabels.JSON_LABEL_UUID, "");
                return uuid.compareTo(uuid2);
            }
        };
        Collections.sort(sortedList, comparator);
        return sortedList;
    }

    static ArrayList<EquippedUpgrade> sort(ArrayList<EquippedUpgrade> list) {
        ArrayList<EquippedUpgrade> newList = new ArrayList<EquippedUpgrade>(list);
        Comparator<EquippedUpgrade> comparator = new Comparator<EquippedUpgrade>() {
            @Override
            public int compare(EquippedUpgrade equippedUpgrade, EquippedUpgrade equippedUpgrade2) {
                return equippedUpgrade.getExternalId().compareTo(equippedUpgrade2.getExternalId());
            }
        };
        Collections.sort(newList, comparator);
        return newList;
    }

    private void listTester(String fileName) throws IOException, JSONException {
        String fileNameWithExtension = String.format("%s.spacedocksquads", fileName);
        InputStream is = getContext().getAssets().open(fileNameWithExtension);
        universe.loadSquadsFromStream(is, true);
        is.close();
        is = getContext().getAssets().open(fileNameWithExtension);
        String savedJSON = DataUtils.convertStreamToString(is);
        JSONTokener tokenizer = new JSONTokener(savedJSON);
        JSONArray jsonArray = new JSONArray(tokenizer);
        int count = jsonArray.length();
        ArrayList<Squad> allSquads = universe.getAllSquads();
        assertEquals(count, allSquads.size());
        for (int i = 0; i < count; ++i) {
            JSONObject jsonObject = jsonArray.getJSONObject(i);
            String uuid = jsonObject.getString(JSONLabels.JSON_LABEL_UUID);
            String name = jsonObject.getString(JSONLabels.JSON_LABEL_NAME);
            Squad loadedSquad = universe.getSquadByUUID(uuid);
            String squadLabel = name + " [" + uuid + "]";
            Log.i("spacedock", "testing " + squadLabel);
            assertNotNull("Can't find squad " + squadLabel, loadedSquad);
            assertEquals("name mismatch", name, loadedSquad.getName());
            assertEquals("notes mismatch " + squadLabel,
                    jsonObject.optString(JSONLabels.JSON_LABEL_NOTES, ""), loadedSquad.getNotes());
            String resourceId = jsonObject.optString(JSONLabels.JSON_LABEL_RESOURCE, "");
            if (resourceId.length() == 0) {
                assertNull("squad shouldn't have a resource", loadedSquad.getResource());
            } else {
                assertEquals("wrong resource in squad " + squadLabel, resourceId, loadedSquad
                        .getResource().getExternalId());
            }
            int additionalPoints = jsonObject.optInt(JSONLabels.JSON_LABEL_ADDITIONAL_POINTS);
            assertEquals("wrong additional points in squad " + squadLabel, additionalPoints,
                    loadedSquad.getAdditionalPoints());
            JSONArray ships = jsonObject.getJSONArray(JSONLabels.JSON_LABEL_SHIPS);
            ArrayList<EquippedShip> equippedShips = loadedSquad.getEquippedShips();
            assertEquals("ship count mismatch " + squadLabel, ships.length(),
                    equippedShips.size());
            for (int shipIndex = 0; shipIndex < ships.length(); ++shipIndex) {
                String shipLabel = squadLabel + ": ship #" + shipIndex;
                JSONObject shipData = ships.getJSONObject(shipIndex);
                EquippedShip loadedShip = equippedShips.get(shipIndex);

                boolean shipIsSideboard = shipData.optBoolean(JSONLabels.JSON_LABEL_SIDEBOARD);
                assertEquals("sideboard mismatch " + shipLabel, shipIsSideboard,
                        loadedShip.isResourceSideboard());

                if (!shipIsSideboard) {
                    String shipId = shipData.getString(JSONLabels.JSON_LABEL_SHIP_ID);
                    assertEquals("ship id mismatch " + shipLabel, shipId,
                            loadedShip.getShipExternalId());
                }

                JSONObject captainData = shipData.getJSONObject(JSONLabels.JSON_LABEL_CAPTAIN);
                EquippedUpgrade ec = loadedShip.getEquippedCaptain();
                Captain captain = loadedShip.getCaptain();
                assertEquals("captain mistmatch for " + shipLabel,
                        captainData.getString(JSONLabels.JSON_LABEL_UPGRADE_ID),
                        captain.getExternalId());
                int cost = captainData.getInt("calculatedCost");
                assertEquals("cost mistmatch for captain on " + shipLabel, cost, ec.calculateCost());

                ArrayList<JSONObject> upgradeListData = sort(shipData.getJSONArray(JSONLabels.JSON_LABEL_UPGRADES));
                ArrayList<EquippedUpgrade> upgrades = sort(loadedShip.getAllUpgradesExceptPlaceholders());

                if (upgradeListData.size() != upgrades.size()) {
                    for (int logUpgradeIndex = 0; logUpgradeIndex < upgradeListData.size(); ++logUpgradeIndex) {
                        JSONObject upgradeData = upgradeListData.get(logUpgradeIndex);
                        Log.i("spacedock", String.format("%d: %s", logUpgradeIndex, upgradeData.optString(JSONLabels.JSON_LABEL_UPGRADE_TITLE, "")));
                    }
                    for (int logUpgradeIndex = 0; logUpgradeIndex < upgrades.size(); ++logUpgradeIndex) {
                        EquippedUpgrade upgrade = upgrades.get(logUpgradeIndex);
                        Log.i("spacedock", String.format("%d: %s", logUpgradeIndex, upgrade.getUpgrade().getTitle()));
                    }
                    assertEquals("upgrade count mismatch for " + shipLabel, upgradeListData.size(),
                            upgrades.size());
                }

                int limit = Math.min(upgradeListData.size(), upgrades.size());
                for (int upgradeIndex = 0; upgradeIndex < limit; ++upgradeIndex) {
                    String upgradeLabel = shipLabel + ": upgrade #" + upgradeIndex;
                    JSONObject upgradeData = upgradeListData.get(upgradeIndex);
                    EquippedUpgrade equippedUpgrade = upgrades.get(upgradeIndex);
                    assertEquals("upgrade mistmatch for " + upgradeLabel,
                            upgradeData.getString(JSONLabels.JSON_LABEL_UPGRADE_ID),
                            equippedUpgrade.getUpgrade().getExternalId());
                    boolean expectedOverridden = upgradeData
                            .optBoolean(JSONLabels.JSON_LABEL_COST_IS_OVERRIDDEN);
                    boolean overridden = equippedUpgrade.getOverridden();
                    assertEquals("upgrade overridden mistmatch for " + upgradeLabel,
                            expectedOverridden,
                            overridden);
                    if (overridden) {
                    } else {
                        cost = upgradeData.getInt("calculatedCost");
                        int calculatedCost = equippedUpgrade.calculateCost();
                        assertEquals("cost mistmatch for " + upgradeLabel, cost, calculatedCost);
                    }
                }

                cost = shipData.getInt("calculatedCost");
                int calculatedCost = loadedShip.calculateCost();
                assertEquals("cost mistmatch for " + shipLabel, cost, calculatedCost);
            }

            int cost = jsonObject.getInt(JSONLabels.JSON_LABEL_COST);
            int calculatedCost = loadedSquad.calculateCost();
            assertEquals("cost mistmatch for " + squadLabel, cost, calculatedCost);
        }
    }

    public void testImportList() throws JSONException, IOException {
        listTester("squads_for_test");
    }

    public void testSpecials() throws JSONException, IOException {
        listTester("specials");
    }

    public void testExport() throws IOException, JSONException {
        InputStream is = getContext().getAssets().open("romulan_2_ship.spacedock");
        Squad squad = new Squad();
        squad.importFromStream(universe, is, false, true);
        JSONObject o = squad.asJSON();
        String jsonString = o.toString(4);
        InputStream stream = new ByteArrayInputStream(jsonString.getBytes("UTF-8"));
        Squad newSquad = new Squad();
        newSquad.importFromStream(universe, stream, false, true);
        assertEquals("Cost doesn't match", squad.calculateCost(), newSquad.calculateCost());
    }

}
