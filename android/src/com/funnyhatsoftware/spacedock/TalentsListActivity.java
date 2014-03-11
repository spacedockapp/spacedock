package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

import android.widget.BaseAdapter;

import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Upgrade;

public class TalentsListActivity extends UpgradeListActivity {

    @Override
    protected BaseAdapter createSectionAdapter(Universe universe, String faction, int listRowId) {
        ArrayList<Upgrade> items = universe.getTalentsForFaction(faction);
        UpgradeAdapter adapter = new UpgradeAdapter(this,
                listRowId, items);
        return adapter;
    }

}
