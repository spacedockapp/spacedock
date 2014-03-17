package com.funnyhatsoftware.spacedock.holder;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import java.util.ArrayList;

public class NewItemAdapter extends ArrayAdapter<Object> {

    private final ItemHolderFactory mItemHolderFactory;
    public NewItemAdapter(Context context, String faction,
            ItemHolderFactory itemHolderFactory) {
        super(context, itemHolderFactory.getSimpleLayoutResId(),
                new ArrayList<Object>(itemHolderFactory.getItemsForFaction(faction)));
        mItemHolderFactory = itemHolderFactory;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Object item = getItem(position);
        ItemHolder holder;
        if (convertView == null) {
            Context context = getContext();
            LayoutInflater inflater = ((Activity) context).getLayoutInflater();
            convertView = inflater.inflate(mItemHolderFactory.getSimpleLayoutResId(), parent, false);
            holder = mItemHolderFactory.createHolder(convertView);
            convertView.setTag(holder);
        } else {
            holder = (ItemHolder) convertView.getTag();
        }
        holder.reinitialize(getContext().getResources(), item);
        return convertView;
    }
}
