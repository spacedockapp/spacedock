package com.funnyhatsoftware.spacedock.activity;

import android.os.Bundle;
import android.support.v4.app.Fragment;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.fragment.EditSquadFragment;
import com.funnyhatsoftware.spacedock.fragment.ItemListFragment;

public class EditSquadActivity extends PanedFragmentActivity
        implements ItemListFragment.ItemSelectedListener, EditSquadFragment.ItemRequestListener {
    public static final String EXTRA_SQUAD_INDEX = "squad_index";

    private static final String TAG_EDIT = "edit";
    private static final String TAG_SELECT = "select";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_onepane);

        if (savedInstanceState == null) {
            int squadIndex = getIntent().getIntExtra(EXTRA_SQUAD_INDEX, 0);
            Fragment editSquadFragment = EditSquadFragment.newInstance(squadIndex);
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.primary_fragment_container, editSquadFragment, TAG_EDIT)
                    .commit();
        }
    }

    @Override
    public void onItemRequested(String itemType, String prioritizedFaction,
            String currentEquipmentId) {
        Fragment newFragment = ItemListFragment.newInstance(
                itemType, prioritizedFaction, currentEquipmentId);
        navigateToSubFragment(newFragment, TAG_SELECT);
    }

    @Override
    public void onItemSelected(String itemType, String itemId) {
        EditSquadFragment editSquadFragment =
                (EditSquadFragment) getSupportFragmentManager().findFragmentByTag(TAG_EDIT);

        editSquadFragment.onSetItemReturned(itemId);
    }
}
