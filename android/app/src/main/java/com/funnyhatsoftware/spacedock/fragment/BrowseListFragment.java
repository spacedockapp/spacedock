package com.funnyhatsoftware.spacedock.fragment;

import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.activity.SetItemListActivity;
import com.funnyhatsoftware.spacedock.data.Upgrade;
import com.funnyhatsoftware.spacedock.holder.AdmiralHolder;
import com.funnyhatsoftware.spacedock.holder.CaptainHolder;
import com.funnyhatsoftware.spacedock.holder.ExpansionHolder;
import com.funnyhatsoftware.spacedock.holder.FlagshipHolder;
import com.funnyhatsoftware.spacedock.holder.FleetCaptainHolder;
import com.funnyhatsoftware.spacedock.holder.ReferenceHolder;
import com.funnyhatsoftware.spacedock.holder.ResourceHolder;
import com.funnyhatsoftware.spacedock.holder.ShipHolder;
import com.funnyhatsoftware.spacedock.holder.UpgradeHolder;
import com.funnyhatsoftware.spacedock.holder.WeaponHolder;

public class BrowseListFragment extends ListFragment {
    public interface BrowseTypeSelectionListener {
        public void onBrowseTypeSelected(String itemType);
    }

    ArrayAdapter<String> mAdapter;
    BrowseTypeSelectionListener mSelectListener;

    /* This list must be kept in sync with R.array.browse_items_list */
    static final String[] TYPE_MAP = {
        ShipHolder.TYPE_STRING,
        AdmiralHolder.TYPE_STRING,
        CaptainHolder.TYPE_STRING,
        UpgradeHolder.TYPE_STRING_CREW,
        UpgradeHolder.TYPE_STRING_TALENT,
        UpgradeHolder.TYPE_STRING_TECH,
        UpgradeHolder.TYPE_STRING_BORG,
        WeaponHolder.TYPE_STRING,
        ResourceHolder.TYPE_STRING,
        FlagshipHolder.TYPE_STRING,
        FleetCaptainHolder.TYPE_STRING,
        ReferenceHolder.TYPE_STRING,
        ExpansionHolder.TYPE_STRING,
        UpgradeHolder.TYPE_STRING_SQUADRON,
        UpgradeHolder.TYPE_STRING_OFFICER,
    };

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        String[] browseLabels = getResources().getStringArray(R.array.browse_items_list);
        mAdapter = new ArrayAdapter<String>(getActivity(),
                android.R.layout.simple_list_item_activated_1,
                browseLabels);
        setListAdapter(mAdapter);

        if (getParentFragment() != null) {
            // parent fragment, if present, must handle browse type selection
            mSelectListener = (BrowseTypeSelectionListener) getParentFragment();
        }
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        String targetType = TYPE_MAP[position];
        if (mSelectListener == null) {
            startActivity(SetItemListActivity.BrowseActivity.getIntent(getActivity(), targetType));
        } else {
            mSelectListener.onBrowseTypeSelected(targetType);
        }
    }
}
