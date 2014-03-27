package com.funnyhatsoftware.spacedock.activity;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentTransaction;

import com.funnyhatsoftware.spacedock.R;

public abstract class PanedFragmentActivity extends FragmentActivity {
    protected boolean isTwoPane() {
        return findViewById(R.id.secondary_fragment_container) != null;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_onepane); // returns 2 pane on tablets
    }

    protected void initializePrimaryFragment(Fragment newFragment, String tag) {
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.primary_fragment_container, newFragment, tag)
                .commit();
    }

    protected void navigateToSubFragment(Fragment newFragment, String tag) {
        final boolean isTwoPane = isTwoPane();
        int containerId = isTwoPane ? R.id.secondary_fragment_container
                : R.id.primary_fragment_container;

        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction()
                .replace(containerId, newFragment, tag);
        if (!isTwoPane) {
            transaction.addToBackStack(tag);
        }
        transaction.commit();
    }
}
