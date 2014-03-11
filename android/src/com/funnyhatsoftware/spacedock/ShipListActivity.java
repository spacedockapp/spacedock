package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Intent;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;

import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.Universe;

public class ShipListActivity extends ItemListActivity {

    @Override
    protected BaseAdapter createSectionAdapter(Universe universe, String s, int listRowId) {
        ArrayList<Ship> ships = universe.getShipsForFaction(s);
        ArrayAdapter<Ship> adapter = new ShipsAdapter(this,
                listRowId, ships);
        return adapter;
    }

    @Override
    protected void handleClickedItem(BaseAdapter headerAdapter, Activity self, int position) {
        Ship upgrade = (Ship) headerAdapter.getItem(position);
        Intent intent = new Intent(self, ShipDetailActivity.class);
        intent.putExtra("externalId", upgrade.getExternalId());
        startActivity(intent);
    }

    @Override
    protected int getListRowId() {
        return R.layout.ship_list_row;
    }

}
