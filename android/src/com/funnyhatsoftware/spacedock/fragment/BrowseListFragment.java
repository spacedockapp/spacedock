package com.funnyhatsoftware.spacedock.fragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.ListFragment;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.funnyhatsoftware.spacedock.holder.ItemHolderFactory;

import java.util.ArrayList;

public class BrowseListFragment extends ListFragment {
    public interface BrowseTypeSelectionListener {
        public void onBrowseTypeSelected(String itemType);
    }

    ArrayAdapter<String> mAdapter;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ArrayList<String> targets = new ArrayList<String>();
        targets.addAll(ItemHolderFactory.getFactoryTypes());

        mAdapter = new ArrayAdapter<String>(getActivity(),
                android.R.layout.simple_list_item_activated_1,
                targets);
        setListAdapter(mAdapter);
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        String targetType = mAdapter.getItem(position);
        ((BrowseTypeSelectionListener) getActivity()).onBrowseTypeSelected(targetType);
    }
}
