package com.funnyhatsoftware.spacedock.fragment;

import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.view.View;
import android.widget.ListView;

import com.funnyhatsoftware.spacedock.SetItemAdapter;

public class SetItemListFragment extends ListFragment {
    static final String ARG_EQUIP_SHIP_NR = "ship_id";
    static final String ARG_SLOT_TYPE = "slot_type";
    static final String ARG_SLOT_NUMBER = "slot_number";
    static final String ARG_CURRENT_EQUIP_ID = "current_equip";
    static final String ARG_RETURN_EQUIP_ID = "return_equip";
    static final String ARG_PREFERRED_FACTION = "pref_faction";

    public static final String SAVE_KEY_ACTIVATED_POSITION = "activated_position";

    public interface SetItemSelectCallback {
        public void onSetItemSelected(int equippedShipNumber, int slotType, int slotNumber, String externalId);
    }

    private SetItemSelectCallback mCallback;
    private SetItemAdapter mAdapter;
    private int mActivatedPosition = ListView.INVALID_POSITION;

    private int mEquippedShipNumber = -1;
    private int mSlotType = -1;
    private int mSlotNumber = -1;

    /**
     * Create a new instance of SetItemListFragment, providing ship to be equipped and slot
     * as arguments.
     *
     * TODO: create content URIs for this
     */
    public static SetItemListFragment newInstance(int equippedShipNumber,
            int slotType, int slotNumber, String currentEquipmentId, String prefFaction) {
        SetItemListFragment fragment = new SetItemListFragment();

        Bundle args = new Bundle();
        args.putInt(ARG_EQUIP_SHIP_NR, equippedShipNumber);
        args.putInt(ARG_SLOT_TYPE, slotType);
        args.putInt(ARG_SLOT_NUMBER, slotNumber);
        args.putString(ARG_CURRENT_EQUIP_ID, currentEquipmentId);
        args.putString(ARG_PREFERRED_FACTION, prefFaction);
        fragment.setArguments(args);
        return fragment;
    }

    /**
     * When creating, retrieve this instance's number from its arguments.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (getArguments() == null) {
            throw new IllegalArgumentException();
        }

        // activity must implement selection callback
        mCallback = (SetItemSelectCallback) getActivity();
        mEquippedShipNumber = getArguments().getInt(ARG_EQUIP_SHIP_NR);
        mSlotType = getArguments().getInt(ARG_SLOT_TYPE);
        mSlotNumber = getArguments().getInt(ARG_SLOT_NUMBER);

        String preferredFaction = getArguments().getString(ARG_PREFERRED_FACTION);
        mAdapter = new SetItemAdapter(getActivity(), mSlotType, preferredFaction);
        setListAdapter(mAdapter);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        getListView().setChoiceMode(ListView.CHOICE_MODE_SINGLE);
        String currentEquipmentId = getArguments().getString(ARG_CURRENT_EQUIP_ID);
        if (currentEquipmentId != null) {
            for (int i = 0; i < mAdapter.getCount(); i++) {
                if (currentEquipmentId.compareTo(mAdapter.getItemExternalId(i)) == 0) {
                    // TODO: reuse fragment, select & smoothly scroll to new position
                    setActivatedPosition(i);
                    getListView().setSelection(i);
                    break;
                }
            }
        }

        // Restore the previously serialized activated item position.
        if (savedInstanceState != null
                && savedInstanceState.containsKey(SAVE_KEY_ACTIVATED_POSITION)) {
            setActivatedPosition(savedInstanceState.getInt(SAVE_KEY_ACTIVATED_POSITION));
        }
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        mCallback.onSetItemSelected(mEquippedShipNumber,
                mSlotType, mSlotNumber, mAdapter.getItemExternalId(position));
    }

    private void setActivatedPosition(int position) {
        if (position == ListView.INVALID_POSITION) {
            getListView().setItemChecked(mActivatedPosition, false);
        } else {
            getListView().setItemChecked(position, true);
        }
        mActivatedPosition = position;
    }
}
