package com.funnyhatsoftware.spacedock;

import android.app.ActionBar;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ArrayAdapter;
import android.widget.SpinnerAdapter;

/**
 * Base fragment managing Activity class, supporting ActionBar spinner navigation.
 *
 * This activitymanages all of the fragment transitions to navigate between building squads
 * and browsing items.
 */
public class RootActivity extends FragmentActivity implements ActionBar.OnNavigationListener {
    private int mPosition;
    private static Class[] sNavigationFragments = new Class[] {
            BrowseListFragment.class,
            ManageSquadsFragment.class,
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_root_twopane); // TODO: single pane for phone

        getActionBar().setNavigationMode(ActionBar.NAVIGATION_MODE_LIST);
        SpinnerAdapter spinnerAdapter = ArrayAdapter.createFromResource(
                getActionBar().getThemedContext(),
                R.array.action_spinner_list,
                android.R.layout.simple_spinner_dropdown_item);


        getActionBar().setListNavigationCallbacks(spinnerAdapter, this);

        //Fragment leftFragment = new ManageSquadsFragment();
        Fragment leftFragment = new BrowseListFragment();
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.left_fragment_container, leftFragment)
                .commit();
        mPosition = 0;
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

        return super.onOptionsItemSelected(item);

    }

    @Override
    public boolean onNavigationItemSelected(int itemPosition, long itemId) {
        Fragment currentLeft = getSupportFragmentManager()
                .findFragmentById(R.id.left_fragment_container);

        if (itemPosition == mPosition) return false;

        Fragment leftFragment = (itemPosition == 0)
                ? new BrowseListFragment() : new ManageSquadsFragment();
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.left_fragment_container, leftFragment)
                .commit();
        mPosition = itemPosition;
        return true;
    }
}
