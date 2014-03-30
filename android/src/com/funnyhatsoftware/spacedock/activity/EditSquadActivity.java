package com.funnyhatsoftware.spacedock.activity;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.TextEntryDialog;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.fragment.EditSquadFragment;
import com.funnyhatsoftware.spacedock.fragment.SetItemListFragment;

public class EditSquadActivity extends PanedFragmentActivity
        implements SetItemListFragment.SetItemSelectedListener,
        EditSquadFragment.SetItemRequestListener {
    public static final String EXTRA_SQUAD_INDEX = "squad_index";

    private static final String TAG_EDIT = "edit";
    private static final String TAG_SELECT = "select";

    private int mSquadIndex;

    private void updateTitle() {
        mSquadIndex = getIntent().getIntExtra(EXTRA_SQUAD_INDEX, 0);
        String title = Universe.getUniverse().getSquad(mSquadIndex).getName();
        getActionBar().setTitle(title);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getActionBar().setDisplayHomeAsUpEnabled(true); // TODO: navigate up without new activity
        updateTitle();

        if (savedInstanceState == null) {
            initializePrimaryFragment(EditSquadFragment.newInstance(mSquadIndex), TAG_EDIT);
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        super.onCreateOptionsMenu(menu);
        getMenuInflater().inflate(R.menu.menu_edit_squad, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        final int itemId = item.getItemId();

        final Squad squad = Universe.getUniverse().getAllSquads().get(mSquadIndex);
        if (squad == null) {
            throw new IllegalStateException("Editing invalid squad");
        }

        if (itemId == R.id.menu_rename) {
            TextEntryDialog.create(this, squad.getName(),
                    R.string.dialog_request_squad_name,
                    R.string.dialog_error_empty_squad_name,
                    new TextEntryDialog.OnAcceptListener() {
                        @Override
                        public void onTextValueCommitted(String inputText) {
                            squad.setName(inputText);
                            updateTitle();
                        }
                    });
            return true;
        } else if (itemId == R.id.menu_delete) {
            Universe.getUniverse().getAllSquads().remove(mSquadIndex);
            Toast.makeText(this, "Deleted squad " + squad.getName(), Toast.LENGTH_SHORT).show();
            mSquadIndex = -1;
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
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
