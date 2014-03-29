package com.funnyhatsoftware.spacedock.fragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ExpandableListView;
import android.widget.ListView;

import com.funnyhatsoftware.spacedock.EditSquadAdapter;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.EquippedShip;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;

public class EditSquadFragment extends Fragment implements EditSquadAdapter.SlotSelectListener {
    private static final String ARG_SQUAD_INDEX = "squad_index";

    private static final String SAVE_STATE_SHIP_NUMBER = "ship_num";
    private static final String SAVE_STATE_SLOT_TYPE = "slot_type";
    private static final String SAVE_STATE_SLOT_NUMBER = "slot_num";

    public interface SetItemRequestListener {
        void onItemRequested(String itemType, String prioritizedFaction, String currentEquipmentId);
    }

    public static EditSquadFragment newInstance(int squadIndex) {
        EditSquadFragment fragment = new EditSquadFragment();
        Bundle args = new Bundle();
        args.putInt(ARG_SQUAD_INDEX, squadIndex);
        fragment.setArguments(args);
        return fragment;
    }

    EditSquadAdapter mAdapter;

    /**
     * These three ints store information associated with the current slot request, so that the
     * fragment can tell its adapter where a returned item should be inserted
     */
    private int mEquippedShipNumber;
    private int mSelectedSlotType;
    private int mSelectedSlotNumber;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (savedInstanceState != null) {
            mEquippedShipNumber = savedInstanceState.getInt(SAVE_STATE_SHIP_NUMBER);
            mSelectedSlotType = savedInstanceState.getInt(SAVE_STATE_SLOT_TYPE);
            mSelectedSlotNumber = savedInstanceState.getInt(SAVE_STATE_SLOT_NUMBER);
        } else {
            mEquippedShipNumber = -1;
            mSelectedSlotType = -1;
            mSelectedSlotNumber = -1;
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putInt(SAVE_STATE_SHIP_NUMBER, mEquippedShipNumber);
        outState.putInt(SAVE_STATE_SLOT_TYPE, mSelectedSlotType);
        outState.putInt(SAVE_STATE_SLOT_NUMBER, mSelectedSlotNumber);
    }

    @Override
    public View onCreateView(LayoutInflater inflater,
            ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_edit_squad, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        ExpandableListView elv = (ExpandableListView) view.findViewById(R.id.list);

        // TODO: better place to do this
        boolean isTwoPane = getActivity().findViewById(R.id.secondary_fragment_container) != null;
        elv.setChoiceMode(isTwoPane
                ? ListView.CHOICE_MODE_SINGLE
                : ListView.CHOICE_MODE_NONE);

        int squadIndex = getArguments().getInt(ARG_SQUAD_INDEX);
        Squad squad = Universe.getUniverse().getSquad(squadIndex);
        mAdapter = new EditSquadAdapter(getActivity(), elv, squad, this);
        elv.setAdapter(mAdapter);
    }

    private static String[] slotNames = {
            "Captain",
            "Crew",
            "Weapon",
            "Tech",
            "Talent",
    };

    @Override
    public void onSlotSelected(int equippedShipNumber, int slotType, int slotNumber,
            String currentEquipmentId, String prefFaction) {
        final SetItemRequestListener listener = ((SetItemRequestListener)getActivity());

        mEquippedShipNumber = equippedShipNumber;
        mSelectedSlotType = slotType;
        mSelectedSlotNumber = slotNumber;
        if (mSelectedSlotType == EquippedShip.SLOT_TYPE_SHIP) {
            listener.onItemRequested("Ship", prefFaction, null);
        } else {
            listener.onItemRequested(slotNames[slotType], prefFaction, currentEquipmentId);
        }
    }

    public void onSetItemReturned(String externalId) {
        mAdapter.insertSetItem(mEquippedShipNumber, mSelectedSlotType, mSelectedSlotNumber,
                externalId);
    }
}
