package com.funnyhatsoftware.spacedock;

import android.app.Activity;
import android.view.ActionMode;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.funnyhatsoftware.spacedock.activity.EditSquadActivity;
import com.funnyhatsoftware.spacedock.data.EquippedShip;
import com.funnyhatsoftware.spacedock.data.EquippedUpgrade;
import com.funnyhatsoftware.spacedock.data.Explanation;
import com.funnyhatsoftware.spacedock.data.Squad;

import java.util.ArrayList;

public class EditSquadAdapter extends BaseExpandableListAdapter implements
        ExpandableListView.OnGroupClickListener,
        ExpandableListView.OnChildClickListener,
        AdapterView.OnItemClickListener,
        AdapterView.OnItemLongClickListener {
    public interface SlotSelectListener {
        void onSlotSelected(int equippedShipNumber, int slotType, int slotNumber,
                String currentEquipmentId, String prefFaction);
    }

    public static final int SELECT_MODE_SLOT_AND_CAB = 1;
    public static final int SELECT_MODE_CAB_ONLY = 2;

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
    private final SlotSelectListener mListener;
    private final int mSelectionMode;
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
        expandAllGroups();
    }

    private void expandAllGroups() {
        for (int i = 0; i < getGroupCount(); i++) {
            mListView.expandGroup(i);
        }
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

            if (mTitleTextView == null || (mCostTextView == null && mItemType != ITEM_TYPE_HEADER)) {
                throw new IllegalStateException();
            }
        }

        private void initCostTextColor(int baseCost, int calculatedCost) {
            int colorResId = R.color.cost;
            if (calculatedCost > baseCost) {
                colorResId = R.color.dark_red; // more expensive, show red
            } else if (calculatedCost < baseCost) {
                colorResId = R.color.dark_green;
            }
            int color = mActivity.getResources().getColor(colorResId);
            mCostTextView.setTextColor(color);
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
                        initCostTextColor(0, 0);
                    } else {
                        mTitleTextView.setText(upgrade.getUpgrade().getTitle());

                        int calculatedCost = upgrade.calculateCost();
                        mCostTextView.setText(Integer.toString(calculatedCost));
                        int baseCost = upgrade.getUpgrade().getCost();
                        initCostTextColor(baseCost, calculatedCost);
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
                int selectionMode, Squad squad, SlotSelectListener listener) {
        // TODO: always maintain one empty extra ship to support add/remove
        mActivity = activity;
        mListView = listView;
        mSquad = squad;
        mListener = listener;
        updateLookup();
        mListView.setOnGroupClickListener(this); // disable/ignore collapse/expand
        mListView.setOnChildClickListener(this); // child clicks -> upgrade selection
        mListView.setOnItemClickListener(this); // non-child/group footer clicks -> adding ships
        mListView.setOnItemLongClickListener(this);
        mListView.setChoiceMode(ListView.CHOICE_MODE_SINGLE);
        mSelectionMode = selectionMode;

        // add footer for adding ships
        LayoutInflater inflater = activity.getLayoutInflater();
        View footer = inflater.inflate(R.layout.squad_list_add_ship, listView, false);
        listView.addFooterView(footer);

        listView.setAdapter(this);
        expandAllGroups();
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
    public boolean onGroupClick(ExpandableListView parent, View v, int groupPosition, long id) {
        return true; // eat the click without expanding/collapsing
    }

    @Override
    public boolean onChildClick(ExpandableListView parent, View v,
            int groupPosition, int childPosition, long id) {
        long packedPosition = ExpandableListView.getPackedPositionForChild(
                groupPosition, childPosition);

        int index = mListView.getFlatListPosition(packedPosition);
        if (mActionMode != null) mActionMode.finish();
        if (mSelectionMode != SELECT_MODE_CAB_ONLY) {
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

        mListener.onSlotSelected(groupPosition, slotType, slotNumber,
                currentEquipmentId, prefFaction);
        return false;
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        // any non group/child views are used for adding ships
        mListener.onSlotSelected(-1, EquippedShip.SLOT_TYPE_SHIP, 0, null, null);
    }

    public void insertSetItem(int equippedShipNumber, int slotType, int slotIndex,
            String externalId) {
        Explanation explanation;
        if (slotType == EquippedShip.SLOT_TYPE_SHIP) {
            explanation = mSquad.tryAddEquippedShip(externalId);
        } else {
            EquippedShip es = getEquippedShip(equippedShipNumber);
            explanation = es.tryEquipUpgrade(mSquad, slotType, slotIndex, externalId);
        }
        if (explanation.canAdd) {
            notifyDataSetChanged();
        } else {
            // Show error message. This isn't a great way to do it, but works for now.
            Toast.makeText(mActivity, explanation.result, Toast.LENGTH_SHORT).show();
            Toast.makeText(mActivity, explanation.explanation, Toast.LENGTH_SHORT).show();
        }
    }

    //////////////////////////////////////////////////////////////////
    // Ship editing - long press and contextual action bar
    // TODO: consider moving the majority of this logic to EditSquadFragment
    //////////////////////////////////////////////////////////////////
    private int mSelectedShip = -1;
    private ActionMode mActionMode;
    @Override
    public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
        long packedPosition = mListView.getExpandableListPosition(position);
        int childPosition = ExpandableListView.getPackedPositionChild(packedPosition);
        if (childPosition >= 0) return false;
        int groupPosition = ExpandableListView.getPackedPositionGroup(packedPosition);
        if (groupPosition < 0) return false;

        mSelectedShip = groupPosition;
        mListView.setItemChecked(position, true);
        ((EditSquadActivity)mActivity).onShipSelected(); // hides 2nd fragment TODO: cleanup

        if (mActionMode == null) {
            // start up action mode, if needed
            mActionMode = mActivity.startActionMode(mActionModeCallback);
        }

        // TODO: remove secondary fragment in 2 pane
        return true;
    }

    private ActionMode.Callback mActionModeCallback = new ActionMode.Callback() {
        // Called when the action mode is created; startActionMode() was called
        @Override
        public boolean onCreateActionMode(ActionMode mode, Menu menu) {
            // Inflate a menu resource providing context menu items
            MenuInflater inflater = mode.getMenuInflater();
            inflater.inflate(R.menu.menu_edit_ship, menu);
            return true;
        }

        // Called each time the action mode is shown. Always called after onCreateActionMode, but
        // may be called multiple times if the mode is invalidated.
        @Override
        public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
            return false; // Return false if nothing is done
        }

        // Called when the user selects a contextual menu item
        @Override
        public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
            switch (item.getItemId()) {
                case R.id.menu_delete:
                    mSquad.removeEquippedShip(mSquad.getEquippedShips().get(mSelectedShip));
                    notifyDataSetChanged();
                    ((EditSquadActivity)mActivity).onSquadMembershipChange(); // TODO: cleanup
                    mode.finish(); // Action picked, so close the CAB
                    return true;
                default:
                    return false;
            }
        }

        // Called when the user exits the action mode
        @Override
        public void onDestroyActionMode(ActionMode mode) {
            if (mSelectedShip >= 0) {
                long packedPosition = ExpandableListView.getPackedPositionForGroup(mSelectedShip);
                int flatPosition = mListView.getFlatListPosition(packedPosition);
                mListView.setItemChecked(flatPosition, false);

                mSelectedShip = -1;
            }
            mActionMode = null;
        }
    };
}
