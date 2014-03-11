
package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

import android.app.Activity;
import android.widget.BaseAdapter;

import com.funnyhatsoftware.spacedock.data.Set;
import com.funnyhatsoftware.spacedock.data.Universe;

public class SetListActivity extends ItemListActivity {

    @Override
    protected BaseAdapter createSectionAdapter(Universe universe, String s, int listRowId) {
        ArrayList<Set> sets = universe.getSets();
        SetsAdapter adapter = new SetsAdapter(this,
                listRowId, sets);
        return adapter;
    }

    @Override
    protected void handleClickedItem(BaseAdapter headerAdapter, Activity self, int position) {
        // TODO Auto-generated method stub

    }

    @Override
    protected int getListRowId() {
        return R.layout.set_list_row;
    }

    @Override
    protected boolean usesFactions() {
        return false;
    }
}
