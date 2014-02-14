package com.funnyhatsoftware.spacedock;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;

public class SetItemListFragment extends ListFragment {
    private static final String ARG_EQUIP_SHIP_NR = "ship_id";
    private static final String ARG_SLOT_TYPE = "slot_type";
    private static final String ARG_SLOT_NUMBER = "slot_number";
    private static final String ARG_CURRENT_EQUIP_ID = "current_equip";

    public static final String SAVE_KEY_ACTIVATED_POSITION = "activated_position";

    public interface SetItemSelectCallback {
        public void onSetItemSelected(int equippedShipNumber, int slotType, int slotNumber, String externalId);
    }

    private SetItemSelectCallback mCallback;
    private ArrayAdapter<EquipHelper.SetItemWrapper> mAdapter;
    private int mActivatedPosition = ListView.INVALID_POSITION;

    private int mEquippedShipNumber = -1;
    private int mSlotType = -1;
    private int mSlotNumber = -1;

    /**
     * Create a new instance of CountingFragment, providing "num"
     * as an argument.
     */
    static SetItemListFragment newInstance(int equippedShipNumber,
            int slotType, int slotNumber, String currentEquipmentId) {
        SetItemListFragment fragment = new SetItemListFragment();

        // Supply num input as an argument.
        Bundle args = new Bundle();
        args.putInt(ARG_EQUIP_SHIP_NR, equippedShipNumber);
        args.putInt(ARG_SLOT_TYPE, slotType);
        args.putInt(ARG_SLOT_NUMBER, slotNumber);
        args.putString(ARG_CURRENT_EQUIP_ID, currentEquipmentId);
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
        mAdapter = new SetItemAdapter(getActivity(), mSlotType);
        setListAdapter(mAdapter);

    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        getListView().setChoiceMode(ListView.CHOICE_MODE_SINGLE);
        String currentEquipmentId = getArguments().getString(ARG_CURRENT_EQUIP_ID);
        if (currentEquipmentId != null) {
            for (int i = 0; i < mAdapter.getCount(); i++) {
                if (currentEquipmentId.compareTo(mAdapter.getItem(i).getExternalId()) == 0) {
                    setActivatedPosition(i);
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
        EquipHelper.SetItemWrapper wrapper = mAdapter.getItem(position);
        mCallback.onSetItemSelected(mEquippedShipNumber,
                mSlotType, mSlotNumber, wrapper.getExternalId());
    }

    private void setActivatedPosition(int position) {
        if (position == ListView.INVALID_POSITION) {
            getListView().setItemChecked(mActivatedPosition, false);
        } else {
            getListView().setItemChecked(position, true);
        }
        mActivatedPosition = position;
    }

    private static class SetItemAdapter extends ArrayAdapter<EquipHelper.SetItemWrapper> {
        private final int mSlotType;

        public SetItemAdapter(Context context, int slotType) {
            super(context, SetItemHolder.getLayoutForSlot(slotType), R.id.title,
                    EquipHelper.getItemsForSlot(slotType));
            mSlotType = slotType;
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
            holder.reinitialize(getItem(position).item);
            return listItem;
        }
    }
}
