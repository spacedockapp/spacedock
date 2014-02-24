package com.funnyhatsoftware.spacedock;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;

public class SetItemListActivity extends FragmentActivity
        implements SetItemListFragment.SetItemSelectCallback {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_set_item_select);

        getActionBar().setDisplayHomeAsUpEnabled(true);

        if (savedInstanceState == null) {
            Fragment fragment = new SetItemListFragment();
            fragment.setArguments(getIntent().getExtras());
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.fragment_container, fragment)
                    .commit();
        }
    }

    @Override
    public void onSetItemSelected(int equippedShipNumber, int slotType, int slotNumber,
                String externalId) {
        Intent resultIntent = new Intent();
        resultIntent.putExtra(SetItemListFragment.ARG_EQUIP_SHIP_NR, equippedShipNumber);
        resultIntent.putExtra(SetItemListFragment.ARG_SLOT_TYPE, slotType);
        resultIntent.putExtra(SetItemListFragment.ARG_SLOT_NUMBER, slotNumber);
        resultIntent.putExtra(SetItemListFragment.ARG_RETURN_EQUIP_ID, externalId);
        setResult(Activity.RESULT_OK, resultIntent);
        finish();
    }
}
