
package com.funnyhatsoftware.spacedock.test;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

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
        assertEquals("Wrong upgrade count", 8, es.getUpgrades().size());
        assertEquals("Wrong cost", 100, squad.calculateCost());
    }

    public void testImportList() throws JSONException, IOException {
        InputStream is = getContext().getAssets().open("squads_for_test.spacedocksquads");
        universe.loadSquadsFromStream(is, true);
        is.close();
        is = getContext().getAssets().open("squads_for_test.spacedocksquads");
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
            for (int shipIndex = 0; shipIndex < ships.length(); ++shipIndex) {
                String shipLabel = squadLabel + ": ship #" + shipIndex;
                JSONObject shipData = ships.getJSONObject(shipIndex);
                EquippedShip loadedShip = equippedShips.get(shipIndex);

                String shipId = shipData.getString(JSONLabels.JSON_LABEL_SHIP_ID);
                assertEquals("ship id mismatch " + shipLabel, shipId, loadedShip.getShip()
                        .getExternalId());

                boolean shipIsSideboard = shipData.optBoolean(JSONLabels.JSON_LABEL_SIDEBOARD);
                assertEquals("sideboard mismatch " + shipLabel, shipIsSideboard,
                        loadedShip.getIsResourceSideboard());

                JSONObject captainData = shipData.getJSONObject(JSONLabels.JSON_LABEL_CAPTAIN);
                EquippedUpgrade ec = loadedShip.getEquippedCaptain();
                Captain captain = loadedShip.getCaptain();
                assertEquals("captain mistmatch for " + shipLabel,
                        captainData.getString(JSONLabels.JSON_LABEL_UPGRADE_ID),
                        captain.getExternalId());
                int cost = captainData.getInt("calculatedCost");
                assertEquals("cost mistmatch for captain on " + shipLabel, cost, ec.calculateCost());

                JSONArray upgradeListData = shipData.getJSONArray(JSONLabels.JSON_LABEL_UPGRADES);
                ArrayList<EquippedUpgrade> upgrades = loadedShip.getAllUpgradesExceptPlaceholders();
                int limit = Math.min(upgradeListData.length(), upgrades.size());
                for (int upgradeIndex = 0; upgradeIndex < limit; ++upgradeIndex) {
                    String upgradeLabel = shipLabel + ": upgrade #" + upgradeIndex;
                    JSONObject upgradeData = upgradeListData.getJSONObject(upgradeIndex);
                    EquippedUpgrade equippedUpgrade = upgrades.get(upgradeIndex);
                    assertEquals("upgrade mistmatch for " + upgradeLabel,
                            upgradeData.getString(JSONLabels.JSON_LABEL_UPGRADE_ID),
                            equippedUpgrade.getUpgrade().getExternalId());
                }
                assertEquals("upgrade count mismatch for " + shipLabel, upgradeListData.length(),
                        upgrades.size());

                cost = shipData.getInt("calculatedCost");
                assertEquals("cost mistmatch for " + shipLabel, cost, loadedShip.calculateCost());
            }

            int cost = jsonObject.getInt(JSONLabels.JSON_LABEL_COST);
            assertEquals("cost mistmatch for " + squadLabel, cost, loadedSquad.calculateCost());
        }
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
