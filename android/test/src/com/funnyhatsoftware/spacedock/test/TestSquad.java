package com.funnyhatsoftware.spacedock.test;

import java.io.IOException;
import java.io.InputStream;

import org.json.JSONException;

import com.funnyhatsoftware.spacedock.data.EquippedShip;
import com.funnyhatsoftware.spacedock.data.Squad;

public class TestSquad extends BaseTest {
	public void testImport() throws IOException, JSONException {
		InputStream is = getContext().getAssets().open("romulan_2_ship.spacedock");
		Squad squad = new Squad();
		squad.importFromStream(universe, is);
		assertEquals("Wrong notes", "Unified Force (0) Strike Force (5)", squad.getNotes());
		assertEquals("Wrong name", "Romulan 2 Ship", squad.getName());
		assertEquals("Wrong ship count", 2, squad.getEquippedShips().size());
		EquippedShip es = squad.getEquippedShips().get(0);
		assertEquals("Wrong upgrade count", 5, es.getUpgrades().size());
		assertEquals("Wrong cost", 100, squad.calculateCost());
	}
}
