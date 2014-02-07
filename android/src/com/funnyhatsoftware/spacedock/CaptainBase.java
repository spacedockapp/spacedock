package com.funnyhatsoftware.spacedock;

import java.util.Map;

public class CaptainBase extends Upgrade {
	public int skill;
	public int talent;

	public void update(Map<String,Object> data) {
		skill = Utils.intValue((String)data.get("Skill"));
		talent = Utils.intValue((String)data.get("Talent"));
	}

}
