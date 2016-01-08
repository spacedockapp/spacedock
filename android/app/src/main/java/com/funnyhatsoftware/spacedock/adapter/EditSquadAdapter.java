package com.funnyhatsoftware.spacedock.adapter;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Admiral;
import com.funnyhatsoftware.spacedock.data.Constants;
import com.funnyhatsoftware.spacedock.data.EquippedShip;
import com.funnyhatsoftware.spacedock.data.EquippedUpgrade;
import com.funnyhatsoftware.spacedock.data.Explanation;
import com.funnyhatsoftware.spacedock.data.Flagship;
import com.funnyhatsoftware.spacedock.data.FleetCaptain;
import com.funnyhatsoftware.spacedock.data.Squad;

import java.util.ArrayList;

public class EditSquadAdapter extends BaseExpandableListAdapter implements
        ExpandableListView.OnGroupClickListener,
        ExpandableListView.OnChildClickListener,
        AdapterView.OnItemClickListener {
    public interface SlotSelectListener {
        void onSlotSelected(int equippedShipNumber, int slotType, int slotNumber,
                            String currentEquipmentId, String prefFaction);
    }

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
        final ArrayList<EquippedShip> ships = mSquad.getEquippedShips();
        final boolean squadHasFlagship =
                mSquad.getResource() != null && mSquad.getResource().getIsFlagship();
        int flagshipIndex = -1;
        if (squadHasFlagship) {
            for (int i = 0; i < ships.size(); i++) {
                if (ships.get(i).getFlagship() != null) {
                    flagshipIndex = i;
                    break;
                }
            }
        }
        final boolean flagshipUnassigned = squadHasFlagship && flagshipIndex < 0;

        final boolean squadHasFleetCaptain = null != mSquad.getResource() && mSquad.getResource().isFleetCaptain();
        int fleetCaptainIndex = -1;
        if (squadHasFleetCaptain) {
            for (int i = 0; i < ships.size(); i++) {
                if (null != ships.get(i).getFleetCaptain()) {
                    fleetCaptainIndex = i;
                    break;
                }
            }
        }
        final boolean fleetCaptainUnassigned = squadHasFleetCaptain && fleetCaptainIndex < 0;

        final boolean squadHasOfficers = null != mSquad.getResource() && mSquad.getResource().isOfficers();
        int officerCount = 0;
        if (squadHasOfficers) {
            for (int i = 0; i < ships.size(); i++) {
                ArrayList<EquippedUpgrade> officers = ships.get(i).allUpgradesOfType(Constants.OFFICER_TYPE);
                officerCount += officers.size();
                if (officerCount >= 4) {
                    officerCount = 4;
                    break;
                }
            }
        }

        int admiralIndex = -1;
        for (int i = 0; i < ships.size(); i++) {
            Admiral admiral = ships.get(i).getAdmiral();
            if (null != admiral && !admiral.isPlaceholder()) {
                admiralIndex = i;
                break;
            }
        }

        for (int i = 0; i < mSquad.getEquippedShips().size(); i++) {
            ArrayList<ListItemLookup> l = new ArrayList<ListItemLookup>();
            EquippedShip s = ships.get(i);
            if (i == flagshipIndex || flagshipUnassigned) {
                populateLookup(l, 1, R.string.flagship_slot, EquippedShip.SLOT_TYPE_FLAGSHIP);
            } else if (i == fleetCaptainIndex || fleetCaptainUnassigned && s.getCaptainLimit() > 0) {
                populateLookup(l, 1, R.string.fleetcaptain_slot, EquippedShip.SLOT_TYPE_FLEET_CAPTAIN);
            }
            if (!s.isResourceSideboard() && !s.isShuttle()) {
                if (i == admiralIndex || 0 > admiralIndex) {
                    populateLookup(l, s.getAdmiralLimit(), R.string.admiral_slot,
                            EquippedShip.SLOT_TYPE_ADMIRAL);
                }
            }
            populateLookup(l, s.getCaptainLimit(), R.string.captain_slot,
                    EquippedShip.SLOT_TYPE_CAPTAIN);
            populateLookup(l, s.getTalent(), R.string.talent_slot, EquippedShip.SLOT_TYPE_TALENT);
            populateLookup(l, s.getCrew(), R.string.crew_slot, EquippedShip.SLOT_TYPE_CREW);
            if (squadHasOfficers) {
                int officerLimit = s.getOfficerLimit();
                ArrayList<EquippedUpgrade> officers = s.allUpgradesOfType(Constants.OFFICER_TYPE);
                officerCount -= officers.size();
                officerLimit -= officerCount;
                populateLookup(l, officerLimit, R.string.officer_slot, EquippedShip.SLOT_TYPE_OFFICER);
            }
            populateLookup(l, s.getWeapon(), R.string.weapon_slot, EquippedShip.SLOT_TYPE_WEAPON);
            populateLookup(l, s.getTech(), R.string.tech_slot, EquippedShip.SLOT_TYPE_TECH);
            populateLookup(l, s.getBorg(), R.string.borg_slot, EquippedShip.SLOT_TYPE_BORG);
            populateLookup(l, s.getSquadron(), R.string.squadron_slot, EquippedShip.SLOT_TYPE_SQUADRON);
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
            switch (mItemType) {
                case ITEM_TYPE_HEADER:
                    // Header, simply set text
                    String headerText = mActivity.getResources().getString(
                            mListItemLookup.headerResId);
                    mTitleTextView.setText(headerText);
                    break;
                case ITEM_TYPE_SLOT:
                    // Slot, set title & cost
                    initCostTextColor(0, 0); // set default text color
                    if (mListItemLookup.slotType == EquippedShip.SLOT_TYPE_FLAGSHIP) {
                        Flagship flagship = es.getFlagship();
                        if (flagship == null) {
                            mTitleTextView.setText(R.string.empty_upgrade_slot);
                            mCostTextView.setText(R.string.indicator_not_applicable);
                        } else {
                            mTitleTextView.setText(flagship.getTitle());
                            mCostTextView.setText(Integer.toString(flagship.getCost()));
                        }
                    } else if (mListItemLookup.slotType == EquippedShip.SLOT_TYPE_FLEET_CAPTAIN) {
                        FleetCaptain fleetCaptain = es.getFleetCaptain();
                        if (null == fleetCaptain) {
                            mTitleTextView.setText(R.string.empty_upgrade_slot);
                            mCostTextView.setText(R.string.indicator_not_applicable);
                        } else {
                            mTitleTextView.setText(fleetCaptain.getTitle());
                            mCostTextView.setText(Integer.toString(fleetCaptain.getCost()));
                        }
                    } else {
                        EquippedUpgrade upgrade = es.getUpgradeAtSlot(
                                mListItemLookup.slotType, mListItemLookup.slotNumber);
                        if (upgrade == null || upgrade.getUpgrade().isPlaceholder()) {
                            mTitleTextView.setText(R.string.empty_upgrade_slot);
                            mCostTextView.setText(R.string.indicator_not_applicable);
                        } else {
                            mTitleTextView.setText(upgrade.getUpgrade().getTitle());

                            int calculatedCost = upgrade.calculateCost();
                            mCostTextView.setText(Integer.toString(calculatedCost));
                            int baseCost = upgrade.getUpgrade().getCost();
                            initCostTextColor(baseCost, calculatedCost);
                        }
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

    public Squad getSquad() {
        return mSquad;
    }

    public EditSquadAdapter(Activity activity, ExpandableListView listView,
                            Squad squad, SlotSelectListener listener) {
        // TODO: always maintain one empty extra ship to support add/remove
        mActivity = activity;
        mListView = listView;
        mSquad = squad;
        mListener = listener;
        updateLookup();
        mListView.setOnGroupClickListener(this); // group clicks - ship selection
        mListView.setOnChildClickListener(this); // child clicks -> upgrade selection
        mListView.setOnItemClickListener(this); // non-child/group footer clicks -> adding ships
        mListView.setChoiceMode(ListView.CHOICE_MODE_SINGLE);

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

        SquadListItemHolder holder = (SquadListItemHolder) convertView.getTag();
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
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        // any non group/child views are used for adding ships
        mListener.onSlotSelected(-1, EquippedShip.SLOT_TYPE_SHIP, 0, null, null);
    }

    @Override
    public boolean onGroupClick(ExpandableListView parent, View v, int groupPosition, long id) {
        long packedPosition = ExpandableListView.getPackedPositionForGroup(groupPosition);
        int index = mListView.getFlatListPosition(packedPosition);
        if (packedPosition == mListView.getSelectedPosition()) {
            return false; // do nothing for double select
        }

        // Ship slot selected, call back to listener
        EquippedShip equippedShip = getEquippedShip(groupPosition);

        if (equippedShip.isFighterSquadron() || equippedShip.isResourceSideboard()) {
            // don't support changing ships for these
            return false;
        }

        mListView.setItemChecked(index, true);
        String currentEquipmentId = equippedShip.getShip().getExternalId();
        mListener.onSlotSelected(groupPosition, EquippedShip.SLOT_TYPE_SHIP, 0,
                currentEquipmentId, equippedShip.getFaction());
        return true;
    }

    @Override
    public boolean onChildClick(ExpandableListView parent, View v,
                                int groupPosition, int childPosition, long id) {
        long packedPosition = ExpandableListView.getPackedPositionForChild(
                groupPosition, childPosition);
        int index = mListView.getFlatListPosition(packedPosition);
        if (packedPosition == mListView.getSelectedPosition()) {
            return false; // do nothing for double select
        }
        mListView.setItemChecked(index, true);
        SquadListItemHolder holder = (SquadListItemHolder) v.getTag();

        // Upgrade slot selected, call back to listener with slot info
        int slotType = holder.mListItemLookup.slotType;
        int slotNumber = holder.mListItemLookup.slotNumber;
        String currentEquipmentId;
        EquippedShip equippedShip = getEquippedShip(groupPosition);
        if (slotType == EquippedShip.SLOT_TYPE_FLAGSHIP) {
            Flagship flagship = equippedShip.getFlagship();
            currentEquipmentId = (flagship == null) ? null : flagship.getExternalId();
        } else if (slotType == EquippedShip.SLOT_TYPE_FLEET_CAPTAIN) {
            FleetCaptain fleetCaptain = equippedShip.getFleetCaptain();
            currentEquipmentId = (fleetCaptain == null) ? null : fleetCaptain.getExternalId();
        } else {
            EquippedUpgrade equippedUpgrade = getEquippedUpgrade(groupPosition, slotType, slotNumber);
            currentEquipmentId = (equippedUpgrade == null) ? null : equippedUpgrade.getUpgrade().getExternalId();
        }

        // Make upgrades with faction == ship faction most visible
        String prefFaction = equippedShip.getFaction();

        mListener.onSlotSelected(groupPosition, slotType, slotNumber,
                currentEquipmentId, prefFaction);
        return true;
    }

    public void insertSetItem(int equippedShipNumber, int slotType, int slotIndex,
                              String externalId) {
        Explanation explanation;
        if (slotType == EquippedShip.SLOT_TYPE_SHIP) {
            if (equippedShipNumber >= 0) {
                EquippedShip es = getEquippedShip(equippedShipNumber);
                explanation = es.trySetShip(mSquad, externalId);
            } else {
                explanation = mSquad.tryAddEquippedShip(externalId);
            }
        } else {
            EquippedShip es = getEquippedShip(equippedShipNumber);
            if (slotType == EquippedShip.SLOT_TYPE_FLAGSHIP) {
                explanation = es.tryEquipFlagship(mSquad, externalId);
            } else if (slotType == EquippedShip.SLOT_TYPE_FLEET_CAPTAIN) {
                explanation = es.tryEquipFleetCaptain(mSquad, externalId);
            } else {
                explanation = es.tryEquipUpgrade(mSquad, slotType, slotIndex, externalId);
            }
        }
        if (explanation.canAdd) {
            notifyDataSetChanged();
        } else {
            // Show error message. This isn't a great way to do it, but works for now.
            Toast.makeText(mActivity, explanation.result, Toast.LENGTH_SHORT).show();
            Toast.makeText(mActivity, explanation.explanation, Toast.LENGTH_SHORT).show();
        }
    }
}
