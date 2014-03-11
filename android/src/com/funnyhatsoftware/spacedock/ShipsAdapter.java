
package com.funnyhatsoftware.spacedock;

import java.util.List;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.Ship;

public class ShipsAdapter extends ItemAdapter<Ship> {
    
    public ShipsAdapter(Context context, int resource, List<Ship> objects) {
        super(context, resource, objects);
    }

    protected void setupView(int position, View convertView) {
        Ship ship = (Ship) getItem(position);
        TextView title = (TextView) convertView.findViewById(R.id.shipRowTitle);
        title.setText(ship.getDescriptiveTitle());
        TextView cost = (TextView) convertView.findViewById(R.id.shipRowCost);
        cost.setText(Integer.toString(ship.getCost()));
    }

}
