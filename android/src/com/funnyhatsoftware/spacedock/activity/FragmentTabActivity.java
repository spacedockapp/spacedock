package com.funnyhatsoftware.spacedock.activity;

import android.app.ActionBar;
import android.app.FragmentTransaction;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;

import com.funnyhatsoftware.spacedock.R;

public abstract class FragmentTabActivity extends FragmentActivity {
    protected abstract FragmentPagerAdapter createPagerAdapter();
    private FragmentPagerAdapter mFragmentPagerAdapter;

    protected FragmentPagerAdapter getPagerAdapter() {
        return mFragmentPagerAdapter;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.root_view_pager);
        final ActionBar actionBar = getActionBar();
        actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_TABS);

        final ViewPager viewPager = (ViewPager) findViewById(R.id.view_pager);
        mFragmentPagerAdapter = createPagerAdapter();
        viewPager.setAdapter(mFragmentPagerAdapter);
        viewPager.setOnPageChangeListener(
                new ViewPager.SimpleOnPageChangeListener() {
                    @Override
                    public void onPageSelected(int position) {
                        super.onPageSelected(position);
                        getActionBar().setSelectedNavigationItem(position);
                    }
                }
        );

        ActionBar.TabListener tabListener = new ActionBar.TabListener() {
            @Override
            public void onTabSelected(ActionBar.Tab tab, FragmentTransaction ft) {
                viewPager.setCurrentItem(tab.getPosition());
            }

            @Override
            public void onTabUnselected(ActionBar.Tab tab, FragmentTransaction ft) {}

            @Override
            public void onTabReselected(ActionBar.Tab tab, FragmentTransaction ft) {}
        };

        for (int i = 0; i < mFragmentPagerAdapter.getCount(); i++) {
            actionBar.addTab(actionBar.newTab()
                    .setText(mFragmentPagerAdapter.getPageTitle(i))
                    .setTabListener(tabListener));
        }
    }
}
