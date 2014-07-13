
package com.funnyhatsoftware.spacedock.activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentPagerAdapter;
import android.view.Menu;
import android.view.MenuItem;

import com.funnyhatsoftware.spacedock.DataHelper;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.fragment.BrowseListFragment;
import com.funnyhatsoftware.spacedock.fragment.BrowseTwoPaneFragment;
import com.funnyhatsoftware.spacedock.fragment.ManageSquadsFragment;

public class RootTabActivity extends FragmentTabActivity implements
        ManageSquadsFragment.SquadSelectListener {
    private boolean mTwoPane;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mTwoPane = getResources().getBoolean(R.bool.use_two_pane);

        if (getIntent().getData() != null) {
            DataHelper.loadUniverseDataFromUri(this, getIntent().getData());
        }
    }

    @Override
    protected void onPause() {
        super.onPause();

        DataHelper.saveUniverseData(this);
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
            startActivity(new Intent(this, SettingsActivity.class));
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected FragmentPagerAdapter createPagerAdapter() {
        return new FragmentPagerAdapter(getSupportFragmentManager()) {
            String[] mTitles = getResources().getStringArray(R.array.root_tab_labels);

            @Override
            public CharSequence getPageTitle(int position) {
                return mTitles[position];
            }

            @Override
            public Fragment getItem(int i) {
                if (i == 0) {
                    return new ManageSquadsFragment();
                } else {
                    return mTwoPane ? new BrowseTwoPaneFragment() : new BrowseListFragment();
                }
            }

            @Override
            public int getCount() {
                return 2;
            }
        };
    }

    @Override
    public void onSquadSelected(String squadUuid) {
        startActivity(SquadTabActivity.getIntent(this, squadUuid));
    }
}
