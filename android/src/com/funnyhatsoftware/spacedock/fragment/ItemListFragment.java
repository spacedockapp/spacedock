package com.funnyhatsoftware.spacedock.fragment;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.ListFragment;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.ListView;

import com.funnyhatsoftware.spacedock.ItemAdapter;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.SeparatedListAdapter;
import com.funnyhatsoftware.spacedock.data.Set;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.holder.ItemHolderFactory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

public class ItemListFragment extends ListFragment {
    private static final String ARG_ITEM_TYPE = "item_type";
    private static final String ARG_PRIORITIZED_FACTION = "prior_faction";
    private static final String ARG_SELECTED_ID = "item_sel";

    public interface ItemSelectedListener {
        public void onItemSelected(String itemType, String itemId);
    }

    private BaseAdapter mAdapter;
    private String mItemType;

    /**
     * Creates a ItemListFragment
     */
    public static ItemListFragment newInstance(String itemType,
            String prioritizedFaction, String currentId) {
        ItemListFragment fragment = new ItemListFragment();
        Bundle arguments = new Bundle();
        arguments.putString(ItemListFragment.ARG_ITEM_TYPE, itemType);
        arguments.putString(ItemListFragment.ARG_PRIORITIZED_FACTION, prioritizedFaction);
        arguments.putString(ItemListFragment.ARG_SELECTED_ID, currentId);
        fragment.setArguments(arguments);
        return fragment;
    }

    private ArrayList<String> getOrderedFactions() {
        ArrayList<String> factions = new ArrayList<String>(Universe.getUniverse().getAllFactions());

        final String prioritizedFaction = getArguments().getString(ARG_PRIORITIZED_FACTION);
        if (prioritizedFaction != null){
            Collections.sort(factions, new Comparator<String>() {
                @Override
                public int compare(String lhs, String rhs) {
                    if (lhs.equals(prioritizedFaction)) return -1;
                    if (rhs.equals(prioritizedFaction)) return 1;
                    return lhs.compareTo(rhs);
                }
            });
        }
        return factions;
    }

    private int getLayoutResId() {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(getActivity());
        if (prefs.getBoolean("pref_key_show_details", true)) {
            return R.layout.item_detailed;
        } else {
            return R.layout.item_base;
        }
    }


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if ((getArguments() == null) || !getArguments().containsKey(ARG_ITEM_TYPE)) {
            throw new IllegalArgumentException("Invalid fragment arguments, must contain type");
        }

        Context context = getActivity();
        mItemType = getArguments().getString(ARG_ITEM_TYPE);

        final int layoutResId = getLayoutResId();

        ItemHolderFactory itemHolderFactory = ItemHolderFactory.getHolderFactory(mItemType);
        if (itemHolderFactory.usesFactions()) {
            // add a combination of faction-specific adapters together
            final SeparatedListAdapter multiAdapter = new SeparatedListAdapter(getActivity());

            ArrayList<String> factions = getOrderedFactions();
            for (String faction : factions) {
                ItemAdapter factionAdapter = new ItemAdapter(context, faction,
                        layoutResId, itemHolderFactory);
                if (factionAdapter.getCount() > 0) {
                    multiAdapter.addSection(faction, factionAdapter);
                }
            }
            mAdapter = multiAdapter;
        } else {
            // item type not split into factions, use a single adapter
            mAdapter = new ItemAdapter(context, null, layoutResId, itemHolderFactory);
        }
        setListAdapter(mAdapter);
    }

    @Override
    public void onListItemClick(ListView listView, View view, int position, long id) {
        super.onListItemClick(listView, view, position, id);
        if (view.getTag() == null) return;

        // TODO: move into callbacks into activity

        Object item = mAdapter.getItem(position);
        if (item instanceof Set) {
            // Sets don't support activation
            return;
        }

        String externalId = ((SetItem) item).getExternalId();
        ((ItemSelectedListener) getActivity()).onItemSelected(mItemType, externalId);
    }
}
