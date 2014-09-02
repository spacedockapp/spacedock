
package com.funnyhatsoftware.spacedock.fragment;

import android.content.Context;
import android.os.Bundle;

import com.funnyhatsoftware.spacedock.adapter.MultiItemAdapter;
import com.funnyhatsoftware.spacedock.adapter.SeparatedListAdapter;
import com.funnyhatsoftware.spacedock.data.Set;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class DisplaySetFragment extends FullscreenListFragment {
    private static final String ARG_SET_ID = "set_id";

    String mSetId;

    public static DisplaySetFragment newInstance(String setId) {
        if (setId == null) {
            throw new IllegalArgumentException("squad uuid required");
        }

        DisplaySetFragment fragment = new DisplaySetFragment();
        Bundle args = new Bundle();
        args.putString(ARG_SET_ID, setId);
        fragment.setArguments(args);
        return fragment;
    }

    private void initAdapter() {
        Context context = getActivity();
        Set set = Universe.getUniverse().getSet(mSetId);
        if (set == null) {
            // fragment now invalid, detach
            getFragmentManager().beginTransaction()
                    .remove(this)
                    .commit();
            return;
        }

        final SeparatedListAdapter multiAdapter = new SeparatedListAdapter(context) {
            @Override
            public boolean isEnabled(int position) {
                // TODO: this is gross, have SeparatedListAdapter defer
                // isEnabled() to subadapters
                return false;
            }
        };

        Map<String, List<SetItem>> itemsForSet = Universe.getUniverse().getItemsForSet(mSetId);
        for (String categoryLabel : itemsForSet.keySet()) {
            // TODO: force ArrayList<SetItem> everywhere?
            List<Object> itemsInCategory = new ArrayList<Object>();
            itemsInCategory.addAll(itemsForSet.get(categoryLabel));
            multiAdapter.addSection(categoryLabel,
                    new MultiItemAdapter(context, categoryLabel, itemsInCategory));
        }
        setListAdapter(multiAdapter);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mSetId = getArguments().getString(ARG_SET_ID);
    }

    @Override
    public void onResume() {
        super.onResume();

        // recreate adapter from scratch, since squad contents may have changed
        initAdapter();
    }

}
