package com.funnyhatsoftware.spacedock;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.EquippedShip;

import java.util.ArrayList;

public class SquadListAdapter extends BaseExpandableListAdapter
        implements ExpandableListView.OnChildClickListener {
    private static final int INVALID_HEADER_ID = 0;

    private static final int ITEM_TYPE_HEADER = 0;
    private static final int ITEM_TYPE_SLOT = 1;
    private static final int ITEM_TYPE_GROUP = 2;

    private static final int[] LAYOUT_FOR_ITEM_TYPE = {
            R.layout.squad_list_header,
            R.layout.squad_list_slot,
            R.layout.squad_list_group,
    };

    public interface SlotSelectCallback {
        void onSlotSelected(int equippedShipNumber, int slotType, int slotNumber,
                String currentEquipmentId);
    }

    private final Activity mActivity;
    private final ExpandableListView mListView;
    private final SlotSelectCallback mCallback;
    private final ArrayList<EquippedShip> mEquippedShips;
    private ArrayList<ListItemLookup>[] mShipLookup;

    //////////////////////////////////////////////////////////////////
    // Lookup - groupNr,childNr to View type mapping
    //////////////////////////////////////////////////////////////////
    private static ListItemLookup makeHeader(int headerResId) {
        ListItemLookup listItemLookup = new ListItemLookup();
        listItemLookup.headerResId = headerResId;
        return listItemLookup;
    }
    private static ListItemLookup makeSlot(int slotType, int slotNumber) {
        ListItemLookup listItemLookup = new ListItemLookup();
        listItemLookup.slotType = slotType;
        listItemLookup.slotNumber = slotNumber;
        return listItemLookup;
    }
    private static class ListItemLookup {
        int headerResId = INVALID_HEADER_ID;
        int slotType = EquipHelper.SLOT_TYPE_INVALID;
        int slotNumber = 0;
    }
    private static void populateLookup(ArrayList<ListItemLookup> arrayList, int count,
            int headerResId, int slotType) {
        if (count > 0) {
            arrayList.add(makeHeader(headerResId));
            for (int i = 0; i < count; i++) {
                arrayList.add(makeSlot(slotType, i));
            }
        }
    }
    private void updateLookup() {
        mShipLookup = new ArrayList[mEquippedShips.size()];
        for (int i = 0; i < mEquippedShips.size(); i++) {
            ArrayList<ListItemLookup> l = new ArrayList<ListItemLookup>();
            EquippedShip s = mEquippedShips.get(i);
            populateLookup(l, 1, R.string.ship_slot, EquipHelper.SLOT_TYPE_SHIP);
            if (s.getShip() != null) {
                populateLookup(l, 1, R.string.captain_slot, EquipHelper.SLOT_TYPE_CAPTAIN);
                populateLookup(l, s.getCrew(), R.string.crew_slot, EquipHelper.SLOT_TYPE_CREW);
                populateLookup(l, s.getWeapon(), R.string.weapon_slot, EquipHelper.SLOT_TYPE_WEAPON);
                populateLookup(l, s.getTech(), R.string.tech_slot, EquipHelper.SLOT_TYPE_TECH);
            }
            mShipLookup[i] = l;
        }
    }
    @Override
    public void notifyDataSetChanged() {
        updateLookup();
        super.notifyDataSetChanged();
    }

    //////////////////////////////////////////////////////////////////
    // Holder
    //////////////////////////////////////////////////////////////////
    private View buildItem(ViewGroup parent, int itemType) {
        LayoutInflater inflater = mActivity.getLayoutInflater();
        View item = inflater.inflate(LAYOUT_FOR_ITEM_TYPE[itemType], parent, false);
        item.setTag(new SquadListItemHolder(itemType, item));
        return item;
    }

    private class SquadListItemHolder {
        final int mItemType;
        final TextView mTitleText;
        final TextView mCostText;
        int mGroupPosition;
        int mChildPosition;
        ListItemLookup mListItemLookup;

        public SquadListItemHolder(int itemType, View item) {
            mItemType = itemType;

            mTitleText = (TextView) item.findViewById(R.id.title);
            mCostText = (TextView) item.findViewById(R.id.cost); // null for headers
            mListItemLookup = null;
        }

        public void reinitialize(int groupPosition, int childPosition,
                    ListItemLookup listItemLookup) {
            mGroupPosition = groupPosition;
            mChildPosition = childPosition;
            mListItemLookup = listItemLookup;
            if (mListItemLookup != null) {
                if (mListItemLookup.headerResId != INVALID_HEADER_ID) {
                    // Header, simply set text
                    String headerText = mActivity.getResources().getString(
                            mListItemLookup.headerResId);
                    mTitleText.setText(headerText);
                } else {
                    // Slot, set title & cost
                    EquipHelper.updateSlotCost(mEquippedShips.get(groupPosition),
                            mTitleText, mCostText,
                            mListItemLookup.slotType, mListItemLookup.slotNumber);
                }
            } else {
                // Set equipped ship total cost
                EquipHelper.updateTotalCost(mEquippedShips.get(groupPosition), mCostText);
            }
        }
    }

    public SquadListAdapter(Activity activity, ExpandableListView listView,
            ArrayList<EquippedShip> equippedShips, SlotSelectCallback callback) {
        // TODO: always maintain one empty extra ship to support add/remove
        mActivity = activity;
        mListView = listView;
        mEquippedShips = equippedShips;
        mCallback = callback;
        updateLookup();
        mListView.setOnChildClickListener(this);
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }

    @Override
    public int getChildType(int groupPosition, int childPosition) {
        int headerResId = mShipLookup[groupPosition].get(childPosition).headerResId;
        return headerResId == INVALID_HEADER_ID ? ITEM_TYPE_SLOT : ITEM_TYPE_HEADER;
    }

    @Override
    public int getChildTypeCount() {
        return 2;
    }

    @Override
    public int getGroupCount() {
        return mEquippedShips.size();
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return mShipLookup[groupPosition].size();
    }

    @Override
    public Object getGroup(int groupPosition) {
        return mEquippedShips.get(groupPosition);
    }

    @Override
    public Object getChild(int groupPosition, int childPosition) {
        return null;
    }

    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }

    @Override
    public long getChildId(int groupPosition, int childPosition) {
        return childPosition;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded,
            View convertView, ViewGroup parent) {
        if (convertView == null) {
            convertView = buildItem(parent, ITEM_TYPE_GROUP);
        }
        ((SquadListItemHolder)convertView.getTag()).reinitialize(groupPosition, -1, null);
        return convertView;
    }

    @Override
    public View getChildView(int groupPosition, int childPosition, boolean isLastChild,
            View convertView, ViewGroup parent) {
        ListItemLookup lookup = mShipLookup[groupPosition].get(childPosition);
        int itemType = lookup.headerResId == INVALID_HEADER_ID ? ITEM_TYPE_SLOT : ITEM_TYPE_HEADER;

        if (convertView == null) {
            convertView = buildItem(parent, itemType);
        }
        SquadListItemHolder holder = (SquadListItemHolder)convertView.getTag();
        holder.reinitialize(groupPosition, childPosition, lookup);
        return convertView;
    }

    @Override
    public boolean isChildSelectable(int groupPosition, int childPosition) {
        // only non-headers are selectable
        int headerResId = mShipLookup[groupPosition].get(childPosition).headerResId;
        return headerResId == INVALID_HEADER_ID;
    }

    @Override
    public boolean onChildClick(ExpandableListView parent, View v,
            int groupPosition, int childPosition, long id) {
        long packedPosition = ExpandableListView.getPackedPositionForChild(
                groupPosition, childPosition);

        int index = mListView.getFlatListPosition(packedPosition);
        if (mListView.getChoiceMode() != AbsListView.CHOICE_MODE_NONE) {
            if (packedPosition == mListView.getSelectedPosition()) {
                return false; // do nothing for double select
            }
            mListView.setItemChecked(index, true);
        }

        SquadListItemHolder holder = (SquadListItemHolder) v.getTag();

        int slotType = holder.mListItemLookup.slotType;
        int slotNumber = holder.mListItemLookup.slotNumber;
        String currentEquipmentId = EquipHelper.getIdFromSlot(
                mEquippedShips.get(groupPosition), slotType, slotNumber);
        mCallback.onSlotSelected(groupPosition, slotType, slotNumber, currentEquipmentId);
        return false;
    }

    public void onSetItemReturned(int equippedShipNumber, int slotType, int slotIndex,
                String externalId) {
        EquippedShip equippedShip = mEquippedShips.get(equippedShipNumber);
        EquipHelper.insertItem(externalId, equippedShip, slotType, slotIndex);
        notifyDataSetChanged();
    }
}
