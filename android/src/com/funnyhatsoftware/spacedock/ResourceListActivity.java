
package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Intent;
import android.widget.BaseAdapter;

import com.funnyhatsoftware.spacedock.data.Resource;
import com.funnyhatsoftware.spacedock.data.Universe;

public class ResourceListActivity extends ItemListActivity {

    @Override
    protected BaseAdapter createSectionAdapter(Universe universe, String s, int listRowId) {
        ArrayList<Resource> items = universe.getResources();
        ResourcesAdapter adapter = new ResourcesAdapter(this,
                listRowId, items);
        return adapter;
    }

    @Override
    protected void handleClickedItem(BaseAdapter headerAdapter, Activity self, int position) {
        Resource resource = (Resource) headerAdapter.getItem(position);
        Intent intent = new Intent(self, ResourceDetailActivity.class);
        intent.putExtra("externalId", resource.getExternalId());
        startActivity(intent);
    }

    @Override
    protected int getListRowId() {
        return R.layout.resource_list_row;
    }

    @Override
    protected boolean usesFactions() {
        return false;
    }

}
