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
import com.funnyhatsoftware.spacedock.SeparatedListAdapter;
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

    private static final int LAYOUT_RES_ID = R.layout.item_detailed; // force detailed in this view
    private int mSquadIndex; // index of squad being displayed

    public static DisplaySquadFragment newInstance(int squadIndex) {
        DisplaySquadFragment fragment = new DisplaySquadFragment();
        Bundle args = new Bundle();
        args.putInt(ARG_SQUAD_INDEX, squadIndex);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        Context context = getActivity();
        mSquadIndex = getArguments().getInt(ARG_SQUAD_INDEX);
        Squad squad = Universe.getUniverse().squads.get(mSquadIndex);
        final SeparatedListAdapter multiAdapter = new SeparatedListAdapter(context) {
            @Override
            public boolean isEnabled(int position) {
                // TODO: this is gross, have SeparatedListAdapter defer isEnabled() to subadapters
                return false;
            }
        };

        for (EquippedShip equippedShip : squad.getEquippedShips()) {
            ArrayList<Object> itemList = new ArrayList<Object>();
            itemList.add(equippedShip.getShip());
            for (EquippedUpgrade equippedUpgrade : equippedShip.getUpgrades()) {
                Upgrade upgrade = equippedUpgrade.getUpgrade();
                if (!upgrade.isPlaceholder()) {
                    itemList.add(upgrade);
                }
            }
            multiAdapter.addSection(equippedShip.getTitle(), new MultiItemAdapter(context, itemList));
        }
        setListAdapter(multiAdapter);
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
        public MultiItemAdapter(Context context, ArrayList<Object> items) {
            super(context, 0, items);
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
