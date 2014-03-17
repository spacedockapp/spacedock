package com.funnyhatsoftware.spacedock.holder;

import android.content.Context;
import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.WeaponDetailActivity;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Weapon;

import java.util.List;

public class WeaponHolder extends ItemHolder {
    public static final String TYPE_STRING = "Weapon";
    static ItemHolderFactory getFactory() {
        return new ItemHolderFactory(TYPE_STRING, R.layout.weapon_list_row, 0) {
            @Override
            public ItemHolder createHolder(View view) {
                return new WeaponHolder(view);
            }

            @Override
            public List<?> getItemsForFaction(String faction) {
                return Universe.getUniverse().getUpgradesForFaction(TYPE_STRING, faction);
            }
        };
    }

    final TextView mTitle;
    final TextView mAttack;
    final TextView mRange;
    final TextView mCost;

    private WeaponHolder(View view) {
        mTitle = (TextView) view.findViewById(R.id.weaponRowTitle);
        mAttack = (TextView) view.findViewById(R.id.weaponRowAttack);
        mRange = (TextView) view.findViewById(R.id.weaponRowRange);
        mCost = (TextView) view.findViewById(R.id.weaponRowCost);
    }

    @Override
    public void reinitialize(Resources res, Object item) {
        Weapon weapon = (Weapon) item;
        mTitle.setText(weapon.getTitle());

        setPositiveIntegerText(mAttack, weapon.getAttack());
        mRange.setText(weapon.getRange());
        mCost.setText(Integer.toString(weapon.getCost()));
    }

    @Override
    public void navigateToDetails(Context context, Object item) {
        navigateToDetailsActivity(context, (SetItem)item, WeaponDetailActivity.class);
    }
}
