package com.funnyhatsoftware.spacedock.fragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.funnyhatsoftware.spacedock.R;

public abstract class TwoPaneFragment extends Fragment {
    private final static String TAG_PRIMARY = "tag_primary";
    abstract Fragment createPrimaryFragment();
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_two_pane, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        if (savedInstanceState == null) {
            getChildFragmentManager().beginTransaction()
                    .replace(R.id.primary_fragment_container, createPrimaryFragment(), TAG_PRIMARY)
                    .commit();
        }
    }

    protected Fragment getPrimaryFragment() {
        return getChildFragmentManager().findFragmentByTag(TAG_PRIMARY);
    }
}
