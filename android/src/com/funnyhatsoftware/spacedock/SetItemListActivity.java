package com.funnyhatsoftware.spacedock;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;

public class SetItemListActivity extends FragmentActivity
        implements SetItemListFragment.SetItemSelectCallback {

    public static final String EXTRA_EQUIP_SHIP_NR = "ship";
    public static final String EXTRA_SLOT_TYPE = "slot_type";
    public static final String EXTRA_SLOT_NUMBER = "slot_number";
    public static final String EXTRA_CURRENT_EQUIP_ID = "current";
    public static final String EXTRA_RETURN_SELECTION = "return_id";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_set_item_select);

        getActionBar().setDisplayHomeAsUpEnabled(true);

        if (savedInstanceState == null) {
            final Intent i = getIntent();
            if (!i.hasExtra(EXTRA_SLOT_TYPE)) {
                throw new IllegalArgumentException("SetItemListActivity requires slot type");
            }

            int equippedShipNumber = i.getIntExtra(EXTRA_EQUIP_SHIP_NR, -1);
            int slotType = i.getIntExtra(EXTRA_SLOT_TYPE, -1);
            int slotNumber = i.getIntExtra(EXTRA_SLOT_NUMBER, -1);
            String currentEquipmentId = i.getStringExtra(EXTRA_CURRENT_EQUIP_ID);
            Fragment fragment = SetItemListFragment.newInstance(
                    equippedShipNumber, slotType, slotNumber, currentEquipmentId);
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.fragment_container, fragment)
                    .commit();
        }
    }

    @Override
    public void onSetItemSelected(int equippedShipNumber, int slotType, int slotNumber,
                String externalId) {
        Intent resultIntent = new Intent();
        resultIntent.putExtra(EXTRA_EQUIP_SHIP_NR, equippedShipNumber);
        resultIntent.putExtra(EXTRA_SLOT_TYPE, slotType);
        resultIntent.putExtra(EXTRA_SLOT_NUMBER, slotNumber);
        resultIntent.putExtra(EXTRA_RETURN_SELECTION, externalId);
        setResult(Activity.RESULT_OK, resultIntent);
        finish();
    }
}
