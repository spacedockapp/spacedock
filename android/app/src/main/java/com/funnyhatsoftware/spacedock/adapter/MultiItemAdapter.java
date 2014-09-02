package com.funnyhatsoftware.spacedock.adapter;

import android.app.Activity;
import android.content.Context;
import android.support.v4.util.ArrayMap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.fragment.DisplaySquadFragment;
import com.funnyhatsoftware.spacedock.holder.SetItemHolder;
import com.funnyhatsoftware.spacedock.holder.SetItemHolderFactory;

import java.util.ArrayList;
import java.util.List;

public class MultiItemAdapter extends ArrayAdapter<Object> {
    // force detailed item display in this view
    private static final int LAYOUT_RES_ID = R.layout.item_with_details;

    private String mTitle;

    public String getTitle() {
        return mTitle;
    }

    public void appendTitleIndex(int index) {
        mTitle += " " + Integer.toString(index);
    }

    public MultiItemAdapter(Context context, String title, List<Object> items) {
        super(context, 0, items);
        mTitle = title;
    }

    @Override
    public int getViewTypeCount() {
        return SetItemHolderFactory.getFactoryTypes().size();
    }

    // Maps seen types->unique integers for recycling differentiation
    private final ArrayMap<Class, Integer> mTypeMap =
            new ArrayMap<Class, Integer>();

    @Override
    public int getItemViewType(int position) {
        Object item = getItem(position);
        Class clazz = item.getClass();
        if (!mTypeMap.containsKey(clazz)) {
            mTypeMap.put(clazz, mTypeMap.size());
        }
        return mTypeMap.get(clazz);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Object item = getItem(position);
        SetItemHolder holder;
        if (convertView == null) {
            SetItemHolderFactory setItemHolderFactory =
                    SetItemHolderFactory.getHolderFactory(item.getClass());

            Context context = getContext();
            LayoutInflater inflater = ((Activity) context).getLayoutInflater();
            convertView = inflater.inflate(LAYOUT_RES_ID, parent, false);
            holder = setItemHolderFactory.createHolder(convertView);
            convertView.setTag(holder);
        } else {
            holder = (SetItemHolder) convertView.getTag();
        }
        holder.reinitialize(getContext().getResources(), item);
        return convertView;
    }
}
