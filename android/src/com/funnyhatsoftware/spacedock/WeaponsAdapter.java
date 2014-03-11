
package com.funnyhatsoftware.spacedock;

import java.util.List;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.Upgrade;
import com.funnyhatsoftware.spacedock.data.Weapon;

public class WeaponsAdapter extends ItemAdapter<Upgrade> {

    public WeaponsAdapter(Context context, int resource, List<Upgrade> objects) {
        super(context, resource, objects);
    }

    protected void setupView(int position, View convertView) {
        Weapon weapon = (Weapon) getItem(position);
        TextView title = (TextView) convertView.findViewById(R.id.weaponRowTitle);
        title.setText(weapon.getTitle());
        TextView attack = (TextView) convertView.findViewById(R.id.weaponRowAttack);
        int attackValue = weapon.getAttack();
        if (attackValue > 0) {
            attack.setText(Integer.toString(attackValue));
            attack.setVisibility(View.VISIBLE);
        } else {
            attack.setText("");
            attack.setVisibility(View.INVISIBLE);
        }
        TextView range = (TextView) convertView.findViewById(R.id.weaponRowRange);
        range.setText(weapon.getRange());
        TextView cost = (TextView) convertView.findViewById(R.id.weaponRowCost);
        cost.setText(Integer.toString(weapon.getCost()));
    }

}
