package com.funnyhatsoftware.spacedock;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
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
        void onSlotSelected(int slotType, String currentEquipmentId);
    }

    private final Activity mActivity;
    private final ExpandableListView mListView;
    private final SlotSelectCallback mCallback;
    private final ArrayList<EquippedShip> mEquippedShips;
    private ArrayList<ListItemLookup>[] mShipLookup;
    private long mSelectedPosition;
    private int mSelectedSlotType;
    private int mSelectedSlotIndex;

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
        final TextView mTextView;
        final TextView mCost;
        int mGroupPosition;
        int mChildPosition;
        ListItemLookup mListItemLookup;

        public SquadListItemHolder(int itemType, View item) {
            mItemType = itemType;

            TextView textView;
            textView = (TextView) item.findViewById(R.id.text);
            if (textView == null) textView = (TextView) item;
            mTextView = textView;
            mCost = (TextView) item.findViewById(R.id.cost); // null for headers
            mListItemLookup = null;
        }

        public void reinitialize(int groupPosition, int childPosition, ListItemLookup listItemLookup) {
            mGroupPosition = groupPosition;
            mChildPosition = childPosition;
            mListItemLookup = listItemLookup;
            if (mListItemLookup != null) {
                if (mListItemLookup.headerResId != INVALID_HEADER_ID) {
                    // Header, simply set text
                    mTextView.setText(mActivity.getResources().getString(mListItemLookup.headerResId));
                } else {
                    // Slot, set item & cost
                    EquipHelper.updateSlotCost(mEquippedShips.get(groupPosition), mTextView, mCost,
                            mListItemLookup.slotType, mListItemLookup.slotNumber);
                }
            } else {
                // Set equipped ship total cost
                EquipHelper.updateTotalCost(mEquippedShips.get(groupPosition), mCost);
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
        ((SquadListItemHolder)convertView.getTag()).reinitialize(groupPosition, childPosition, lookup);
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
        // TODO: ignore click on 2nd empty slot/make those unselectable/add slots as needed
        long packedPosition = ExpandableListView.getPackedPositionForChild(
                groupPosition, childPosition);

        if (packedPosition == mSelectedPosition) {
            // double selection... want to do anything here?
            return false;
        }
        int index = mListView.getFlatListPosition(packedPosition);
        mListView.setItemChecked(index, true);


        SquadListItemHolder holder = (SquadListItemHolder) v.getTag();

        // TODO: store selection, so that select slot -> rotate -> select item works
        mSelectedPosition = packedPosition;
        mSelectedSlotType = holder.mListItemLookup.slotType;
        mSelectedSlotIndex = holder.mListItemLookup.slotNumber;

        String currentEquipmentId = EquipHelper.getIdFromSlot(
                mEquippedShips.get(groupPosition), mSelectedSlotType, mSelectedSlotIndex);
        mCallback.onSlotSelected(holder.mListItemLookup.slotType, currentEquipmentId);
        return false;
    }

    public void onSetItemReturned(String externalId) {
        int groupPosition = ExpandableListView.getPackedPositionGroup(mSelectedPosition);
        EquippedShip equippedShip = mEquippedShips.get(groupPosition);
        EquipHelper.insertItem(externalId, equippedShip, mSelectedSlotType, mSelectedSlotIndex);
        notifyDataSetChanged();
    }
}
