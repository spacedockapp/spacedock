
package com.funnyhatsoftware.spacedock;

import android.app.Activity;
import android.content.Intent;

import com.funnyhatsoftware.spacedock.data.Upgrade;

public abstract class UpgradeListActivity extends ItemListActivity {

    @Override
    protected void handleClickedItem(SeparatedListAdapter headerAdapter, Activity self, int position) {
        Upgrade upgrade = (Upgrade) headerAdapter.getItem(position);
        Intent intent = new Intent(self, UpgradeDetailActivity.class);
        intent.putExtra("externalId", upgrade.getExternalId());
        startActivity(intent);
    }

    @Override
    protected int getListRowId() {
        return R.layout.upgrade_list_row;
    }

}
