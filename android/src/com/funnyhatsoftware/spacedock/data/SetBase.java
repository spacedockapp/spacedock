package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class SetBase {
    public String externalId;
    public boolean include;
    public String name;
    public String productName;
    public ArrayList<SetItem> items = new ArrayList<SetItem>();

    public void update(Map<String,Object> data) {
        externalId = DataUtils.stringValue((String)data.get("Id"));
        include = DataUtils.booleanValue((String)data.get("Include"));
        name = DataUtils.stringValue((String)data.get("Name"));
        productName = DataUtils.stringValue((String)data.get("ProductName"));
    }

}
