package com.funnyhatsoftware.spacedock.fragment;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.ListFragment;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.ListView;

import com.funnyhatsoftware.spacedock.HeaderAdapter;
import com.funnyhatsoftware.spacedock.SetItemAdapter;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.SeparatedListAdapter;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.holder.CaptainHolder;
import com.funnyhatsoftware.spacedock.holder.SetItemHolderFactory;
import com.funnyhatsoftware.spacedock.holder.ShipHolder;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

public class SetItemListFragment extends ListFragment {
    private static final String ARG_IS_SELECTING = "selection";
    private static final String ARG_ITEM_TYPE = "item_type";
    private static final String ARG_PRIORITIZED_FACTION = "prior_faction";
    private static final String ARG_SELECTED_ID = "item_sel";


    public interface SetItemSelectedListener {
        public void onItemSelected(String itemType, String itemId);
    }

    private boolean mSelectionMode;
    private BaseAdapter mAdapter;
    private String mItemType;

    /**
     * Creates a SetItemListFragment for display
     */
    public static SetItemListFragment newInstance(String itemType) {
        return newInstance(false, itemType, null, null);
    }

    /**
     * Creates a SetItemListFragment for item selection
     */
    public static SetItemListFragment newInstance(String itemType,
            String prioritizedFaction, String currentId) {
        return newInstance(true, itemType, prioritizedFaction, currentId);
    }

    private static SetItemListFragment newInstance(boolean selectionMode,
            String itemType, String prioritizedFaction, String currentId) {
        SetItemListFragment fragment = new SetItemListFragment();
        Bundle arguments = new Bundle();
        arguments.putBoolean(ARG_IS_SELECTING, selectionMode);
        arguments.putString(ARG_ITEM_TYPE, itemType);
        arguments.putString(ARG_PRIORITIZED_FACTION, prioritizedFaction);
        arguments.putString(ARG_SELECTED_ID, currentId);
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
            return R.layout.item_with_details;
        } else {
            return R.layout.item_no_details;
        }
    }

    public void reinitAdapter() {
        Context context = getActivity();
        final int layoutResId = getLayoutResId();

        SetItemHolderFactory setItemHolderFactory = SetItemHolderFactory.getHolderFactory(mItemType);

        BaseAdapter contentAdapter;
        if (setItemHolderFactory.usesFactions()) {
            SeparatedListAdapter multiAdapter = new SeparatedListAdapter(getActivity());
            // add a combination of faction-specific adapters together
            ArrayList<String> factions = getOrderedFactions();
            for (String faction : factions) {
                SetItemAdapter factionAdapter = SetItemAdapter.CreateFactionAdapter(context,
                        faction, layoutResId, setItemHolderFactory);
                if (factionAdapter != null) {
                    multiAdapter.addSection(faction, factionAdapter);
                }
            }
            contentAdapter = multiAdapter;
        } else {
            // item type not split into factions, use a single adapter
            contentAdapter = SetItemAdapter.CreateFactionAdapter(context,
                    null, layoutResId, setItemHolderFactory);
        }

        if (mSelectionMode
                && !setItemHolderFactory.getType().equals(ShipHolder.TYPE_STRING)
                && !setItemHolderFactory.getType().equals(CaptainHolder.TYPE_STRING)) {
            // when selecting upgrades (other than Captain) add a 'clear' item/placeholder at the top
            BaseAdapter placeholderAdapter = SetItemAdapter.CreatePlaceholderAdapter(context,
                    layoutResId, setItemHolderFactory);
            mAdapter = new HeaderAdapter(placeholderAdapter, contentAdapter);
        } else {
            mAdapter = contentAdapter;
        }

        setListAdapter(mAdapter);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        if ((getArguments() == null) || !getArguments().containsKey(ARG_ITEM_TYPE)) {
            throw new IllegalArgumentException("Invalid fragment arguments, must contain type");
        }

        mSelectionMode = getArguments().getBoolean(ARG_IS_SELECTING);
        mItemType = getArguments().getString(ARG_ITEM_TYPE);
    }

    @Override
    public void onResume() {
        super.onResume();

        // (re)initialize adapter here, since settings may have changed detail display
        reinitAdapter();
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        inflater.inflate(R.menu.menu_set_item_list, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        final int itemId = item.getItemId();
        if (itemId == R.id.menu_faction) {
            FragmentManager fm = getFragmentManager();
            ChooseFactionDialog chooseFactionDialog = new ChooseFactionDialog();
            chooseFactionDialog.show(fm, "fragment_faction_list");
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onListItemClick(ListView listView, View view, int position, long id) {
        super.onListItemClick(listView, view, position, id);
        if (view.getTag() == null) return;

        SetItem item = (SetItem) mAdapter.getItem(position);
        String externalId = item.getExternalId();
        ((SetItemSelectedListener) getActivity()).onItemSelected(mItemType, externalId);
    }
}
