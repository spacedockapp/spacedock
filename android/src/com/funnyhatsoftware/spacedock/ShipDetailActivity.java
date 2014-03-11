
package com.funnyhatsoftware.spacedock;

import android.text.TextUtils;

import com.funnyhatsoftware.spacedock.data.Ship;
import com.funnyhatsoftware.spacedock.data.Universe;

public class ShipDetailActivity extends DetailActivity {

    @Override
    protected String setupValues(Universe universe, String itemId) {
        Ship ship = universe.getShip(itemId);

        mValues.add(new Pair("Name", ship.getTitle()));
        mValues.add(new Pair("Faction", ship.getFaction()));
        mValues.add(new Pair("Cost", ship.getCost()));
        mValues.add(new Pair("Unique", ship.getUnique()));
        mValues.add(new Pair("Attack", ship.getAttack()));
        mValues.add(new Pair("Agility", ship.getAgility()));
        mValues.add(new Pair("Hull", ship.getHull()));
        mValues.add(new Pair("Shields", ship.getShield()));
        mValues.add(new Pair("Crew", ship.getCrew()));
        mValues.add(new Pair("Tech", ship.getTech()));
        mValues.add(new Pair("Weapon", ship.getWeapon()));
        mValues.add(new Pair("Front Arc", ship.formattedFrontArc()));
        mValues.add(new Pair("Rear Arc", ship.formattedRearArc()));
        mValues.add(new Pair("Actions", TextUtils.join(", ", ship.actionStrings())));
        mValues.add(new Pair("Key Moves", ship.movesSummary()));
        mValues.add(new Pair("Set", ship.getSetName()));
        String ability = ship.getAbility();
        if (ability.length() > 0) {
            mValues.add(new Pair("Ability", ship.getAbility()));
        }
        return ship.getTitle();
    }

}
