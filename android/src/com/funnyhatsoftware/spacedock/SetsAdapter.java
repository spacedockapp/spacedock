package com.funnyhatsoftware.spacedock;

import java.util.List;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.Set;

public class SetsAdapter extends ItemAdapter<Set> {
    public SetsAdapter(Context context, int resource, List<Set> objects) {
        super(context, resource, objects);
    }

    protected void setupView(int position, View convertView) {
        Set set = (Set) getItem(position);
        TextView productName = (TextView) convertView.findViewById(R.id.setRowProductName);
        productName.setText(set.getProductName());
    }
}
