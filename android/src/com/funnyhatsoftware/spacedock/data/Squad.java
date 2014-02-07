package com.funnyhatsoftware.spacedock.data;

import java.io.InputStream;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

public class Squad extends SquadBase {

	static String convertStreamToString(InputStream is) {
		java.util.Scanner s = new java.util.Scanner(is);
		s.useDelimiter("\\A");
		String value = s.hasNext() ? s.next() : "";
		s.close();
		return value;
	}

	public EquippedShip getSideboard() {
		EquippedShip sideboard = null;

		for (EquippedShip target : equippedShips) {
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
			equippedShips.add(sideboard);
		}
		return sideboard;
	}

	EquippedShip removeSideboard() {
		EquippedShip sideboard = getSideboard();

		if (sideboard != null) {
			equippedShips.remove(sideboard);
		}

		return sideboard;
	}

	public void importFromStream(Universe universe, InputStream is)
			throws JSONException {
		JSONTokener tokenizer = new JSONTokener(convertStreamToString(is));
		JSONObject jsonObject = new JSONObject(tokenizer);
		setNotes(jsonObject.getString("notes"));
		setName(jsonObject.getString("name"));
		setAdditionalPoints(jsonObject.optInt("additionalPoints"));
		String resourceId = jsonObject.optString("resource");
		if (resourceId != null) {
			Resource resource = universe.resources.get(resourceId);
			setResource(resource);
		}

		JSONArray ships = jsonObject.getJSONArray("ships");
		EquippedShip currentShip = null;
		for (int i = 0; i < ships.length(); ++i) {
			JSONObject shipData = ships.getJSONObject(i);
			boolean shipIsSideboard = shipData.optBoolean("sideboard");
			if (shipIsSideboard) {
				currentShip = getSideboard();
			} else {
				currentShip = new EquippedShip();		
			}
			currentShip.importUpgrades(universe, shipData);
			add(currentShip);
		}
	}

	public void add(EquippedShip ship) {
		equippedShips.add(ship);
		ship.setSquad(this);
	}
}
