package com.funnyhatsoftware.spacedock;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.widget.ExpandableListView;
import android.widget.ListView;

import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;

import org.json.JSONException;

import java.io.IOException;
import java.io.InputStream;

public class SquadBuildActivity extends FragmentActivity
        implements SetItemListFragment.SetItemSelectCallback, SquadListAdapter.SlotSelectCallback {
    public static final int REQUEST_GET_SET_ITEM = 0;

    private static Squad sSquad;

    private SquadListAdapter mAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_squad_build_onepane);

        if (sSquad == null) {
            try {
                InputStream is = getAssets().open("romulan_2_ship.spacedock");
                sSquad = new Squad();
                sSquad.importFromStream(Universe.getUniverse(), is);
            } catch (IOException e) {
                e.printStackTrace();
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        ExpandableListView listView = (ExpandableListView) findViewById(R.id.squad_list);
        boolean isTwoPane = findViewById(R.id.right_fragment_container) != null;
        listView.setChoiceMode(isTwoPane
                ? ListView.CHOICE_MODE_SINGLE
                : ListView.CHOICE_MODE_NONE);
        mAdapter = new SquadListAdapter(this, listView, sSquad, this);
        listView.setAdapter(mAdapter);
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
    }

    @Override
    public void onSlotSelected(int equippedShipNumber, int slotType, int slotNumber,
                String currentEquipmentId, String prefFaction) {
        Bundle argsBundle = new Bundle();
        SetItemListFragment.setupArgs(argsBundle,
                equippedShipNumber, slotType, slotNumber, currentEquipmentId, prefFaction);

        boolean isTwoPane = findViewById(R.id.right_fragment_container) != null;
        if (isTwoPane) {
            // Two pane, update right fragment to allow item selection
            Fragment rightFragment = new SetItemListFragment();
            rightFragment.setArguments(argsBundle);
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.right_fragment_container, rightFragment)
                    .commit();
        } else {
            // Single pane, get item with new activity
            Intent intent = new Intent(this, SetItemListActivity.class);
            intent.putExtras(argsBundle);
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
            // Set item returned from SetItemListActivity
            Bundle bundle = data.getExtras();
            int equippedShipNumber = bundle.getInt(SetItemListFragment.ARG_EQUIP_SHIP_NR);
            int slotType = bundle.getInt(SetItemListFragment.ARG_SLOT_TYPE);
            int slotNumber = bundle.getInt(SetItemListFragment.ARG_SLOT_NUMBER);
            String externalId = bundle.getString(SetItemListFragment.ARG_RETURN_EQUIP_ID);
            onSetItemSelected(equippedShipNumber, slotType, slotNumber, externalId);
        }
    }
}
