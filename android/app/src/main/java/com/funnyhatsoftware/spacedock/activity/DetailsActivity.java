package com.funnyhatsoftware.spacedock.activity;

import android.content.Context;
import android.content.Intent;
import android.support.v4.app.Fragment;

import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;
import com.funnyhatsoftware.spacedock.holder.ExpansionHolder;

public class DetailsActivity extends SinglePaneActivity {
    private static final String EXTRA_TYPE = "browsetype";
    private static final String EXTRA_ITEM = "displayitem";

    public static Intent getIntent(Context context, String itemType, String itemId) {
        if (itemType == null || itemId == null) {
            throw new IllegalArgumentException();
        }

        if (itemType.equals(ExpansionHolder.TYPE_STRING)) {
            return ExpansionDetailsActivity.getIntent(context, itemId);
        }

        Intent intent = new Intent(context, DetailsActivity.class);
        intent.putExtra(EXTRA_TYPE, itemType);
        intent.putExtra(EXTRA_ITEM, itemId);
        return intent;
    }

    public Fragment getFragment() {
        String itemType = getIntent().getStringExtra(EXTRA_TYPE);
        String itemId = getIntent().getStringExtra(EXTRA_ITEM);
        return DetailsFragment.newInstance(itemType, itemId);
    }
}
