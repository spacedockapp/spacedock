package com.funnyhatsoftware.spacedock.fragment;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.support.v4.util.ArrayMap;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Toast;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.adapter.SeparatedListAdapter;
import com.funnyhatsoftware.spacedock.data.EquippedShip;
import com.funnyhatsoftware.spacedock.data.EquippedUpgrade;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Upgrade;
import com.funnyhatsoftware.spacedock.holder.SetItemHolder;
import com.funnyhatsoftware.spacedock.holder.SetItemHolderFactory;

import java.util.ArrayList;

public class DisplaySquadFragment extends ListFragment {
    private static final String ARG_SQUAD_INDEX = "squad_index";

    public interface SquadDisplayListener {
        public void onSquadEditAction(int squadIndex);
    }

    private static final int LAYOUT_RES_ID = R.layout.item_with_details; // force detailed in this view
    private int mSquadIndex; // index of squad being displayed

    public static DisplaySquadFragment newInstance(int squadIndex) {
        if (squadIndex >= Universe.getUniverse().getAllSquads().size()) {
            throw new IllegalArgumentException("can't display missing squad " + squadIndex);
        }

        DisplaySquadFragment fragment = new DisplaySquadFragment();
        Bundle args = new Bundle();
        args.putInt(ARG_SQUAD_INDEX, squadIndex);
        fragment.setArguments(args);
        return fragment;
    }

    private void initAdapter() {
        Context context = getActivity();

        if (mSquadIndex >= Universe.getUniverse().getAllSquads().size()) {
            // fragment now invalid, detach
            getFragmentManager().beginTransaction().remove(this).commit();
            return;
        }

        // build adapters mapping each ship title to its list of ship + upgrades
        Squad squad = Universe.getUniverse().getSquad(mSquadIndex);
        ArrayList<MultiItemAdapter> subAdapters = new ArrayList<MultiItemAdapter>();
        for (EquippedShip equippedShip : squad.getEquippedShips()) {
            ArrayList<Object> itemList = new ArrayList<Object>();
            itemList.add(equippedShip.getShip());
            for (EquippedUpgrade equippedUpgrade : equippedShip.getUpgrades()) {
                Upgrade upgrade = equippedUpgrade.getUpgrade();
                if (!upgrade.isPlaceholder()) {
                    itemList.add(upgrade);
                }
            }
            subAdapters.add(new MultiItemAdapter(context, equippedShip.getTitle(), itemList));
        }

        final SeparatedListAdapter multiAdapter = new SeparatedListAdapter(context) {
            @Override
            public boolean isEnabled(int position) {
                // TODO: this is gross, have SeparatedListAdapter defer isEnabled() to subadapters
                return false;
            }
        };

        // handle duplicate ship titles by appending unique indices on duplicates
        for (int i = 0; i < subAdapters.size(); i++) {
            MultiItemAdapter adapter = subAdapters.get(i);
            int renameIndex = -1;
            for (int j = i + 1; j < subAdapters.size(); j++) {
                MultiItemAdapter otherAdapter = subAdapters.get(j);
                if (adapter.getTitle().equals(otherAdapter.getTitle())) {
                    if (renameIndex < 0) {
                        // found 1st dupe, start labelling at index 2
                        renameIndex = 2;
                    }
                    otherAdapter.appendTitleIndex(renameIndex);
                    renameIndex++;
                }
            }
            if (renameIndex >= 0) {
                // now rename the original ship
                adapter.appendTitleIndex(1);
            }

            multiAdapter.addSection(adapter.getTitle(), adapter);
        }
        setListAdapter(multiAdapter);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        mSquadIndex = getArguments().getInt(ARG_SQUAD_INDEX);
    }

    @Override
    public void onResume() {
        super.onResume();

        // recreate adapter from scratch, since squad contents may have changed
        initAdapter();
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        inflater.inflate(R.menu.menu_display_squad, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        final int itemId = item.getItemId();
        final Context context = getActivity();

        if (itemId == R.id.menu_edit) {
            ((SquadDisplayListener)getActivity()).onSquadEditAction(mSquadIndex);
            return true;
        } else if (itemId == R.id.menu_share) {
            Toast.makeText(context, "TODO: sharing.", Toast.LENGTH_SHORT).show();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private static class MultiItemAdapter extends ArrayAdapter<Object> {
        private String mTitle;
        public String getTitle() { return mTitle; }
        public void appendTitleIndex(int index) { mTitle += " " + Integer.toString(index); }

        public MultiItemAdapter(Context context, String title, ArrayList<Object> items) {
            super(context, 0, items);
            mTitle = title;
        }

        @Override
        public int getViewTypeCount() {
            return SetItemHolderFactory.getFactoryTypes().size();
        }

        // Maps seen types->unique integers for recycling differentiation
        private final ArrayMap<Class, Integer> mTypeMap =
                new ArrayMap<Class, Integer>();

        @Override
        public int getItemViewType(int position) {
            Class clazz = getItem(position).getClass();
            if (!mTypeMap.containsKey(clazz)) {
                mTypeMap.put(clazz, mTypeMap.size());
            }
            return mTypeMap.get(clazz);
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            Object item = getItem(position);
            SetItemHolder holder;
            if (convertView == null) {
                SetItemHolderFactory setItemHolderFactory =
                        SetItemHolderFactory.getHolderFactory(item.getClass());

                Context context = getContext();
                LayoutInflater inflater = ((Activity) context).getLayoutInflater();
                convertView = inflater.inflate(LAYOUT_RES_ID, parent, false);
                holder = setItemHolderFactory.createHolder(convertView);
                convertView.setTag(holder);
            } else {
                holder = (SetItemHolder) convertView.getTag();
            }
            holder.reinitialize(getContext().getResources(), item);
            return convertView;
        }
    }
}
