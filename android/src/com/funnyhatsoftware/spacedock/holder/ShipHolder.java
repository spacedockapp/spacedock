package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.activity.DetailActivity;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.List;

public class ShipHolder extends ItemHolder {
    public static final String TYPE_STRING = "Ship";
    static ItemHolderFactory getFactory() {
        return new ItemHolderFactory(TYPE_STRING, R.layout.ship_list_row, 0) {
            @Override
            public ItemHolder createHolder(View view) {
                return new ShipHolder(view);
            }

            @Override
            public List<?> getItemsForFaction(String faction) {
                return Universe.getUniverse().getShipsForFaction(faction);
            }

            @Override
            public String getDetails(DetailActivity.DetailDataBuilder builder, String id) {
                Ship ship = Universe.getUniverse().getShip(id);
                builder.addString("Name", ship.getTitle());
                builder.addString("Faction", ship.getFaction());
                builder.addInt("Cost", ship.getCost());
                builder.addBoolean("Unique", ship.getUnique());
                builder.addInt("Attack", ship.getAttack());
                builder.addInt("Agility", ship.getAgility());
                builder.addInt("Hull", ship.getHull());
                builder.addInt("Shields", ship.getShield());
                builder.addInt("Crew", ship.getCrew());
                builder.addInt("Tech", ship.getTech());
                builder.addInt("Weapon", ship.getWeapon());
                builder.addString("Front Arc", ship.formattedFrontArc());
                builder.addString("Rear Arc", ship.formattedRearArc());
                builder.addString("Actions", TextUtils.join(", ", ship.actionStrings()));
                builder.addString("Key Moves", ship.movesSummary());
                builder.addString("Set", ship.getSetName());
                String ability = ship.getAbility();
                if (!ability.isEmpty()) {
                    builder.addString("Ability", ship.getAbility());
                }
                return ship.getTitle();
            }
        };
    }

    final TextView mTitle;
    final TextView mCost;

    private ShipHolder(View view) {
        mTitle = (TextView) view.findViewById(R.id.shipRowTitle);
        mCost = (TextView) view.findViewById(R.id.shipRowCost);
    }

    @Override
    public void reinitialize(Resources res, Object item) {
        Ship ship = (Ship) item;
        mTitle.setText(ship.getTitle());
        mCost.setText(Integer.toString(ship.getCost()));
    }
}
