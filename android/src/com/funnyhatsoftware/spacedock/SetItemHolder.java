package com.funnyhatsoftware.spacedock;

import android.graphics.Color;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.DataUtils;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.ShipClassDetails;

public class SetItemHolder {
    static int getLayoutForSlot(int slotType) {
        switch(slotType) {
            case EquipHelper.SLOT_TYPE_CAPTAIN:
            case EquipHelper.SLOT_TYPE_CREW:
            case EquipHelper.SLOT_TYPE_TECH:
            case EquipHelper.SLOT_TYPE_TALENT:
            case EquipHelper.SLOT_TYPE_WEAPON:
                return R.layout.item_list_basic;

            case EquipHelper.SLOT_TYPE_SHIP:
                return R.layout.item_list_ship;
        }
        throw new IllegalArgumentException();
    }

    static SetItemHolder createHolder(View view, int slotType) {
        switch(slotType) {
            case EquipHelper.SLOT_TYPE_CAPTAIN:
            case EquipHelper.SLOT_TYPE_CREW:
            case EquipHelper.SLOT_TYPE_TECH:
            case EquipHelper.SLOT_TYPE_TALENT:
            case EquipHelper.SLOT_TYPE_WEAPON:
                return new SetItemHolder(view);

            case EquipHelper.SLOT_TYPE_SHIP:
                return new ShipHolder(view);
        }
        throw new IllegalArgumentException();
    }

    private final TextView mFactionTextView;
    private final TextView mUniqueTextView;
    private final TextView mCostTextView;
    private final TextView mAbilityTextView;

    public SetItemHolder(View view) {
        mFactionTextView = (TextView) view.findViewById(R.id.faction);
        mCostTextView = (TextView) view.findViewById(R.id.cost);
        mUniqueTextView = (TextView) view.findViewById(R.id.unique);
        mAbilityTextView = (TextView) view.findViewById(R.id.ability);
    }

    public void reinitialize(SetItem item) {
        String faction = item.getFaction();
        mFactionTextView.setTextColor(FactionInfo.getFactionColor(
                mFactionTextView.getResources(),
                item.getFaction()));
        mFactionTextView.setText(faction.substring(0, 3));
        mCostTextView.setText(Integer.toString(item.getCost()));
        mUniqueTextView.setText(item.getUnique() ? "U" : "");

        String ability = item.getAbility();
        boolean hasAbility = ability != null && !ability.isEmpty();
        mAbilityTextView.setText(ability);
        mAbilityTextView.setVisibility(hasAbility ? View.VISIBLE : View.GONE);
    }

    static class ShipHolder extends SetItemHolder {
        private final ArcDrawable mArcDrawable = new ArcDrawable();
        private final ManeuverGridDrawable mManeuverGridDrawable;
        private final TextView mClassTextView;
        private final TextView mAttackTextView;
        private final TextView mAgilityTextView;
        private final TextView mHullTextView;
        private final TextView mShieldTextView;
        public ShipHolder(View view) {
            super(view);
            mManeuverGridDrawable = new ManeuverGridDrawable(view.getContext());

            view.findViewById(R.id.arc_display).setBackgroundDrawable(mArcDrawable);
            view.findViewById(R.id.maneuver_display).setBackgroundDrawable(mManeuverGridDrawable);
            mClassTextView = (TextView) view.findViewById(R.id.clazz);
            mAttackTextView = (TextView) view.findViewById(R.id.attack);
            mAgilityTextView = (TextView) view.findViewById(R.id.agility);
            mHullTextView = (TextView) view.findViewById(R.id.hull);
            mShieldTextView = (TextView) view.findViewById(R.id.shield);
        }

        @Override
        public void reinitialize(SetItem item) {
            super.reinitialize(item);
            Ship ship = (Ship) item;
            ShipClassDetails details = ship.getShipClassDetails();

            if (details != null) {
                int factionColor = FactionInfo.getFactionColor(
                        mClassTextView.getResources(), ship.getFaction());
                int frontArc = DataUtils.intValue(details.getFrontArc());
                int rearArc = DataUtils.intValue(details.getRearArc());
                mArcDrawable.setArc(factionColor, frontArc, rearArc);
                mManeuverGridDrawable.setManeuvers(details.getManeuvers());
            } else {
                // TODO: fix cases where details are missing
                mArcDrawable.setArc(Color.BLACK, 0, 0);
                mManeuverGridDrawable.setManeuvers(null);
            }

            mClassTextView.setText(ship.getShipClass());
            mAttackTextView.setText(Integer.toString(ship.getAttack()));
            mAgilityTextView.setText(Integer.toString(ship.getAgility()));
            mHullTextView.setText(Integer.toString(ship.getHull()));
            mShieldTextView.setText(Integer.toString(ship.getShield()));
        }
    }
}
