package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Weapon;

import java.util.List;

public class WeaponHolder extends SetItemHolder {
    public static final String TYPE_STRING = "Weapon";
    static SetItemHolderFactory getFactory() {
        return new SetItemHolderFactory(Weapon.class, TYPE_STRING) {
            @Override
            public SetItemHolder createHolder(View view) {
                return new WeaponHolder(view);
            }

            @Override
            public List<? extends SetItem> getItemsForFaction(String faction) {
                return Universe.getUniverse().getUpgradesForFaction(TYPE_STRING, faction);
            }

            @Override
            public String getDetails(DetailsFragment.DetailDataBuilder builder, String id) {
                Weapon weapon = (Weapon) Universe.getUniverse().getUpgrade(id);
                String faction = weapon.getFaction();
                if (!"".equals(weapon.getAdditionalFaction())) {
                    faction += ", " + weapon.getAdditionalFaction();
                }
                builder.addString("Faction", faction);
                builder.addString("Type", weapon.getUpType());
                if (weapon.getAttack() > 0) {
                    builder.addInt("Attack", weapon.getAttack());
                }
                if (!weapon.getRange().isEmpty()) {
                    builder.addString("Range", weapon.getRange());
                }
                builder.addInt("Cost", weapon.getCost())
                        .addBoolean("Unique", weapon.getUnique())
                        .addString("Set", weapon.getSetName())
                        .addString("Ability", weapon.getAbility());
                return weapon.getTitle();
            }
        };
    }

    final TextView mAttack;
    final TextView mRange;

    private WeaponHolder(View view) {
        super(view, R.layout.item_weapon_values);
        mAttack = (TextView) view.findViewById(R.id.attack);
        mRange = (TextView) view.findViewById(R.id.range);
    }

    @Override
    public void reinitializeStubViews(Resources res, SetItem item) {
        Weapon weapon = (Weapon) item;
        setPositiveIntegerText(mAttack, weapon.getAttack());
        mRange.setText(weapon.getRange());
    }
}
