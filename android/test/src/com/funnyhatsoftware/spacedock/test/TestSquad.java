
package com.funnyhatsoftware.spacedock.test;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;

import com.funnyhatsoftware.spacedock.data.EquippedShip;
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
        squad.importFromStream(universe, is, false);
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
        InputStream is = getContext().getAssets().open("squads_33.spacedocksquads");
        universe.loadSquadsFromStream(is);
        ArrayList<Squad> allSquads = universe.getAllSquads();
        assertEquals(32, allSquads.size());
    }
    
    
    public void testExport() throws IOException, JSONException {
        InputStream is = getContext().getAssets().open("romulan_2_ship.spacedock");
        Squad squad = new Squad();
        squad.importFromStream(universe, is, false);
        JSONObject o = squad.asJSON();
        String jsonString = o.toString(4);
        InputStream stream = new ByteArrayInputStream(jsonString.getBytes("UTF-8"));
        Squad newSquad = new Squad();
        newSquad.importFromStream(universe, stream, false);
        assertEquals("Cost doesn't match", squad.calculateCost(), newSquad.calculateCost());
    }
   
}
