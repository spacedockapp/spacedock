package com.funnyhatsoftware.spacedock;

import java.util.List;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.Resource;

public class ResourcesAdapter extends ItemAdapter<Resource> {

    public ResourcesAdapter(Context context, int resource, List<Resource> objects) {
        super(context, resource, objects);
    }

    protected void setupView(int position, View convertView) {
        Resource resource = (Resource) getItem(position);
        TextView title = (TextView) convertView.findViewById(R.id.resourceRowTitle);
        title.setText(resource.getTitle());
        TextView cost = (TextView) convertView.findViewById(R.id.resourceRowCost);
        cost.setText(Integer.toString(resource.getCost()));
    }

}
