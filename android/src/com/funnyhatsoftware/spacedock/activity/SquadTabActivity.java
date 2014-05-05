package com.funnyhatsoftware.spacedock.activity;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.adapter.ResourceSpinnerAdapter;
import com.funnyhatsoftware.spacedock.data.Resource;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.fragment.DisplaySquadFragment;
import com.funnyhatsoftware.spacedock.fragment.EditSquadFragment;
import com.funnyhatsoftware.spacedock.fragment.EditSquadTwoPaneFragment;
import com.funnyhatsoftware.spacedock.fragment.SetItemListFragment;

public class SquadTabActivity extends FragmentTabActivity implements
        ResourceSpinnerAdapter.ResourceSelectListener {
    private static final String EXTRA_SQUAD_UUID = "squadUuid";
    private boolean mTwoPane;
    private String mSquadUuid;

    public static Intent getIntent(Context context, String squadUuid) {
        if (squadUuid == null) throw new IllegalArgumentException();

        Intent intent = new Intent(context, SquadTabActivity.class);
        intent.putExtra(EXTRA_SQUAD_UUID, squadUuid);
        return intent;
    }

    public void updateTitle() {
        Squad squad = Universe.getUniverse().getSquadByUUID(mSquadUuid);

        getActionBar().setTitle(squad.getName());
        String cost = Integer.toString(squad.calculateCost());
        getActionBar().setSubtitle(cost + " total points");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mTwoPane = getResources().getBoolean(R.bool.use_two_pane);
        mSquadUuid = getIntent().getStringExtra(EXTRA_SQUAD_UUID);
        if (mSquadUuid == null) {
            throw new IllegalArgumentException("Squad uuid required for squad");
        }
        updateTitle();
    }


    @Override
    protected FragmentPagerAdapter createPagerAdapter() {
        return new FragmentPagerAdapter(getSupportFragmentManager()) {
            String[] mTitles = getResources().getStringArray(R.array.squad_tab_labels);

            @Override
            public CharSequence getPageTitle(int position) {
                return mTitles[position];
            }

            @Override
            public Fragment getItem(int i) {
                if (i == 0) {
                    return DisplaySquadFragment.newInstance(mSquadUuid);
                } else {
                    return mTwoPane ? EditSquadTwoPaneFragment.newInstance(mSquadUuid)
                            : EditSquadFragment.newInstance(mSquadUuid);
                }
            }

            @Override
            public int getCount() {
                return 2;
            }
        };
    }

    public void notifyEditSquadFragment(FragmentManager manager) {
        for (Fragment fragment : manager.getFragments()) {
            if (fragment instanceof EditSquadFragment) {
                ((EditSquadFragment) fragment).notifyDataSetChanged();
            } else if (fragment instanceof SetItemListFragment) {
                // Remove SetItemListFragment, as it may be stale/invalid
                manager.beginTransaction().remove(fragment).commit();
                // TODO: have editSquadFragment understand/maintain its selection ID correctly
                // across data modification. Currently, WAR by just removing the select fragment,
                // so that we don't show inconsistent selection options.
            } else if (fragment instanceof EditSquadTwoPaneFragment) {
                notifyEditSquadFragment(fragment.getChildFragmentManager());
            }
        }
    }

    @Override
    public void onResourceChanged(Resource previousResource, Resource selectedResource) {
        updateTitle(); // update title with new cost
        if ((previousResource != null && previousResource.getIsFlagship())
                || (selectedResource != null && selectedResource.getIsFlagship())) {
            notifyEditSquadFragment(getSupportFragmentManager());
        }
    }

    // TODO: The following are temporary, and should be cleaned up when convenient
    public void onShipSelected() {
        for (Fragment fragment : getSupportFragmentManager().getFragments()) {
            if (fragment instanceof EditSquadTwoPaneFragment) {
                for (Fragment subFragment : fragment.getChildFragmentManager().getFragments()) {
                    if (subFragment instanceof SetItemListFragment) {
                        fragment.getChildFragmentManager().beginTransaction()
                                .remove(subFragment)
                                .commit();
                    }
                }
            }
        }
    }

    public void onSquadMembershipChange() {
        updateTitle();
    }
}
