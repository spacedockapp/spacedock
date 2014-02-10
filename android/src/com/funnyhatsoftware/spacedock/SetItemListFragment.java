package com.funnyhatsoftware.spacedock;

import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;

public class SetItemListFragment extends ListFragment {
    public static final String ARG_SLOT_TYPE = "slot_type";
    public static final String ARG_CURRENT_EQUIP_ID = "current_equip";

    public static final String SAVE_KEY_ACTIVATED_POSITION = "activated_position";

    public interface CardSelectCallback {
        public void onCardSelected(String externalId);
    }

    private CardSelectCallback mCallback;
    private ArrayAdapter<EquipHelper.SetItemWrapper> mAdapter;
    private int mSlotType;
    private int mActivatedPosition = ListView.INVALID_POSITION;

    /**
     * Create a new instance of CountingFragment, providing "num"
     * as an argument.
     */
    static SetItemListFragment newInstance(int slotType, String currentEquipmentId) {
        SetItemListFragment fragment = new SetItemListFragment();

        // Supply num input as an argument.
        Bundle args = new Bundle();
        args.putInt(ARG_SLOT_TYPE, slotType);
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
        mCallback = (CardSelectCallback) getActivity();
        mSlotType = getArguments().getInt(ARG_SLOT_TYPE);
        mAdapter = new ArrayAdapter<EquipHelper.SetItemWrapper>(
                getActivity(),
                android.R.layout.simple_list_item_activated_1,
                EquipHelper.getItemsForSlot(mSlotType));
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
        mCallback.onCardSelected(wrapper.getExternalId());
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
