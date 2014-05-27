package com.funnyhatsoftware.spacedock.fragment;

import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

/**
 * Temporary hack for the two ListFragments which take up the entire screen on wide displays.
 *
 * TODO: remove once the UI is redesigned to avoid single pane, simple list on big devices.
 */
public class FullscreenListFragment extends ListFragment {
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        View inflated = super.onCreateView(inflater, container, savedInstanceState);

        float density = getResources().getDisplayMetrics().density;
        float paddingDp = (getResources().getConfiguration().screenWidthDp - 600) / 4;
        if (paddingDp > 0) {
            int padding = (int) (paddingDp * density);
            inflated.setPadding(padding, 0, padding, 0);
        }
        return inflated;
    }
}
