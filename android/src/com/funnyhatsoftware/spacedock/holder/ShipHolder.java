package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.FactionInfo;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.DataUtils;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.ShipClassDetails;
import com.funnyhatsoftware.spacedock.drawable.ArcDrawable;
import com.funnyhatsoftware.spacedock.drawable.ManeuverGridDrawable;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;
import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.List;

public class ShipHolder extends SetItemHolder {
    public static final String TYPE_STRING = "Ship";
    static SetItemHolderFactory getFactory() {
        return new SetItemHolderFactory(Ship.class, TYPE_STRING) {
            @Override
            public SetItemHolder createHolder(View view) {
                return new ShipHolder(view);
            }

            @Override
            public List<? extends SetItem> getItemsForFaction(String faction) {
                return Universe.getUniverse().getShipsForFaction(faction);
            }

            @Override
            public String getDetails(DetailsFragment.DetailDataBuilder builder, String id) {
                Ship ship = Universe.getUniverse().getShip(id);
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

    final TextView mAttack;
    final TextView mAgility;
    final TextView mHull;
    final TextView mShield;
    final TextView mClass;
    final ArcDrawable mArcDrawable;
    final ManeuverGridDrawable mManeuverGridDrawable;

    @SuppressWarnings("deprecation")
    private ShipHolder(View view) {
        super(view, R.layout.item_ship_values, R.layout.item_ship_detail_row);
        mAttack = (TextView) view.findViewById(R.id.attack);
        mAgility = (TextView) view.findViewById(R.id.agility);
        mHull = (TextView) view.findViewById(R.id.hull);
        mShield = (TextView) view.findViewById(R.id.shield);

        // detailed display
        mClass = (TextView) view.findViewById(R.id.clazz);
        if (mClass == null) {
            mArcDrawable = null;
            mManeuverGridDrawable = null;
        } else {
            mArcDrawable = new ArcDrawable(view.getResources());
            view.findViewById(R.id.arc_display).setBackgroundDrawable(mArcDrawable);
            mManeuverGridDrawable = new ManeuverGridDrawable(view.getResources());
            view.findViewById(R.id.maneuver_display).setBackgroundDrawable(mManeuverGridDrawable);
        }
    }

    @Override
    public void reinitializeStubViews(Resources res, SetItem item) {
        Ship ship = (Ship) item;
        mAttack.setText(Integer.toString(ship.getAttack()));
        mAgility.setText(Integer.toString(ship.getAgility()));
        mHull.setText(Integer.toString(ship.getHull()));
        mShield.setText(Integer.toString(ship.getShield()));

        if (!ship.isUnique()) {
            // override title to use ship class
            mTitle.setText(ship.getShipClass());
        }

        if (mClass != null) {
            ShipClassDetails details = ship.getShipClassDetails();
            int factionColor = FactionInfo.getFactionColor(
                    mClass.getResources(), ship.getFaction());
            int frontArc = DataUtils.intValue(details.getFrontArc());
            int rearArc = DataUtils.intValue(details.getRearArc());
            mClass.setText(ship.getShipClass());
            mArcDrawable.setArc(factionColor, frontArc, rearArc);
            mManeuverGridDrawable.setManeuvers(details.getManeuvers());
        }
    }
}
