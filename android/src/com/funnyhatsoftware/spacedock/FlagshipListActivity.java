package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Intent;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;

import com.funnyhatsoftware.spacedock.data.Flagship;
import com.funnyhatsoftware.spacedock.data.Resource;
import com.funnyhatsoftware.spacedock.data.Universe;

public class FlagshipListActivity extends ItemListActivity {

    @Override
    protected BaseAdapter createSectionAdapter(Universe universe, String s, int listRowId) {
        ArrayList<Flagship> flagships = universe.getFlagshipsForFaction(s);
        ArrayAdapter<Flagship> adapter = new FlagshipsAdapter(this,
                listRowId, flagships);
        return adapter;
    }

    @Override
    protected void handleClickedItem(BaseAdapter headerAdapter, Activity self, int position) {
        Flagship fs = (Flagship) headerAdapter.getItem(position);
        Intent intent = new Intent(self, FlagshipDetailActivity.class);
        intent.putExtra("externalId", fs.getExternalId());
        startActivity(intent);
    }

    @Override
    protected int getListRowId() {
        return R.layout.flagship_list_row;
    }

}
