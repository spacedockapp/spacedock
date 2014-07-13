package com.funnyhatsoftware.spacedock.activity;

import android.content.Context;
import android.content.Intent;
import android.support.v4.app.Fragment;

import com.funnyhatsoftware.spacedock.fragment.SetItemListFragment;

public abstract class SetItemListActivity extends SinglePaneActivity implements
        SetItemListFragment.SetItemSelectedListener {
    private static final String EXTRA_ITEM_TYPE = "item_type";
    private static final String EXTRA_PRIORITIZED_FACTION = "prior_faction";
    private static final String EXTRA_SELECTED_ID = "item_sel";

    public static final String EXTRA_ITEM_RESULT_ID = "result_id";

    public static class BrowseActivity extends SetItemListActivity implements
            SetItemListFragment.SetItemSelectedListener {
        public static Intent getIntent(Context context, String itemType) {
            if (itemType == null) throw new IllegalArgumentException();
            Intent intent = new Intent(context, BrowseActivity.class);
            intent.putExtra(EXTRA_ITEM_TYPE, itemType);
            return intent;
        }

        public Fragment getFragment() {
            String itemType = getIntent().getStringExtra(EXTRA_ITEM_TYPE);
            return SetItemListFragment.newInstance(itemType);
        }

        @Override
        public void onItemSelected(String itemType, String itemId) {
            startActivity(DetailsActivity.getIntent(this, itemType, itemId));
        }
    }

    public static class SelectActivity extends SetItemListActivity implements
            SetItemListFragment.SetItemSelectedListener {
        public static Intent getIntent(Context context, String itemType, String prioritizedFaction,
                String currentEquipmentId) {
            if (itemType == null) throw new IllegalArgumentException();

            Intent intent = new Intent(context, SelectActivity.class);
            intent.putExtra(EXTRA_ITEM_TYPE, itemType);
            intent.putExtra(EXTRA_PRIORITIZED_FACTION, prioritizedFaction);
            intent.putExtra(EXTRA_SELECTED_ID, currentEquipmentId);
            return intent;
        }

        @Override
        public Fragment getFragment() {
            String itemType = getIntent().getStringExtra(EXTRA_ITEM_TYPE);
            String prioritizedFaction = getIntent().getStringExtra(EXTRA_PRIORITIZED_FACTION);
            String currentEquipmentId = getIntent().getStringExtra(EXTRA_SELECTED_ID);
            return SetItemListFragment.newInstance(itemType, prioritizedFaction, currentEquipmentId);
        }

        @Override
        public void onItemSelected(String itemType, String itemId) {
            Intent returnIntent = new Intent();
            returnIntent.putExtra(EXTRA_ITEM_RESULT_ID, itemId);
            setResult(RESULT_OK, returnIntent);
            finish();
        }
    }
}
