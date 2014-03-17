package com.funnyhatsoftware.spacedock;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.view.View;
import android.widget.AdapterView;
import android.widget.BaseAdapter;

import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.holder.ItemHolder;
import com.funnyhatsoftware.spacedock.holder.ItemHolderFactory;
import com.funnyhatsoftware.spacedock.holder.NewItemAdapter;

public class ItemListFragment extends ListFragment {
    public static final String ARG_ITEM_TYPE = "item_type";
    private BaseAdapter mAdapter;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if ((getArguments() == null) || !getArguments().containsKey(ARG_ITEM_TYPE)) {
            throw new IllegalArgumentException("Invalid fragment arguments, must contain type");
        }

        Context context = getActivity();
        String key = getArguments().getString(ARG_ITEM_TYPE);
        ItemHolderFactory itemHolderFactory = ItemHolderFactory.getHolderFactory(key);
        Universe universe = Universe.getUniverse();

        if (itemHolderFactory.usesFactions()) {
            // add a combination of faction-specific adapters together
            final SeparatedListAdapter multiAdapter = new SeparatedListAdapter(getActivity());
            for (String faction : universe.getAllFactions()) {
                NewItemAdapter factionAdapter = new NewItemAdapter(context, faction, itemHolderFactory);
                if (factionAdapter.getCount() > 0) {
                    multiAdapter.addSection(faction, factionAdapter);
                }
            }
            mAdapter = multiAdapter;
        } else {
            // item type not split into factions, use a single adapter
            mAdapter = new NewItemAdapter(context, null, itemHolderFactory);
        }
        setListAdapter(mAdapter);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        getListView().setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if (view.getTag() == null) return;

                ItemHolder holder = (ItemHolder) view.getTag();
                holder.navigateToDetails(getActivity(), mAdapter.getItem(position));
            }
        });
    }
}
