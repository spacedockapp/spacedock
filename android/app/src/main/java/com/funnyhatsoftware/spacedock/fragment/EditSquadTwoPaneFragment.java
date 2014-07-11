package com.funnyhatsoftware.spacedock.fragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;

import com.funnyhatsoftware.spacedock.R;

public class EditSquadTwoPaneFragment extends TwoPaneFragment implements
        EditSquadFragment.SetItemRequestListener,
        SetItemListFragment.SetItemSelectedListener {
    private static final String ARG_SQUAD_UUID = "squad_uuid";

    public static EditSquadTwoPaneFragment newInstance(String squadUuid) {
        EditSquadTwoPaneFragment fragment = new EditSquadTwoPaneFragment();
        Bundle args = new Bundle();
        args.putString(ARG_SQUAD_UUID, squadUuid);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    Fragment createPrimaryFragment() {
        String squadUuid = getArguments().getString(ARG_SQUAD_UUID);
        return EditSquadFragment.newInstance(squadUuid);
    }

    @Override
    public void onItemRequested(String itemType, String prioritizedFaction,
            String currentEquipmentId) {
        Fragment fragment = SetItemListFragment.newInstance(
                itemType, prioritizedFaction, currentEquipmentId);
        getChildFragmentManager().beginTransaction()
                .replace(R.id.secondary_fragment_container, fragment)
                .commit();
    }

    @Override
    public void onItemSelected(String itemType, String itemId) {
        EditSquadFragment fragment = (EditSquadFragment) getPrimaryFragment();
        fragment.onSetItemReturned(itemId);
    }
}
