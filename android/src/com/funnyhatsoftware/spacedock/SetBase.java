package com.funnyhatsoftware.spacedock;

import java.util.Map;

import java.util.ArrayList;

public class SetBase {
	public String externalId;
	public boolean include;
	public String name;
	public String productName;
	public ArrayList<SetItem> items = new ArrayList<SetItem>();

	public void update(Map<String,Object> data) {
		externalId = Utils.stringValue((String)data.get("Id"));
		include = Utils.booleanValue((String)data.get("Include"));
		name = Utils.stringValue((String)data.get("Name"));
		productName = Utils.stringValue((String)data.get("ProductName"));
	}

}
