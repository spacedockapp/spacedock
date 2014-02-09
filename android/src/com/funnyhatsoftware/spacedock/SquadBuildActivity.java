package com.funnyhatsoftware.spacedock;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.widget.ExpandableListView;
import android.widget.ListView;

import com.funnyhatsoftware.spacedock.data.EquippedShip;

import java.util.ArrayList;

public class SquadBuildActivity extends FragmentActivity
        implements SetItemListFragment.SetItemSelectCallback, SquadListAdapter.SlotSelectCallback {
    public static final int REQUEST_GET_SET_ITEM = 0;

    private static ArrayList<EquippedShip> testEquippedShips = new ArrayList<EquippedShip>();

    private SquadListAdapter mAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_squad_build_onepane);

        while (testEquippedShips.size() < 3) {
            testEquippedShips.add(new EquippedShip());
        }

        ExpandableListView listView = (ExpandableListView) findViewById(R.id.squad_list);
        boolean isTwoPane = findViewById(R.id.right_fragment_container) != null;
        listView.setChoiceMode(isTwoPane
                ? ListView.CHOICE_MODE_SINGLE
                : ListView.CHOICE_MODE_NONE);
        mAdapter = new SquadListAdapter(this, listView, testEquippedShips, this);
        listView.setAdapter(mAdapter);
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
    }

    @Override
    public void onSlotSelected(int equippedShipNumber, int slotType, int slotNumber,
                String currentEquipmentId) {
        boolean isTwoPane = findViewById(R.id.right_fragment_container) != null;
        if (isTwoPane) {
            // Two pane, update right fragment to allow item selection
            Fragment rightFragment = SetItemListFragment.newInstance(
                    equippedShipNumber, slotType, slotNumber, currentEquipmentId);
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.right_fragment_container, rightFragment)
                    .commit();
        } else {
            // Single pane, get item with new activity
            Intent intent = new Intent(this, SetItemListActivity.class);
            intent.putExtra(SetItemListActivity.EXTRA_EQUIP_SHIP_NR, equippedShipNumber);
            intent.putExtra(SetItemListActivity.EXTRA_SLOT_TYPE, slotType);
            intent.putExtra(SetItemListActivity.EXTRA_SLOT_NUMBER, slotNumber);
            intent.putExtra(SetItemListActivity.EXTRA_CURRENT_EQUIP_ID, currentEquipmentId);
            startActivityForResult(intent, REQUEST_GET_SET_ITEM);
        }
    }

    @Override
    public void onSetItemSelected(int equippedShipNumber, int slotType, int slotNumber,
                String externalId) {
        mAdapter.onSetItemReturned(equippedShipNumber, slotType, slotNumber, externalId);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_GET_SET_ITEM && resultCode == Activity.RESULT_OK) {
            int equippedShipNumber = data.getIntExtra(SetItemListActivity.EXTRA_EQUIP_SHIP_NR, -1);
            int slotType = data.getIntExtra(SetItemListActivity.EXTRA_SLOT_TYPE, -1);
            int slotNumber = data.getIntExtra(SetItemListActivity.EXTRA_SLOT_NUMBER, -1);
            String externalId = data.getStringExtra(SetItemListActivity.EXTRA_RETURN_SELECTION);
            onSetItemSelected(equippedShipNumber, slotType, slotNumber, externalId);
        }
    }
}
