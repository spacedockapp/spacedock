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
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;

public class EditSquadFragment extends Fragment {
    public interface SlotSelectCallback {
        void onSlotSelected(int equippedShipNumber, int slotType, int slotNumber,
            String currentEquipmentId, String prefFaction);
    }

    EditSquadAdapter mAdapter;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_edit_squad, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        ExpandableListView elv = (ExpandableListView) view.findViewById(R.id.list);
        boolean isTwoPane = getActivity().findViewById(R.id.secondary_fragment_container) != null;
        elv.setChoiceMode(isTwoPane
                ? ListView.CHOICE_MODE_SINGLE
                : ListView.CHOICE_MODE_NONE);

        Squad squad = Universe.getUniverse().squads.get(0);
        mAdapter = new EditSquadAdapter(getActivity(), elv,
                squad, (SlotSelectCallback)getActivity());
        elv.setAdapter(mAdapter);
    }

    public void onSetItemReturned(int equippedShipNumber, int slotType, int slotNumber,
            String externalId) {
        mAdapter.onSetItemReturned(equippedShipNumber, slotType, slotNumber, externalId);
    }
}
