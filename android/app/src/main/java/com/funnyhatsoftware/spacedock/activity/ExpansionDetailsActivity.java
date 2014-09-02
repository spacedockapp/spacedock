package com.funnyhatsoftware.spacedock.activity;

import android.content.Context;
import android.content.Intent;
import android.support.v4.app.Fragment;

import com.funnyhatsoftware.spacedock.fragment.DisplaySetFragment;

public class ExpansionDetailsActivity extends SinglePaneActivity {
    private static final String EXTRA_ID = "setId";

    public static Intent getIntent(Context context, String setId) {
        if (setId == null) {
            throw new IllegalArgumentException();
        }

        Intent intent = new Intent(context, ExpansionDetailsActivity.class);
        intent.putExtra(EXTRA_ID, setId);
        return intent;
    }

    public Fragment getFragment() {
        String setId = getIntent().getStringExtra(EXTRA_ID);
        return DisplaySetFragment.newInstance(setId);
    }
}
