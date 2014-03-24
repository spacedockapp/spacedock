package com.funnyhatsoftware.spacedock;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.holder.ItemHolder;
import com.funnyhatsoftware.spacedock.holder.ItemHolderFactory;

import java.util.ArrayList;

public class ItemAdapter extends ArrayAdapter<SetItem> {
    private final ItemHolderFactory mItemHolderFactory;
    private final int mLayoutResId;

    public ItemAdapter(Context context, String faction, int layoutResId,
            ItemHolderFactory itemHolderFactory) {
        super(context, layoutResId,
                new ArrayList<SetItem>(itemHolderFactory.getItemsForFaction(faction)));
        mItemHolderFactory = itemHolderFactory;
        mLayoutResId = layoutResId;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Object item = getItem(position);
        ItemHolder holder;
        if (convertView == null) {
            Context context = getContext();
            LayoutInflater inflater = ((Activity) context).getLayoutInflater();
            convertView = inflater.inflate(mLayoutResId, parent, false);
            holder = mItemHolderFactory.createHolder(convertView);
            convertView.setTag(holder);
        } else {
            holder = (ItemHolder) convertView.getTag();
        }
        holder.reinitialize(getContext().getResources(), item);
        return convertView;
    }
}
