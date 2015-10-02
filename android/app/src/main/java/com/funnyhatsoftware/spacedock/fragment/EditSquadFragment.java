package com.funnyhatsoftware.spacedock.fragment;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ExpandableListView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.TextEntryDialog;
import com.funnyhatsoftware.spacedock.activity.SetItemListActivity;
import com.funnyhatsoftware.spacedock.activity.SquadTabActivity;
import com.funnyhatsoftware.spacedock.adapter.EditSquadAdapter;
import com.funnyhatsoftware.spacedock.adapter.ResourceSpinnerAdapter;
import com.funnyhatsoftware.spacedock.data.EquippedShip;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.holder.ShipHolder;

public class EditSquadFragment extends Fragment implements EditSquadAdapter.SlotSelectListener {
    private static final String ARG_SQUAD_UUID = "squad_uuid";

    private static final String SAVE_STATE_SHIP_NUMBER = "ship_num";
    private static final String SAVE_STATE_SLOT_TYPE = "slot_type";
    private static final String SAVE_STATE_SLOT_NUMBER = "slot_num";

    private static final int REQUEST_ITEM = 0;

    public interface SetItemRequestListener {
        void onItemRequested(String itemType, String prioritizedFaction, String currentEquipmentId);
    }

    public static EditSquadFragment newInstance(String squadUuid) {
        EditSquadFragment fragment = new EditSquadFragment();
        Bundle args = new Bundle();
        args.putString(ARG_SQUAD_UUID, squadUuid);
        fragment.setArguments(args);
        return fragment;
    }

    EditSquadAdapter mAdapter;
    View mView;
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
        setHasOptionsMenu(true);

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
        super.onViewCreated(view, savedInstanceState);
        ExpandableListView elv = (ExpandableListView) view.findViewById(R.id.list);

        String squadUuid = getArguments().getString(ARG_SQUAD_UUID);
        Squad squad = Universe.getUniverse().getSquadByUUID(squadUuid);
        mAdapter = new EditSquadAdapter(getActivity(), elv, squad, this);
        mView = view;
        Spinner resourceSpinner = (Spinner) view.findViewById(R.id.resource_spinner);
        ResourceSpinnerAdapter.createForSpinner(getActivity(), resourceSpinner, squad);
        ((SquadTabActivity)getActivity()).updateTitleAndCost();
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        if (getParentFragment() != null && !getParentFragment().isMenuVisible()) { return; } // WAR
        inflater.inflate(R.menu.menu_edit_squad, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        final int itemId = item.getItemId();

        String squadUuid = getArguments().getString(ARG_SQUAD_UUID);
        final Squad squad = Universe.getUniverse().getSquadByUUID(squadUuid);
        if (squad == null) {
            throw new IllegalStateException("Editing invalid squad");
        }

        Context context = getActivity();
        if (itemId == R.id.menu_rename) {
            TextEntryDialog.create(context, squad.getName(),
                    R.string.dialog_request_squad_name,
                    R.string.dialog_error_empty_squad_name,
                    new TextEntryDialog.OnAcceptListener() {
                        @Override
                        public void onTextValueCommitted(String inputText) {
                            squad.setName(inputText);
                            ((SquadTabActivity)getActivity()).updateTitleAndCost(); // TODO: clean this up
                        }
                    }
            );
            return true;
        } else if (itemId == R.id.menu_additional_points) {
                TextEntryDialog.create(context, Integer.toString(squad.getAdditionalPoints()),
                        R.string.dialog_additional_points,
                        R.string.dialog_error_nan,
                        new TextEntryDialog.OnAcceptListener() {
                            @Override
                            public void onTextValueCommitted(String inputText) {
                                squad.setAdditionalPoints(new Integer(inputText).intValue());
                                notifyDataSetChanged();
                                ((SquadTabActivity) getActivity()).updateTitleAndCost(); // TODO: clean this up
                            }
                        }
                );
                return true;
        } else if (itemId == R.id.menu_notes) {
            TextEntryDialog.create(context, squad.getNotes(),
                    R.string.dialog_notes,
                    R.string.dialog_notes,
                    new TextEntryDialog.OnAcceptListener() {
                        @Override
                        public void onTextValueCommitted(String inputText) {
                            squad.setNotes(inputText);
                            notifyDataSetChanged();
                            ((SquadTabActivity) getActivity()).updateTitleAndCost(); // TODO: clean this up
                        }
                    }
            );
            return true;
        } else if (itemId == R.id.menu_delete) {
            Universe.getUniverse().getAllSquads().remove(squad);
            Toast.makeText(context, "Deleted squad " + squad.getName(),
                    Toast.LENGTH_SHORT).show();
            getActivity().finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public void notifyDataSetChanged() {
        // Data has changed out from underneath adapter, signal it to update
        mAdapter.notifyDataSetChanged();
    }

    @Override
    public void onSlotSelected(int equippedShipNumber, int slotType, int slotNumber,
            String currentEquipmentId, String prefFaction) {
        mEquippedShipNumber = equippedShipNumber;
        mSelectedSlotType = slotType;
        mSelectedSlotNumber = slotNumber;

        Fragment parentFragment = getParentFragment();
        if (parentFragment == null) {
            // No parent fragment, handle directly
            Intent intent;
            if (mSelectedSlotType == EquippedShip.SLOT_TYPE_SHIP) {
                intent = SetItemListActivity.SelectActivity.getIntent(
                        getActivity(),
                        ShipHolder.TYPE_STRING,
                        prefFaction,
                        currentEquipmentId);
            } else {
                intent = SetItemListActivity.SelectActivity.getIntent(
                        getActivity(),
                        EquippedShip.CLASS_FOR_SLOT[slotType].getSimpleName(),
                        prefFaction,
                        currentEquipmentId);
            }
            startActivityForResult(intent, REQUEST_ITEM);
        } else {
            // delegate to containing fragment
            SetItemRequestListener listener = (SetItemRequestListener) parentFragment;
            if (mSelectedSlotType == EquippedShip.SLOT_TYPE_SHIP) {
                listener.onItemRequested(ShipHolder.TYPE_STRING, prefFaction, currentEquipmentId);
            } else {
                String slotName = EquippedShip.CLASS_FOR_SLOT[slotType].getSimpleName();
                listener.onItemRequested(slotName, prefFaction, currentEquipmentId);
            }
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_ITEM && resultCode == Activity.RESULT_OK) {
            String itemId = data.getStringExtra(SetItemListActivity.EXTRA_ITEM_RESULT_ID);
            onSetItemReturned(itemId);
            Spinner resourceSpinner = (Spinner) mView.findViewById(R.id.resource_spinner);
            ResourceSpinnerAdapter.createForSpinner(getActivity(), resourceSpinner, mAdapter.getSquad());
        }
    }

    public void onSetItemReturned(String externalId) {
        if (mAdapter != null) {
            mAdapter.insertSetItem(mEquippedShipNumber, mSelectedSlotType, mSelectedSlotNumber,
                    externalId);
        }
        ((SquadTabActivity)getActivity()).updateTitleAndCost(); // TODO: clean this up
    }
}
