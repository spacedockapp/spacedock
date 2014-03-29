package com.funnyhatsoftware.spacedock.fragment;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.ListFragment;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.ListView;

import com.funnyhatsoftware.spacedock.SetItemAdapter;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.SeparatedListAdapter;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.holder.SetItemHolderFactory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

public class SetItemListFragment extends ListFragment {
    private static final String ARG_ITEM_TYPE = "item_type";
    private static final String ARG_PRIORITIZED_FACTION = "prior_faction";
    private static final String ARG_SELECTED_ID = "item_sel";

    public interface SetItemSelectedListener {
        public void onItemSelected(String itemType, String itemId);
    }

    private BaseAdapter mAdapter;
    private String mItemType;

    /**
     * Creates a SetItemListFragment
     */
    public static SetItemListFragment newInstance(String itemType,
            String prioritizedFaction, String currentId) {
        SetItemListFragment fragment = new SetItemListFragment();
        Bundle arguments = new Bundle();
        arguments.putString(SetItemListFragment.ARG_ITEM_TYPE, itemType);
        arguments.putString(SetItemListFragment.ARG_PRIORITIZED_FACTION, prioritizedFaction);
        arguments.putString(SetItemListFragment.ARG_SELECTED_ID, currentId);
        fragment.setArguments(arguments);
        return fragment;
    }

    private ArrayList<String> getOrderedFactions() {
        ArrayList<String> factions = new ArrayList<String>(Universe.getUniverse().getSelectedFactions());

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

    public void initializeAdapter() {
        Context context = getActivity();
        final int layoutResId = getLayoutResId();

        SetItemHolderFactory setItemHolderFactory = SetItemHolderFactory.getHolderFactory(mItemType);
        if (setItemHolderFactory.usesFactions()) {
            // add a combination of faction-specific adapters together
            final SeparatedListAdapter multiAdapter = new SeparatedListAdapter(getActivity());

            ArrayList<String> factions = getOrderedFactions();
            for (String faction : factions) {
                SetItemAdapter factionAdapter = new SetItemAdapter(context, faction,
                        layoutResId, setItemHolderFactory);
                if (factionAdapter.getCount() > 0) {
                    multiAdapter.addSection(faction, factionAdapter);
                }
            }
            mAdapter = multiAdapter;
        } else {
            // item type not split into factions, use a single adapter
            mAdapter = new SetItemAdapter(context, null, layoutResId, setItemHolderFactory);
        }
        setListAdapter(mAdapter);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if ((getArguments() == null) || !getArguments().containsKey(ARG_ITEM_TYPE)) {
            throw new IllegalArgumentException("Invalid fragment arguments, must contain type");
        }

        mItemType = getArguments().getString(ARG_ITEM_TYPE);
        initializeAdapter();
    }

    @Override
    public void onListItemClick(ListView listView, View view, int position, long id) {
        super.onListItemClick(listView, view, position, id);
        if (view.getTag() == null) return;

        // TODO: move into callbacks into activity

        SetItem item = (SetItem) mAdapter.getItem(position);
        String externalId = item.getExternalId();
        ((SetItemSelectedListener) getActivity()).onItemSelected(mItemType, externalId);
    }
}
