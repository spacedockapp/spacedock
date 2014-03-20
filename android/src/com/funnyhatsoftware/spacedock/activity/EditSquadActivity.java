package com.funnyhatsoftware.spacedock.activity;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.fragment.EditSquadFragment;
import com.funnyhatsoftware.spacedock.fragment.SetItemListFragment;

public class EditSquadActivity extends FragmentActivity
        implements SetItemListFragment.SetItemSelectCallback, EditSquadFragment.SlotSelectCallback {
    private static final String TAG_EDIT = "edit";
    private static final String TAG_FIND = "find";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_onepane);

        if (savedInstanceState == null) {
            Fragment editSquadFragment = new EditSquadFragment();
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.primary_fragment_container, editSquadFragment, TAG_EDIT)
                    .commit();
        }
    }

    @Override
    public void onSlotSelected(int equippedShipNumber, int slotType, int slotNumber,
            String currentEquipmentId, String prefFaction) {
        Fragment newFragment = SetItemListFragment.newInstance(equippedShipNumber,
                slotType, slotNumber, currentEquipmentId, prefFaction);

        // Two pane, update right fragment to allow item selection
        boolean isTwoPane = findViewById(R.id.secondary_fragment_container) != null;
        if (isTwoPane) {
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.secondary_fragment_container, newFragment, TAG_FIND)
                    .commit();
        } else {
            // Single pane, put fragment into primary container
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.primary_fragment_container, newFragment, TAG_FIND)
                    .addToBackStack(TAG_FIND)
                    .commit();
        }
    }

    @Override
    public void onSetItemSelected(int equippedShipNumber, int slotType, int slotNumber,
            String externalId) {
        // pop find fragment off back stack if applicable
        getSupportFragmentManager().popBackStack(TAG_FIND,
                FragmentManager.POP_BACK_STACK_INCLUSIVE);

        EditSquadFragment editSquadFragment =
                (EditSquadFragment) getSupportFragmentManager().findFragmentByTag(TAG_EDIT);
        editSquadFragment.onSetItemReturned(equippedShipNumber, slotType, slotNumber, externalId);
    }
}
