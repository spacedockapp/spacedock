
package com.funnyhatsoftware.spacedock;

import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

public abstract class ItemAdapter<T> extends ArrayAdapter<T> {

    protected int layoutResourceId;

    public ItemAdapter(Context context, int resource, List<T> objects) {
        super(context, resource, objects);
        layoutResourceId = resource;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        if (convertView == null) {
            Context context = getContext();
            LayoutInflater inflater = ((Activity) context).getLayoutInflater();
            convertView = inflater.inflate(layoutResourceId, parent, false);
        }
        setupView(position, convertView);
        return convertView;
    }

    protected abstract void setupView(int position, View convertView);

}
