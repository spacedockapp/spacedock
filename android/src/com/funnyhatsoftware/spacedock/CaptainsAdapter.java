
package com.funnyhatsoftware.spacedock;

import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.Captain;

public class CaptainsAdapter extends android.widget.ArrayAdapter<Captain> {
    int layoutResourceId;

    public CaptainsAdapter(Context context, int resource, List<Captain> objects) {
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
        Captain captain = getItem(position);
        TextView title = (TextView) convertView.findViewById(R.id.captainRowTitle);
        title.setText(captain.getTitle());
        TextView skill = (TextView) convertView.findViewById(R.id.captainRowSkill);
        skill.setText(Integer.toString(captain.getSkill()));
        TextView cost = (TextView) convertView.findViewById(R.id.captainRowCost);
        cost.setText(Integer.toString(captain.getCost()));
        return convertView;
    }

}
