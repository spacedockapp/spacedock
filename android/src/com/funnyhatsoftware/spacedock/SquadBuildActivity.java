package com.funnyhatsoftware.spacedock;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.widget.ExpandableListView;
import android.widget.ListView;

import com.funnyhatsoftware.spacedock.data.EquippedShip;

import java.util.ArrayList;

public class SquadBuildActivity extends FragmentActivity
        implements SetItemListFragment.CardSelectCallback, SquadListAdapter.SlotSelectCallback {
    private static ArrayList<EquippedShip> testEquippedShips = new ArrayList<EquippedShip>();

    private SquadListAdapter mAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        while (testEquippedShips.size() < 3) {
            testEquippedShips.add(new EquippedShip());
        }

        ExpandableListView listView = (ExpandableListView) findViewById(R.id.squad_list);
        listView.setChoiceMode(ListView.CHOICE_MODE_SINGLE);
        mAdapter = new SquadListAdapter(this, listView, testEquippedShips, this);
        listView.setAdapter(mAdapter);
    }

    @Override
    public void onCardSelected(String externalId) {
        mAdapter.onSetItemReturned(externalId);
    }

    @Override
    public void onSlotSelected(int slotType, String currentEquipmentId) {
        // TODO: single pane UI
        Fragment rightFragment = SetItemListFragment.newInstance(slotType, currentEquipmentId);
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.right_fragment_container, rightFragment)
                .commit();
    }
}
