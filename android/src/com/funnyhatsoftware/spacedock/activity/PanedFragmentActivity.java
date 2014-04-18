package com.funnyhatsoftware.spacedock.activity;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentTransaction;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.fragment.ChooseFactionDialog;
import com.funnyhatsoftware.spacedock.fragment.SetItemListFragment;

public abstract class PanedFragmentActivity extends FragmentActivity
        implements ChooseFactionDialog.FactionChoiceListener {
    /**
     * Fragment interface that allows Activities to update fragment data when Universe data
     * updates should be reflected in other fragments.
     */
    public interface DataFragment {
        /**
         * Called when data Fragment is displaying should be updated.
         * <p>
         * If the fragment directly *references* raw Universe data, this can be
         * handled as notifying the fragment's adapter.
         * <p>
         * If however the fragment's adapter was created with a copy of data from within
         * the Universe, the adapter will likely need to be recreated.
         */
        public void notifyDataSetChanged();
    }

    protected boolean isTwoPane() {
        return findViewById(R.id.secondary_fragment_container) != null;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_onepane); // returns 2 pane on tablets
    }

    /**
     * Call notifyDataSetChanged() on the fragment with the tag passed, if it exists.
     */
    protected void notifyDataFragment(String tag) {
        DataFragment fragment = (DataFragment) getSupportFragmentManager().findFragmentByTag(tag);
        if (fragment != null) {
            fragment.notifyDataSetChanged();
        }
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

    /**
     * @return True if removed, false if not present.
     */
    protected boolean removeFragmentByTag(String tag) {
        Fragment fragment = getSupportFragmentManager().findFragmentByTag(tag);
        if (fragment != null) {
            getSupportFragmentManager().beginTransaction()
                    .remove(fragment)
                    .commit();
            return true;
        }
        return false;
    }

    @Override
    public void onFactionChoiceUpdated(String faction) {
        Universe.getUniverse().setSelectedFaction(faction);

        // update SetItemListFragments to respect new faction choice
        for (Fragment fragment : getSupportFragmentManager().getFragments()) {
            if (fragment instanceof SetItemListFragment) {
                ((SetItemListFragment) fragment).notifyDataSetChanged();
            }
        }
    }
}
