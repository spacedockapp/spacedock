
package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Intent;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;

import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Upgrade;

public class WeaponListActivity extends UpgradeListActivity {

    @Override
    protected BaseAdapter createSectionAdapter(Universe universe, String faction, int resourceId) {
        ArrayList<Upgrade> upgrades = universe.getUpgradesForFaction(mUpType, faction);
        ArrayAdapter<Upgrade> adapter = new WeaponsAdapter(this,
                resourceId, upgrades);
        return adapter;
    }

    @Override
    protected int getListRowId() {
        return R.layout.weapon_list_row;
    }

    @Override
    protected void handleClickedItem(BaseAdapter headerAdapter, Activity self, int position) {
        Upgrade upgrade = (Upgrade) headerAdapter.getItem(position);
        Intent intent = new Intent(self, WeaponDetailActivity.class);
        intent.putExtra("externalId", upgrade.getExternalId());
        startActivity(intent);
    }

}
