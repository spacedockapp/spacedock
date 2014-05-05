package com.funnyhatsoftware.spacedock.fragment;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;

import com.funnyhatsoftware.spacedock.R;

public class BrowseTwoPaneFragment extends TwoPaneFragment implements
        BrowseListFragment.BrowseTypeSelectionListener,
        SetItemListFragment.SetItemSelectedListener {
    @Override
    Fragment createPrimaryFragment() {
        return new BrowseListFragment();
    }

    @Override
    public void onBrowseTypeSelected(String itemType) {
        Fragment fragment = SetItemListFragment.newInstance(itemType);
        getChildFragmentManager().beginTransaction()
                .replace(R.id.secondary_fragment_container, fragment)
                .commit();
    }

    @Override
    public void onItemSelected(String itemType, String itemId) {
        FragmentTransaction ft = getFragmentManager().beginTransaction();
        Fragment prev = getFragmentManager().findFragmentByTag("dialog");
        if (prev != null) {
            ft.remove(prev);
        }
        ft.addToBackStack(null);

        // show the dialog.
        DetailsFragment fragment = DetailsFragment.newInstance(itemType, itemId);
        fragment.show(ft, "dialog");
    }
}
