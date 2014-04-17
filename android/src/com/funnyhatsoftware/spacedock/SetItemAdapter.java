package com.funnyhatsoftware.spacedock;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.holder.FlagshipHolder;
import com.funnyhatsoftware.spacedock.holder.SetItemHolder;
import com.funnyhatsoftware.spacedock.holder.SetItemHolderFactory;

import java.util.ArrayList;
import java.util.List;

public class SetItemAdapter extends ArrayAdapter<SetItem> {
    private final SetItemHolderFactory mSetItemHolderFactory;
    private final int mLayoutResId;

    public static SetItemAdapter CreateFactionAdapter(Context context, String faction,
            int layoutResId, SetItemHolderFactory factory) {
        List<? extends SetItem> factionItemList = factory.getItemsForFaction(faction);

        if (factionItemList == null || factionItemList.isEmpty()) return null;

        ArrayList<SetItem> items = new ArrayList<SetItem>(factionItemList);
        return new SetItemAdapter(context, layoutResId, factory, items);
    }

    public static SetItemAdapter CreatePlaceholderAdapter(Context context,
            int layoutResId, SetItemHolderFactory factory) {
        SetItem placeholder;
        if (factory.getType().equals(FlagshipHolder.TYPE_STRING)) {
            placeholder = Universe.getUniverse().getOrCreateFlagshipPlaceholder();
        } else {
            placeholder = Universe.getUniverse().findOrCreatePlaceholder(factory.getType());
        }

        if (placeholder == null) {
            throw new IllegalStateException("missing placeholder of type " + factory.getType());
        }

        ArrayList<SetItem> items = new ArrayList<SetItem>(1);
        items.add(placeholder);
        return new SetItemAdapter(context, layoutResId, factory, items);

    }

    private SetItemAdapter(Context context, int layoutResId,
            SetItemHolderFactory setItemHolderFactory, ArrayList<SetItem> items) {
        super(context, layoutResId, items);
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
