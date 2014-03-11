
package com.funnyhatsoftware.spacedock;

import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Weapon;

public class WeaponDetailActivity extends UpgradeDetailActivity {
    protected String setupValues(Universe universe, String weaponId) {
        Weapon weapon = (Weapon) universe.getUpgrade(weaponId);

        mValues.add(new Pair("Name", weapon.getTitle()));
        mValues.add(new Pair("Faction", weapon.getFaction()));
        mValues.add(new Pair("Type", weapon.getUpType()));
        int attack = weapon.getAttack();
        if (attack > 0) {
            mValues.add(new Pair("Attack", attack));
        }
        String range = weapon.getRange();
        if (range.length() > 0) {
            mValues.add(new Pair("Range", weapon.getRange()));
        }
        mValues.add(new Pair("Cost", weapon.getCost()));
        mValues.add(new Pair("Unique", weapon.getUnique()));
        mValues.add(new Pair("Set", weapon.getSetName()));
        mValues.add(new Pair("Ability", weapon.getAbility()));
        return weapon.getTitle();
    }

}
