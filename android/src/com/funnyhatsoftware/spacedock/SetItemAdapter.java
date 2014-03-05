package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import android.content.Context;
import android.content.res.Resources;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import com.funnyhatsoftware.spacedock.data.EquippedShip;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Upgrade;

public class SetItemAdapter extends ArrayAdapter<SetItemAdapter.SetItemWrapper> {

    public static class SetItemWrapper {
        SetItem item;
        SetItemWrapper(SetItem item) {
            this.item = item;
        }

        public String getExternalId() { return item.getExternalId(); }

        @Override
        public String toString() {
            return item.getTitle();
        }
    }
    public static class PlaceholderWrapper extends SetItemWrapper {
        private String mTitle;
        PlaceholderWrapper(String title) {
            super(null);
            mTitle = title;
        }

        @Override
        public String getExternalId() { return ""; }

        @Override
        public String toString() {
            return mTitle;
        }
    }

    private static class SetItemComparator implements Comparator<SetItemWrapper> {
        String mTopFaction;
        public SetItemComparator(String topFaction) {
            mTopFaction = (topFaction == null) ? "" : topFaction;
        }

        @Override
        public int compare(SetItemWrapper lhs, SetItemWrapper rhs) {
            // sort first by faction, prioritizing top faction
            boolean lhsTopFaction = lhs.item.getFaction().equals(mTopFaction);
            boolean rhsTopFaction = rhs.item.getFaction().equals(mTopFaction);
            int factionCompare = lhs.item.getFaction().compareTo(rhs.item.getFaction());
            if (factionCompare != 0) {
                if (lhsTopFaction) return -1;
                if (rhsTopFaction) return 1;

                return factionCompare;
            }

            // then cost
            int costCompare = lhs.item.getCost() - rhs.item.getCost();
            if (costCompare != 0) return costCompare;

            // then title
            return lhs.item.getTitle().compareTo(rhs.item.getTitle());
        }
    }

    private static List<SetItemWrapper> getItemsForSlot(Resources res,
            int slotType, String topFaction) {
        List<SetItemWrapper> items = new ArrayList<SetItemWrapper>();
        Universe universe = Universe.getUniverse();

        if (slotType == EquippedShip.SLOT_TYPE_CAPTAIN) {
            for (int i = 0; i < universe.captains.size(); i++) {
                items.add(new SetItemWrapper(universe.captains.valueAt(i)));
            }
        } else if (slotType == EquippedShip.SLOT_TYPE_SHIP) {
            for (int i = 0; i < universe.ships.size(); i++) {
                items.add(new SetItemWrapper(universe.ships.valueAt(i)));
            }
        } else {
            for (int i = 0; i < universe.upgrades.size(); i++) {
                Upgrade upgrade = universe.upgrades.valueAt(i);
                if (upgrade.getClass() == EquippedShip.CLASS_FOR_SLOT[slotType]) {
                    items.add(new SetItemWrapper(upgrade));
                }
            }
        }
        Collections.sort(items, new SetItemComparator(topFaction));

        if (slotType != EquippedShip.SLOT_TYPE_SHIP
                && slotType != EquippedShip.SLOT_TYPE_CAPTAIN) {
            // Add a clear upgrade option at the top for most upgrade types.
            // Ships don't have placeholders, and captains don't need them
            items.add(0, new PlaceholderWrapper(res.getString(R.string.clear_upgrade_slot)));
        }
        return items;
    }

    private final int mSlotType;

    public SetItemAdapter(Context context, int slotType, String topFaction) {
        super(context, SetItemHolder.getLayoutForSlot(slotType), R.id.title,
                getItemsForSlot(context.getResources(), slotType, topFaction));
        mSlotType = slotType;
    }

    public String getItemExternalId(int i) {
        return getItem(i).getExternalId();
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View listItem = super.getView(position, convertView, parent);
        assert(listItem != null);

        SetItemHolder holder = (SetItemHolder) listItem.getTag();
        if (holder == null) {
            holder = SetItemHolder.createHolder(listItem, mSlotType);
            listItem.setTag(holder);
        }

        holder.reinitialize(parent.getResources(), getItem(position).item);
        return listItem;
    }
}
