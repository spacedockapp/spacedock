package com.funnyhatsoftware.spacedock;

import java.util.Map;

import java.util.ArrayList;

public class EquippedShipBase {
	public Flagship flagship;
	public Ship ship;
	public Squad squad;
	public ArrayList<EquippedUpgrade> upgrades = new ArrayList<EquippedUpgrade>();

	public void update(Map<String,Object> data) {
	}

}
