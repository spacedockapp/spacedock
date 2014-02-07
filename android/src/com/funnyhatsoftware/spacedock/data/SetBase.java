// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class SetBase {
    String externalId;
    public String getExternalId() { return externalId; }
    public SetBase setExternalId(String v) { externalId = v; return this;}
    boolean include;
    public boolean getInclude() { return include; }
    public SetBase setInclude(boolean v) { include = v; return this;}
    String name;
    public String getName() { return name; }
    public SetBase setName(String v) { name = v; return this;}
    String productName;
    public String getProductName() { return productName; }
    public SetBase setProductName(String v) { productName = v; return this;}
    ArrayList<SetItem> items = new ArrayList<SetItem>();
    @SuppressWarnings("unchecked")
    public ArrayList<SetItem> getItems() { return (ArrayList<SetItem>)items.clone(); }
    @SuppressWarnings("unchecked")
    public SetBase setItems(ArrayList<SetItem> v) { items = (ArrayList<SetItem>)v.clone(); return this;}

    public void update(Map<String,Object> data) {
        externalId = DataUtils.stringValue((String)data.get("Id"));
        include = DataUtils.booleanValue((String)data.get("Include"));
        name = DataUtils.stringValue((String)data.get("Name"));
        productName = DataUtils.stringValue((String)data.get("ProductName"));
    }

}
