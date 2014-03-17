package com.funnyhatsoftware.spacedock;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.ListFragment;
import android.util.Log;
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
            Fragment rightFragment = new ItemListFragment();
            Bundle arguments = new Bundle();
            arguments.putString(ItemListFragment.ARG_ITEM_TYPE, mItemType);
            rightFragment.setArguments(arguments);
            getFragmentManager().beginTransaction()
                    .replace(R.id.right_fragment_container, rightFragment)
                    .commit();
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
