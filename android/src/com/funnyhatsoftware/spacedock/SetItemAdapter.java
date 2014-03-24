package com.funnyhatsoftware.spacedock;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.holder.SetItemHolder;
import com.funnyhatsoftware.spacedock.holder.SetItemHolderFactory;

import java.util.ArrayList;

public class SetItemAdapter extends ArrayAdapter<SetItem> {
    private final SetItemHolderFactory mSetItemHolderFactory;
    private final int mLayoutResId;

    public SetItemAdapter(Context context, String faction, int layoutResId,
                          SetItemHolderFactory setItemHolderFactory) {
        super(context, layoutResId,
                new ArrayList<SetItem>(setItemHolderFactory.getItemsForFaction(faction)));
        mSetItemHolderFactory = setItemHolderFactory;
        mLayoutResId = layoutResId;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Object item = getItem(position);
        SetItemHolder holder;
        if (convertView == null) {
            Context context = getContext();
            LayoutInflater inflater = ((Activity) context).getLayoutInflater();
            convertView = inflater.inflate(mLayoutResId, parent, false);
            holder = mSetItemHolderFactory.createHolder(convertView);
            convertView.setTag(holder);
        } else {
            holder = (SetItemHolder) convertView.getTag();
        }
        holder.reinitialize(getContext().getResources(), item);
        return convertView;
    }
}
