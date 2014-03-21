package com.funnyhatsoftware.spacedock.fragment;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.app.ListFragment;
import android.view.View;
import android.widget.AdapterView;
import android.widget.BaseAdapter;

import com.funnyhatsoftware.spacedock.SeparatedListAdapter;
import com.funnyhatsoftware.spacedock.data.Set;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.holder.ItemHolderFactory;
import com.funnyhatsoftware.spacedock.holder.NewItemAdapter;

public class ItemListFragment extends ListFragment implements AdapterView.OnItemClickListener {
    private static final String ARG_ITEM_TYPE = "item_type";

    public interface ItemSelectedListener {
        public void onItemSelected(String itemType, String itemId);
    }

    private BaseAdapter mAdapter;
    private String mItemType;

    public static ItemListFragment newInstance(String itemType) {
        ItemListFragment fragment = new ItemListFragment();
        Bundle arguments = new Bundle();
        arguments.putString(ItemListFragment.ARG_ITEM_TYPE, itemType);
        fragment.setArguments(arguments);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if ((getArguments() == null) || !getArguments().containsKey(ARG_ITEM_TYPE)) {
            throw new IllegalArgumentException("Invalid fragment arguments, must contain type");
        }

        Context context = getActivity();
        mItemType = getArguments().getString(ARG_ITEM_TYPE);
        ItemHolderFactory itemHolderFactory = ItemHolderFactory.getHolderFactory(mItemType);
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
        getListView().setOnItemClickListener(this);
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        if (view.getTag() == null) return;

        // TODO: move into callbacks into activity

        Object item = mAdapter.getItem(position);
        if (item instanceof Set) {
            // Sets don't support detail display
            return;
        }
        String externalId = ((SetItem) item).getExternalId();

        ((ItemSelectedListener) getActivity()).onItemSelected(mItemType, externalId);
    }
}
