
package com.funnyhatsoftware.spacedock.fragment;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
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
import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Upgrade;
import com.funnyhatsoftware.spacedock.holder.SetItemHolder;
import com.funnyhatsoftware.spacedock.holder.SetItemHolderFactory;

import org.json.JSONException;

import java.util.ArrayList;

public class DisplaySquadFragment extends FullscreenListFragment {
    private static final String ARG_SQUAD_UUID = "squad_index";

    // force detailed item display in this view
    private static final int LAYOUT_RES_ID = R.layout.item_with_details;

    String mSquadUuid;

    public static DisplaySquadFragment newInstance(String squadUuid) {
        if (squadUuid == null) {
            throw new IllegalArgumentException("squad uuid required");
        }

        DisplaySquadFragment fragment = new DisplaySquadFragment();
        Bundle args = new Bundle();
        args.putString(ARG_SQUAD_UUID, squadUuid);
        fragment.setArguments(args);
        return fragment;
    }

    private void initAdapter() {
        Context context = getActivity();

        Squad squad = Universe.getUniverse().getSquadByUUID(mSquadUuid);
        if (squad == null) {
            // fragment now invalid, detach
            getFragmentManager().beginTransaction()
                    .remove(this)
                    .commit();
            return;
        }

        // build adapters mapping each ship title to its list of ship + upgrades
        ArrayList<MultiItemAdapter> subAdapters = new ArrayList<MultiItemAdapter>();
        for (EquippedShip equippedShip : squad.getEquippedShips()) {
            ArrayList<Object> itemList = new ArrayList<Object>();
            Ship ship = equippedShip.getShip();
            if (ship != null) {
                itemList.add(ship);
            }
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
                // TODO: this is gross, have SeparatedListAdapter defer
                // isEnabled() to subadapters
                return false;
            }
        };

        // handle duplicate ship titles by appending unique indices on
        // duplicates
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

        mSquadUuid = getArguments().getString(ARG_SQUAD_UUID);
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

    private void copySquadToClipboard() {
        Squad squad = Universe.getUniverse().getSquadByUUID(mSquadUuid);
        if (squad != null) {
            ClipboardManager clipboard = (ClipboardManager) getActivity().getSystemService(
                    Context.CLIPBOARD_SERVICE);
            ClipData newPlainText = ClipData.newPlainText("squad as text",
                    squad.asPlainTextFormat());
            clipboard.setPrimaryClip(newPlainText);
        }
    }

    private void shareSquad() {
        Squad squad = Universe.getUniverse().getSquadByUUID(mSquadUuid);
        if (squad != null) {
            try {
                Intent sendIntent = new Intent();
                sendIntent.setAction(Intent.ACTION_SEND);
                sendIntent.putExtra(Intent.EXTRA_TEXT, squad.asJSON().toString(2));
                String fullName = String.format("%s.spacedock", squad.getName());
                sendIntent.putExtra(android.content.Intent.EXTRA_SUBJECT, fullName);
                sendIntent.setType("application/spacedock");
                startActivity(Intent.createChooser(sendIntent, "Save squad to:"));
            } catch (JSONException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        final int itemId = item.getItemId();
        final Context context = getActivity();

        if (itemId == R.id.menu_duplicate) {
            Toast.makeText(context, "Text description of squad copied to clipboard.",
                    Toast.LENGTH_SHORT).show();
            copySquadToClipboard();
            return true;
        }
        if (itemId == R.id.menu_share) {
            shareSquad();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private static class MultiItemAdapter extends ArrayAdapter<Object> {
        private String mTitle;

        public String getTitle() {
            return mTitle;
        }

        public void appendTitleIndex(int index) {
            mTitle += " " + Integer.toString(index);
        }

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
            Object item = getItem(position);
            Class clazz = item.getClass();
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
