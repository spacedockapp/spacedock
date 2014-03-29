package com.funnyhatsoftware.spacedock.activity;

import android.app.ActionBar;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ArrayAdapter;
import android.widget.SpinnerAdapter;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.fragment.BrowseListFragment;
import com.funnyhatsoftware.spacedock.fragment.ChooseFactionDialog;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;
import com.funnyhatsoftware.spacedock.fragment.DisplaySquadFragment;
import com.funnyhatsoftware.spacedock.fragment.ManageSquadsFragment;
import com.funnyhatsoftware.spacedock.fragment.SetItemListFragment;

/**
 * Base fragment managing Activity class, supporting ActionBar spinner navigation.
 *
 * This activity manages all of the fragment transitions to navigate between building squads
 * and browsing items.
 */
public class RootActivity extends PanedFragmentActivity implements ActionBar.OnNavigationListener,
        BrowseListFragment.BrowseTypeSelectionListener,
        SetItemListFragment.SetItemSelectedListener,
        ManageSquadsFragment.SquadSelectListener,
        DisplaySquadFragment.SquadDisplayListener {
    private final String SAVE_NAV_POSITION = "navPos";
    private int mPosition;

    private final String TAG_ITEM_LIST = "itemlist";
    private final String TAG_DISPLAY_SQUAD = "displaysquad";
    private final String TAG_MANAGE_SQUADS = "managesquads";
    private final String TAG_BROWSE_LIST = "browselist";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getActionBar().setNavigationMode(ActionBar.NAVIGATION_MODE_LIST);
        SpinnerAdapter spinnerAdapter = ArrayAdapter.createFromResource(
                getActionBar().getThemedContext(),
                R.array.action_spinner_list,
                android.R.layout.simple_spinner_dropdown_item);
        getActionBar().setListNavigationCallbacks(spinnerAdapter, this);

        if (savedInstanceState == null) {
            initializePrimaryFragment(new BrowseListFragment(), TAG_BROWSE_LIST);
            mPosition = 0;
        } else {
            mPosition = savedInstanceState.getInt(SAVE_NAV_POSITION);
        }
    }

    private Fragment findFragmentByTag(String tag) {
        return getSupportFragmentManager().findFragmentByTag(tag);
    }

    @Override
    protected void onResume() {
        super.onResume();

        // TODO: don't notify fragments if data hasn't actually changed
        Fragment fragment = findFragmentByTag(TAG_ITEM_LIST);
        if (fragment != null) {
            // content may have been changed by SetPreferences, reinitialize list
            ((SetItemListFragment) fragment).initializeAdapter();
        }
        fragment = findFragmentByTag(TAG_DISPLAY_SQUAD);
        if (fragment != null) {
            // content may have been changed by EditSquadActivity, reinitialize list
            ((DisplaySquadFragment) fragment).initializeAdapter();
        }
        fragment = findFragmentByTag(TAG_MANAGE_SQUADS);
        if (fragment != null) {
            // squad details may have been changed by EditSquadActivity, refresh data
            ((ManageSquadsFragment) fragment).notifyDataSetChanged();
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putInt(SAVE_NAV_POSITION, mPosition);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_root, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        final int itemId = item.getItemId();
        if (itemId == R.id.menu_settings) {
            Intent intent = new Intent(this, SettingsActivity.class);
            startActivity(intent);
            return true;
        }

        if (itemId == R.id.menu_faction) {
            FragmentManager fm = getSupportFragmentManager();
            ChooseFactionDialog chooseFactionDialog = new ChooseFactionDialog();
            chooseFactionDialog.show(fm, "framgment_faction_list");
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public boolean onNavigationItemSelected(int itemPosition, long itemId) {
        if (itemPosition == mPosition) return false;

        Fragment newPrimaryFragment;
        String tag;
        if (itemPosition == 0) {
            newPrimaryFragment = new BrowseListFragment();
            tag = TAG_BROWSE_LIST;
        } else {
            newPrimaryFragment = new ManageSquadsFragment();
            tag = TAG_MANAGE_SQUADS;
        }
        Fragment oldSecondaryFragment = null;
        if (isTwoPane()) {
            oldSecondaryFragment = getSupportFragmentManager()
                .findFragmentById(R.id.secondary_fragment_container);
        }

        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        transaction.replace(R.id.primary_fragment_container, newPrimaryFragment, tag);
        if (oldSecondaryFragment != null) {
            transaction.remove(oldSecondaryFragment);
        }
        transaction.commit();

        mPosition = itemPosition;
        return true;
    }

    @Override
    public void onBrowseTypeSelected(String itemType) {
        Fragment newFragment = SetItemListFragment.newInstance(itemType, null, null);
        navigateToSubFragment(newFragment, TAG_ITEM_LIST);
    }

    @Override
    public void onItemSelected(String itemType, String itemId) {
        DetailsFragment fragment = DetailsFragment.newInstance(itemType, itemId);
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();

        if (isTwoPane()) {
            Fragment prev = getSupportFragmentManager().findFragmentByTag("dialog");
            if (prev != null) {
                ft.remove(prev);
            }
            ft.addToBackStack(null);

            //show the dialog.
            fragment.show(ft, "dialog");
        } else {
            // single pane, add new fragment in place of main
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.primary_fragment_container, fragment)
                    .addToBackStack(null)
                    .commit();
        }
    }

    @Override
    public void onSquadSelected(int squadIndex) {
        Fragment newFragment = DisplaySquadFragment.newInstance(squadIndex);
        navigateToSubFragment(newFragment, TAG_DISPLAY_SQUAD);
    }

    @Override
    public void onSquadEditAction(int squadIndex) {
        Intent intent = new Intent(this, EditSquadActivity.class);
        intent.putExtra(EditSquadActivity.EXTRA_SQUAD_INDEX, squadIndex);
        startActivity(intent);
    }
}
