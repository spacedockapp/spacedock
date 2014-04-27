package com.funnyhatsoftware.spacedock.activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentTransaction;
import android.view.Menu;
import android.view.MenuItem;

import com.funnyhatsoftware.spacedock.R;

public abstract class PanedFragmentActivity extends FragmentActivity {

    protected boolean isTwoPane() {
        return findViewById(R.id.secondary_fragment_container) != null;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_onepane); // returns 2 pane on tablets
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        super.onCreateOptionsMenu(menu);
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

    protected void initializePrimaryFragment(Fragment newFragment, String tag) {
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.primary_fragment_container, newFragment, tag)
                .commit();
    }

    protected void navigateToSubFragment(Fragment newFragment, String tag) {
        final boolean isTwoPane = isTwoPane();
        int containerId = isTwoPane ? R.id.secondary_fragment_container
                : R.id.primary_fragment_container;

        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction()
                .replace(containerId, newFragment, tag);
        if (!isTwoPane) {
            transaction.addToBackStack(tag);
        }
        transaction.commit();
    }

    /**
     * @return True if removed, false if not present.
     */
    protected boolean removeFragmentByTag(String tag) {
        Fragment fragment = getSupportFragmentManager().findFragmentByTag(tag);
        if (fragment != null) {
            getSupportFragmentManager().beginTransaction()
                    .remove(fragment)
                    .commit();
            return true;
        }
        return false;
    }
}
