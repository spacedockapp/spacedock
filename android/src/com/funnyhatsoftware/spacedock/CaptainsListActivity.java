
package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Intent;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;

import com.funnyhatsoftware.spacedock.data.Captain;
import com.funnyhatsoftware.spacedock.data.Universe;

public class CaptainsListActivity extends ItemListActivity {

    protected int getListRowId() {
        return R.layout.captain_list_row;
    }

    protected BaseAdapter createSectionAdapter(Universe universe, String faction, int resourceId) {
        ArrayList<Captain> factionCaptains = universe.getCaptainsForFaction(faction);
        ArrayAdapter<Captain> adapter = new CaptainsAdapter(this,
                resourceId, factionCaptains);
        return adapter;
    }

    protected void handleClickedItem(final SeparatedListAdapter headerAdapter,
            final Activity self, int position) {
        Captain captain = (Captain)headerAdapter.getItem(position);
        Intent intent = new Intent(self, CaptainDetailActivity.class);
        intent.putExtra("externalId", captain.getExternalId());
        startActivity(intent);
    }

}
