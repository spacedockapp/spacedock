package com.funnyhatsoftware.spacedock.activity;

import android.app.ActionBar;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;

import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.fragment.EditSquadFragment;
import com.funnyhatsoftware.spacedock.fragment.SetItemListFragment;

public class EditSquadActivity extends PanedFragmentActivity
        implements SetItemListFragment.SetItemSelectedListener,
        EditSquadFragment.SetItemRequestListener {
    public static final String EXTRA_SQUAD_INDEX = "squad_index";

    private static final String TAG_EDIT = "edit";
    private static final String TAG_SELECT = "select";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final ActionBar actionBar = getActionBar();
        actionBar.setDisplayHomeAsUpEnabled(true); // TODO: navigate up without new activity

        int squadIndex = getIntent().getIntExtra(EXTRA_SQUAD_INDEX, 0);
        String title = Universe.getUniverse().squads.get(squadIndex).getName();
        actionBar.setTitle(title);

        if (savedInstanceState == null) {
            initializePrimaryFragment(EditSquadFragment.newInstance(squadIndex), TAG_EDIT);
        }
    }

    @Override
    public void onItemRequested(String itemType, String prioritizedFaction,
            String currentEquipmentId) {
        Fragment newFragment = SetItemListFragment.newInstance(
                itemType, prioritizedFaction, currentEquipmentId);
        navigateToSubFragment(newFragment, TAG_SELECT);
    }

    @Override
    public void onItemSelected(String itemType, String itemId) {
        EditSquadFragment editSquadFragment =
                (EditSquadFragment) getSupportFragmentManager().findFragmentByTag(TAG_EDIT);

        // in single pane mode, we'll have an select fragment on the back stack to remove
        getSupportFragmentManager().popBackStack(TAG_SELECT,
                FragmentManager.POP_BACK_STACK_INCLUSIVE);

        editSquadFragment.onSetItemReturned(itemId);
    }
}
