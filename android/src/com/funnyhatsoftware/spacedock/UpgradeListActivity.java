
package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.BaseAdapter;

import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Upgrade;

public class UpgradeListActivity extends ItemListActivity {

    protected String mUpType = "";
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        mUpType = getIntent().getStringExtra("upType");
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void handleClickedItem(BaseAdapter headerAdapter, Activity self, int position) {
        Upgrade upgrade = (Upgrade) headerAdapter.getItem(position);
        Intent intent = new Intent(self, UpgradeDetailActivity.class);
        intent.putExtra("externalId", upgrade.getExternalId());
        startActivity(intent);
    }

    @Override
    protected int getListRowId() {
        return R.layout.upgrade_list_row;
    }

    @Override
    protected BaseAdapter createSectionAdapter(Universe universe, String faction, int listRowId) {
        ArrayList<Upgrade> items = universe.getUpgradesForFaction(mUpType, faction);
        UpgradeAdapter adapter = new UpgradeAdapter(this,
                listRowId, items);
        return adapter;
    }
}
