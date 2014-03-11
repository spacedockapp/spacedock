
package com.funnyhatsoftware.spacedock;

import java.util.List;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.Captain;

public class CaptainsAdapter extends ItemAdapter<Captain> {
    public CaptainsAdapter(Context context, int resource, List<Captain> objects) {
        super(context, resource, objects);
    }

    protected void setupView(int position, View convertView) {
        Captain captain = getItem(position);
        TextView title = (TextView) convertView.findViewById(R.id.captainRowTitle);
        title.setText(captain.getTitle());
        TextView skill = (TextView) convertView.findViewById(R.id.captainRowSkill);
        skill.setText(Integer.toString(captain.getSkill()));
        TextView cost = (TextView) convertView.findViewById(R.id.captainRowCost);
        cost.setText(Integer.toString(captain.getCost()));
    }

}
