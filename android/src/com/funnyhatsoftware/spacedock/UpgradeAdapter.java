package com.funnyhatsoftware.spacedock;

import java.util.List;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.Upgrade;

public class UpgradeAdapter extends ItemAdapter<Upgrade> {

    public UpgradeAdapter(Context context, int resource, List<Upgrade> objects) {
        super(context, resource, objects);
    }

    @Override
    protected void setupView(int position, View convertView) {
        Upgrade upgrade = getItem(position);
        TextView title = (TextView) convertView.findViewById(R.id.upgradeRowTitle);
        title.setText(upgrade.getTitle());
        TextView cost = (TextView) convertView.findViewById(R.id.upgradeRowCost);
        cost.setText(Integer.toString(upgrade.getCost()));
    }

}
