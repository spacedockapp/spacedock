package com.funnyhatsoftware.spacedock;

import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

/**
 * Merges two adapters to add a Header, much like ListView.addHeaderView()
 *
 * This approach allows adding a header view to ListFragments, where ListView and
 * Adapter lifecycles are outside of application control.
 */
public class HeaderAdapter extends BaseAdapter {
    private final BaseAdapter mHeaderAdapter;
    private final BaseAdapter mWrappedAdapter;

    public HeaderAdapter(BaseAdapter headerAdapter, BaseAdapter wrappedAdapter) {
        if (headerAdapter.getCount() != 1) {
            throw new IllegalArgumentException();
        }
        mHeaderAdapter = headerAdapter;
        mWrappedAdapter = wrappedAdapter;
    }

    @Override
    public int getCount() {
        return mWrappedAdapter.getCount() + 1;
    }

    @Override
    public int getViewTypeCount() {
        return 1 + mWrappedAdapter.getViewTypeCount();
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            return 0;
        } else {
            return mWrappedAdapter.getItemViewType(position - 1) + 1;
        }
    }

    @Override
    public boolean isEnabled(int position) {
        if (position == 0) {
            return mHeaderAdapter.isEnabled(0);
        }
        return mWrappedAdapter.isEnabled(position - 1);
    }

    @Override
    public Object getItem(int position) {
        if (position == 0) {
            return mHeaderAdapter.getItem(0);
        }
        return mWrappedAdapter.getItem(position - 1);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        if (position == 0) {
            return mHeaderAdapter.getView(0, convertView, parent);
        }
        return mWrappedAdapter.getView(position - 1, convertView, parent);
    }
}
