package com.funnyhatsoftware.spacedock;

import java.util.Map;

public class WeaponBase extends Upgrade {
	public int attack;
	public String range;

	public void update(Map<String,Object> data) {
		attack = Utils.intValue((String)data.get("Attack"));
		range = Utils.stringValue((String)data.get("Range"));
	}

}
