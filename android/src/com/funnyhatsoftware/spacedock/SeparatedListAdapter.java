package com.funnyhatsoftware.spacedock;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Adapter;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;

import java.util.LinkedHashMap;
import java.util.Map;

public class SeparatedListAdapter extends BaseAdapter {
    public final Map<String, Adapter> mSections = new LinkedHashMap<String, Adapter>();
    public final ArrayAdapter<String> mHeaders;
    public final static int TYPE_SECTION_HEADER = 0;

    public SeparatedListAdapter(Context context) {
        mHeaders = new ArrayAdapter<String>(context, R.layout.list_header);
    }

    public void addSection(String section, Adapter adapter) {
        mHeaders.add(section);
        mSections.put(section, adapter);
    }

    public Object getItem(int position) {
        for (String section : mSections.keySet()) {
            Adapter adapter = mSections.get(section);
            int size = adapter.getCount() + 1;

            // check if position inside this section
            if (position == 0) {
                return section;
            }
            if (position < size) {
                return adapter.getItem(position - 1);
            }

            // otherwise jump into next section
            position -= size;
        }
        return null;
    }

    public int getCount() {
        // total together all sections, plus one for each section header
        int total = 0;
        for (Adapter adapter : mSections.values())
            total += adapter.getCount() + 1;
        return total;
    }

    @Override
    public int getViewTypeCount() {
        // assume that headers count as one, then total all sections
        int total = 1;
        for (Adapter adapter : mSections.values()) {
            total += adapter.getViewTypeCount();
        }
        return total;
    }

    @Override
    public int getItemViewType(int position) {
        int type = 1;
        for (String section : mSections.keySet()) {
            Adapter adapter = mSections.get(section);
            int size = adapter.getCount() + 1;

            // check if position inside this section
            if (position == 0) {
                return TYPE_SECTION_HEADER;
            }
            if (position < size) {
                return type + adapter.getItemViewType(position - 1);
            }

            // otherwise jump into next section
            position -= size;
            type += adapter.getViewTypeCount();
        }
        return -1;
    }

    @Override
    public boolean isEnabled(int position) {
        return (getItemViewType(position) != TYPE_SECTION_HEADER);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        int sectionIndex = 0;
        for (String section : mSections.keySet()) {
            Adapter adapter = mSections.get(section);
            int size = adapter.getCount() + 1;

            // check if position inside this section
            if (position == 0) {
                return mHeaders.getView(sectionIndex, convertView, parent);
            }
            if (position < size) {
                return adapter.getView(position - 1, convertView, parent);
            }

            // otherwise jump into next section
            position -= size;
            sectionIndex++;
        }
        return null;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

}