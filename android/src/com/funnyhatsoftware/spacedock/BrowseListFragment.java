package com.funnyhatsoftware.spacedock;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.ListFragment;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.funnyhatsoftware.spacedock.holder.ItemHolderFactory;

import java.util.ArrayList;

public class BrowseListFragment extends ListFragment {
    ArrayAdapter<BrowseTarget> mAdapter;
    private class BrowseTarget {
        final String mItemType;

        /**
         * Upgrade constructor, with optional label parameter to override
         */
        public BrowseTarget(String upType) {
            mItemType = upType;
        }

        public void navigate() {
            Fragment newFragment = new ItemListFragment();
            Bundle arguments = new Bundle();
            arguments.putString(ItemListFragment.ARG_ITEM_TYPE, mItemType);
            newFragment.setArguments(arguments);

            boolean isTwoPane = getActivity().findViewById(R.id.secondary_fragment_container) != null;
            if (isTwoPane) {
                // two pane, replace secondary fragment
                getFragmentManager().beginTransaction()
                        .replace(R.id.secondary_fragment_container, newFragment)
                        .commit();
            } else {
                // single pane, add new fragment in place of main
                getFragmentManager().beginTransaction()
                        .replace(R.id.primary_fragment_container, newFragment)
                        .addToBackStack(null)
                        .commit();
            }
        }

        @Override
        public String toString() {
            // TODO: should load (plural) labels from resources
            return mItemType;
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ArrayList<BrowseTarget> targets = new ArrayList<BrowseTarget>();
        for (String itemType : ItemHolderFactory.getFactoryTypes()) {
            targets.add(new BrowseTarget(itemType));
        }

        mAdapter = new ArrayAdapter<BrowseTarget>(getActivity(),
                android.R.layout.simple_list_item_activated_1, targets);
        setListAdapter(mAdapter);
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        BrowseTarget target = mAdapter.getItem(position);
        target.navigate();
    }
}
