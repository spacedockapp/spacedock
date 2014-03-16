package com.funnyhatsoftware.spacedock;

import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;

public class BrowseListFragment extends ListFragment {
    ArrayAdapter<BrowseTarget> mAdapter;
    private class BrowseTarget {
        final String mLabel;
        final String mUpType;
        final Class mActivityClass;
        public BrowseTarget(String label, Class activityClass) {
            mLabel = label;
            mUpType = null;
            mActivityClass = activityClass;
        }

        /**
         * Upgrade constructor, with optional label parameter to override
         */
        public BrowseTarget(String label, String upType) {
            mLabel = label;
            mUpType = upType;
            mActivityClass = UpgradeListActivity.class;
        }

        public void navigate(Context context) {
            // TODO: trigger a fragment transaction in two pane
            Intent intent = new Intent(context, mActivityClass);
            if (mActivityClass == UpgradeListActivity.class) {
                intent.putExtra(UpgradeListActivity.UPTYPE_KEY, mUpType);
                intent.putExtra(UpgradeListActivity.LABEL_KEY, mLabel);
            }
            startActivity(intent);
        }

        @Override
        public String toString() {
            return mLabel;
        }
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        final Resources res = getActivity().getResources();
        BrowseTarget[] targets = new BrowseTarget[] {
                new BrowseTarget(res.getString(R.string.ships), ShipListActivity.class),
                new BrowseTarget(res.getString(R.string.captains), CaptainsListActivity.class),
                new BrowseTarget(res.getString(R.string.crew), "Crew"),
                new BrowseTarget(res.getString(R.string.talents), "Talent"),
                new BrowseTarget(res.getString(R.string.tech), "Tech"),
                new BrowseTarget(res.getString(R.string.weapons), "Weapon"),
                new BrowseTarget(res.getString(R.string.resources), ResourceListActivity.class),
                new BrowseTarget(res.getString(R.string.flagships), FlagshipListActivity.class),
                new BrowseTarget(res.getString(R.string.sets), SetListActivity.class),
        };

        mAdapter = new ArrayAdapter<BrowseTarget>(getActivity(),
                android.R.layout.simple_list_item_activated_1, targets);
        setListAdapter(mAdapter);
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        Log.d("SPACEDOCK", "onListItemClick " + position + ", " + mAdapter.getItem(position).toString());
        BrowseTarget target = mAdapter.getItem(position);
        target.navigate(getActivity());
    }
}
