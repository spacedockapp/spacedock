package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.EquippedShip;
import com.funnyhatsoftware.spacedock.data.EquippedUpgrade;
import com.funnyhatsoftware.spacedock.data.Squad;

public class EditSquadAdapter extends BaseExpandableListAdapter
        implements ExpandableListView.OnChildClickListener, AdapterView.OnItemClickListener {
    private static final int INVALID_HEADER_ID = 0;

    private static final int ITEM_TYPE_HEADER = 0;
    private static final int ITEM_TYPE_SLOT = 1;
    private static final int ITEM_TYPE_GROUP = 2;

    private static final int[] LAYOUT_FOR_ITEM_TYPE = {
            R.layout.squad_list_header,
            R.layout.squad_list_slot,
            R.layout.squad_list_group,
    };


    private final Activity mActivity;
    private final ExpandableListView mListView;
    private final EditSquadFragment.SlotSelectCallback mCallback;
    private final Squad mSquad;
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
        int slotType = EquippedShip.SLOT_TYPE_INVALID;
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
        mShipLookup = new ArrayList[mSquad.getEquippedShips().size()];
        for (int i = 0; i < mSquad.getEquippedShips().size(); i++) {
            ArrayList<ListItemLookup> l = new ArrayList<ListItemLookup>();
            EquippedShip s = mSquad.getEquippedShips().get(i);
            if (s.getShip() == null) throw new IllegalStateException();
            populateLookup(l, 1, R.string.captain_slot, EquippedShip.SLOT_TYPE_CAPTAIN);
            populateLookup(l, s.getCrew(), R.string.crew_slot, EquippedShip.SLOT_TYPE_CREW);
            populateLookup(l, s.getWeapon(), R.string.weapon_slot, EquippedShip.SLOT_TYPE_WEAPON);
            populateLookup(l, s.getTech(), R.string.tech_slot, EquippedShip.SLOT_TYPE_TECH);
            populateLookup(l, s.getTalent(), R.string.talent_slot, EquippedShip.SLOT_TYPE_TALENT);
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

        if (item == null) throw new IllegalStateException("View inflation failed!");
        item.setTag(new SquadListItemHolder(itemType, item));
        return item;
    }

    private class SquadListItemHolder {
        final int mItemType;
        final TextView mTitleTextView;
        final TextView mCostTextView;
        int mGroupPosition;
        int mChildPosition;
        ListItemLookup mListItemLookup;

        public SquadListItemHolder(int itemType, View item) {
            mItemType = itemType;

            mTitleTextView = (TextView) item.findViewById(R.id.title);
            mCostTextView = (TextView) item.findViewById(R.id.cost); // null for headers
            mListItemLookup = null;

            if (mTitleTextView == null || (mCostTextView == null && mItemType != ITEM_TYPE_HEADER)) {
                throw new IllegalStateException();
            }
        }

        public void reinitialize(int groupPosition, int childPosition,
                    ListItemLookup listItemLookup) {
            mGroupPosition = groupPosition;
            mChildPosition = childPosition;
            mListItemLookup = listItemLookup;

            final EquippedShip es = getEquippedShip(mGroupPosition);
            switch(mItemType) {
                case ITEM_TYPE_HEADER:
                    // Header, simply set text
                    String headerText = mActivity.getResources().getString(
                            mListItemLookup.headerResId);
                    mTitleTextView.setText(headerText);
                    break;
                case ITEM_TYPE_SLOT:
                    // Slot, set title & cost
                    EquippedUpgrade upgrade = es.getUpgradeAtSlot(
                            mListItemLookup.slotType, mListItemLookup.slotNumber);
                    if (upgrade.getUpgrade().isPlaceholder()) {
                        mTitleTextView.setText(R.string.empty_upgrade_slot);
                        mCostTextView.setText(R.string.indicator_not_applicable);
                    } else {
                        mTitleTextView.setText(upgrade.getUpgrade().getTitle());
                        mCostTextView.setText(Integer.toString(upgrade.calculateCost()));
                    }
                    break;
                case ITEM_TYPE_GROUP:
                    // Set equipped ship total cost
                    mTitleTextView.setText(es.getTitle());
                    mCostTextView.setText(Integer.toString(es.calculateCost()));
                    break;
                default:
                    throw new IllegalStateException();
            }
        }
    }

    public EquippedShip getEquippedShip(int shipIndex) {
        return mSquad.getEquippedShips().get(shipIndex);
    }

    public EquippedUpgrade getEquippedUpgrade(int shipIndex, int slotType, int slotNumber) {
        return getEquippedShip(shipIndex).getUpgradeAtSlot(slotType, slotNumber);
    }

    public EditSquadAdapter(Activity activity, ExpandableListView listView,
                Squad squad, EditSquadFragment.SlotSelectCallback callback) {
        // TODO: always maintain one empty extra ship to support add/remove
        mActivity = activity;
        mListView = listView;
        mSquad = squad;
        mCallback = callback;
        updateLookup();
        mListView.setOnChildClickListener(this); // child clicks -> upgrade selection
        mListView.setOnItemClickListener(this); // non-child/group footer clicks -> adding ships

        // add footer for adding ships
        LayoutInflater inflater = activity.getLayoutInflater();
        View footer = inflater.inflate(R.layout.squad_list_add_ship, listView, false);
        listView.addFooterView(footer);
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }

    @Override
    public int getChildType(int groupPosition, int childPosition) {
        int headerResId = mShipLookup[groupPosition].get(childPosition).headerResId;
        return headerResId == INVALID_HEADER_ID ? 0 : 1;
    }

    @Override
    public int getChildTypeCount() {
        return 2;
    }

    @Override
    public int getGroupCount() {
        return mSquad.getEquippedShips().size();
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return mShipLookup[groupPosition].size();
    }

    @Override
    public Object getGroup(int groupPosition) {
        return getEquippedShip(groupPosition);
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

        SquadListItemHolder holder = (SquadListItemHolder) convertView.getTag();
        if (holder.mItemType != ITEM_TYPE_GROUP) throw new IllegalStateException();
        holder.reinitialize(groupPosition, -1, null);

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
        if (holder.mItemType != itemType) throw new IllegalStateException();
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
        EquippedUpgrade equippedUpgrade = getEquippedUpgrade(groupPosition, slotType, slotNumber);
        String currentEquipmentId = equippedUpgrade.getUpgrade().getExternalId();

        // Make upgrades with faction == ship faction most visible
        String prefFaction = getEquippedShip(groupPosition).getShip().getFaction();

        mCallback.onSlotSelected(groupPosition, slotType, slotNumber,
                currentEquipmentId, prefFaction);
        return false;
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        // any non group/child views are used for adding ships
        mCallback.onSlotSelected(-1, EquippedShip.SLOT_TYPE_SHIP, 0, null, null);
    }

    public void onSetItemReturned(int equippedShipNumber, int slotType, int slotIndex,
            String externalId) {
        if (slotType == EquippedShip.SLOT_TYPE_SHIP) {
            mSquad.addEquippedShip(externalId);
        } else {
            getEquippedShip(equippedShipNumber).equipUpgrade(slotType, slotIndex, externalId);
        }
        notifyDataSetChanged();
    }
}
