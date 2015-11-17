package com.funnyhatsoftware.spacedock.fragment;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.ListFragment;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.Spinner;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.adapter.HeaderAdapter;
import com.funnyhatsoftware.spacedock.adapter.SeparatedListAdapter;
import com.funnyhatsoftware.spacedock.adapter.SetItemAdapter;
import com.funnyhatsoftware.spacedock.data.Set;
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
    private SetItemSelectedListener mListener;

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
        if (itemType == null) {
            throw new IllegalArgumentException("fragment must be given item type");
        }
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
        } else if (setItemHolderFactory.getType().equals("Expansion")) {
            SeparatedListAdapter multiAdapter = new SeparatedListAdapter(getActivity());
            ArrayList<Set> sets = Universe.getUniverse().getSets();
            ArrayList<String> sections = new ArrayList<String>();
            for (Set set : sets) {
                String section = set.getSection();
                if (!sections.contains(section)) {
                    sections.add(section);
                    SetItemAdapter setItemAdapter = SetItemAdapter.CreateFactionAdapter(context, section, layoutResId, setItemHolderFactory);
                    if (setItemAdapter != null) {
                        multiAdapter.addSection(section, setItemAdapter);
                    }
                }
            }
            contentAdapter = multiAdapter;
        } else {
            // item type not split into factions, use a single adapter
            contentAdapter = SetItemAdapter.CreateFactionAdapter(context,
                    null, layoutResId, setItemHolderFactory);
        }

        String currentSelectionId = getArguments().getString(ARG_SELECTED_ID);

        if (mSelectionMode && !setItemHolderFactory.getType().equals(CaptainHolder.TYPE_STRING)) {
            // Selecting upgrade (other than Captain): add a 'clear' item/placeholder at the top
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

        if (getParentFragment() != null) {
            mListener = (SetItemSelectedListener) getParentFragment();
        } else {
            mListener = (SetItemSelectedListener) getActivity();
        }
        if (mListener == null) throw new IllegalStateException();
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
        if (getParentFragment() != null && !getParentFragment().isMenuVisible()) { return; } // WAR
        inflater.inflate(R.menu.menu_set_item_list, menu);
        MenuItem item = menu.findItem(R.id.menu_faction_spinner);
        setupFactionSpinner((Spinner) item.getActionView());
    }

    private static boolean stringEquals(String a, String b) {
        // I love you, Java.
        if (a == null || b == null) {
            return a == null && b == null;
        }
        return a.equals(b);
    }

    private void setupFactionSpinner(Spinner spinner) {
        // Note: this assumes only a single SetItemListFragment, and faction spinner
        ArrayList<String> factions = new ArrayList<String>();
        factions.addAll(Universe.getUniverse().getAllFactions());
        factions.add(0, getActivity().getString(R.string.all_factions));

        // TODO: don't show factions with 0 items, will need to recreate adapter in reinitAdapter
        final ArrayAdapter<String> arrayAdapter = new ArrayAdapter<String>(
                getActivity().getActionBar().getThemedContext(),
                android.R.layout.simple_list_item_1, android.R.id.text1, factions);
        spinner.setAdapter(arrayAdapter);

        // preselect Universe's current selection
        String selectedFaction = Universe.getUniverse().getSelectedFaction();
        spinner.setSelection(selectedFaction == null ? 0 : factions.indexOf(selectedFaction));

        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                String faction = null;
                if (position > 0) {
                    faction = arrayAdapter.getItem(position);
                }

                String currentFaction = Universe.getUniverse().getSelectedFaction();
                if (!stringEquals(faction, currentFaction)) {
                    Universe.getUniverse().setSelectedFaction(faction);
                    reinitAdapter();
                }
            }
            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });
    }

    @Override
    public void onListItemClick(ListView listView, View view, int position, long id) {
        super.onListItemClick(listView, view, position, id);
        if (view.getTag() == null) return;

        SetItem item = (SetItem) mAdapter.getItem(position);
        String externalId = item.getExternalId();
        mListener.onItemSelected(mItemType, externalId);
        if (mItemType.equals(ShipHolder.TYPE_STRING) && externalId == null) {
            getFragmentManager().beginTransaction()
                    .remove(this)
                    .commit();
        }
    }
}
